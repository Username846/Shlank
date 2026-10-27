class_name EpisodePlayer
extends Node2D
## Plays an EpisodeScript: stages the sets and actors, voices the dialogue,
## runs the camera, transitions and title cards.

signal exited

const GROUND := 612.0
const CARD_COLORS := [Color("f5c542"), Color("f28ab3"), Color("63c3a5"), Color("6fb3e8"), Color("b48be0")]
const SceneTransition := preload("res://scripts/ui/transition.gd")
const TitleCard := preload("res://scripts/ui/title_card.gd")

var ep: EpisodeScript
## What to play when this episode ends (set by the menu); empty for the last one in a series.
var on_next: Callable
var next_title := ""
const AUTOPLAY_DELAY := 5.0

var _world: Node2D
var _backdrop: Backdrop
var _actors: Node2D
var _cam: Camera2D
var _cast: Dictionary = {}  # id -> Puppet

var _ui: CanvasLayer
var _sub_panel: PanelContainer
var _sub_name: Label
var _sub_text: Label
var _wipe: Control
var _card: Control
var _loc_label: Label
var _hud: Control
var _progress: ProgressBar
var _time_label: Label
var _pause_btn: Button
var _pause_overlay: Control
var _end_overlay: Control
var _next_label: Label
var _next_btn: Button
var _next_t := AUTOPLAY_DELAY

var _paused := false
var _skip := false
var _quit := false
var _index := 0
var _total := 1.0
var _done_time := 0.0
var _shake := 0.0
var _hud_idle := 0.0
var _first_scene := true
var _card_i := 0
var _last_speaker := ""

const TRANSITION_SFX := {"bubbles": "bubbles", "iris": "slide_whistle", "star": "sparkle", "heart": "ding",
	"slide": "whoosh", "checker": "pop", "pinwheel": "slide_whistle", "flash": "blast", "slash": "sword",
	"pixel": "powerup", "door": "hiss", "fade": ""}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_world = Node2D.new()
	_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_world)
	_backdrop = Backdrop.new()
	_world.add_child(_backdrop)
	_actors = Node2D.new()
	_actors.y_sort_enabled = true
	_world.add_child(_actors)
	_cam = Camera2D.new()
	_cam.position = Vector2(640, 360)
	_cam.limit_left = -60
	_cam.limit_top = -60
	_cam.limit_right = 1340
	_cam.limit_bottom = 780
	_world.add_child(_cam)
	_cam.make_current()
	_build_ui()


# ------------------------------------------------------------------- UI --

func _build_ui() -> void:
	_ui = CanvasLayer.new()
	_ui.layer = 10
	add_child(_ui)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UiKit.make_theme()
	_ui.add_child(root)

	# Subtitles
	_sub_panel = PanelContainer.new()
	var sub_box := UiKit.box(Color(1, 1, 1, 0.9), 20, 4, 5)
	sub_box.content_margin_top = 6
	sub_box.content_margin_bottom = 8
	_sub_panel.add_theme_stylebox_override("panel", sub_box)
	_sub_panel.anchor_left = 0.5
	_sub_panel.anchor_right = 0.5
	_sub_panel.anchor_top = 1.0
	_sub_panel.anchor_bottom = 1.0
	_sub_panel.offset_left = -450
	_sub_panel.offset_right = 450
	_sub_panel.offset_top = -104
	_sub_panel.offset_bottom = -16
	_sub_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_sub_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 0)
	_sub_panel.add_child(vb)
	_sub_name = UiKit.title_label("", 22)
	_sub_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vb.add_child(_sub_name)
	_sub_text = UiKit.label("", 23)
	_sub_text.custom_minimum_size = Vector2(860, 0)
	vb.add_child(_sub_text)
	_sub_panel.visible = false

	_loc_label = UiKit.title_label("", 30, Color.WHITE)
	_loc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_loc_label.position = Vector2(28, 20)
	_loc_label.modulate.a = 0.0
	root.add_child(_loc_label)

	_card = TitleCard.new()
	root.add_child(_card)
	_wipe = SceneTransition.new()
	root.add_child(_wipe)

	# HUD
	_hud = Control.new()
	_hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_hud)
	# Top-right cluster, left of the always-on volume/fullscreen buttons:
	# playback buttons, with the progress bar and time underneath.
	var cluster := VBoxContainer.new()
	cluster.add_theme_constant_override("separation", 8)
	cluster.position = Vector2(1280 - 206 - 10 - 194, 16)
	cluster.custom_minimum_size = Vector2(194, 0)
	_hud.add_child(cluster)
	var bar := HBoxContainer.new()
	bar.alignment = BoxContainer.ALIGNMENT_END
	bar.add_theme_constant_override("separation", 10)
	cluster.add_child(bar)
	_pause_btn = UiKit.button("II", UiKit.YELLOW, 24)
	_pause_btn.tooltip_text = "Pause (Space)"
	_pause_btn.custom_minimum_size = Vector2(58, 56)
	_pause_btn.pressed.connect(toggle_pause)
	bar.add_child(_pause_btn)
	var skip_btn := UiKit.button(">>", UiKit.TEAL, 24)
	skip_btn.tooltip_text = "Skip line (Right arrow / click)"
	skip_btn.custom_minimum_size = Vector2(58, 56)
	skip_btn.pressed.connect(func() -> void: _skip = true)
	bar.add_child(skip_btn)
	var quit_btn := UiKit.button("X", UiKit.RED, 24)
	quit_btn.tooltip_text = "Back to menu (Esc)"
	quit_btn.custom_minimum_size = Vector2(58, 56)
	quit_btn.pressed.connect(quit)
	bar.add_child(quit_btn)
	var prow := HBoxContainer.new()
	prow.add_theme_constant_override("separation", 8)
	cluster.add_child(prow)
	_time_label = UiKit.label("0:00 / 0:00", 16, Color.WHITE)
	_time_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_time_label.add_theme_constant_override("outline_size", 5)
	_time_label.add_theme_color_override("font_outline_color", Art.INK)
	_time_label.custom_minimum_size = Vector2(84, 0)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	prow.add_child(_time_label)
	_progress = ProgressBar.new()
	_progress.show_percentage = false
	_progress.max_value = 1.0
	_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# Slim styles: no content margins, so the bar really is 10px tall.
	var bg := UiKit.box(Color(0, 0, 0, 0.35), 5, 2, 0)
	var fill := UiKit.box(UiKit.YELLOW, 5, 2, 0)
	for sb in [bg, fill]:
		sb.content_margin_left = 0
		sb.content_margin_right = 0
		sb.content_margin_top = 0
		sb.content_margin_bottom = 0
	_progress.add_theme_stylebox_override("background", bg)
	_progress.add_theme_stylebox_override("fill", fill)
	_progress.custom_minimum_size = Vector2(0, 10)
	prow.add_child(_progress)

	_pause_overlay = _make_overlay("PAUSED", [["Resume", UiKit.YELLOW, toggle_pause], ["Back to Menu", UiKit.RED, quit]])
	root.add_child(_pause_overlay)
	_end_overlay = _make_overlay("THE END", [["Watch Again", UiKit.YELLOW, _restart], ["Back to Menu", UiKit.TEAL, quit]])
	root.add_child(_end_overlay)
	# "Up next" under the end buttons, when there's a next episode in the series
	var end_box: VBoxContainer = _end_overlay.get_child(0)
	_next_btn = UiKit.button("Next Episode >", UiKit.PINK, 32)
	_next_btn.custom_minimum_size = Vector2(320, 64)
	_next_btn.pressed.connect(_play_next)
	end_box.add_child(_next_btn)
	end_box.move_child(_next_btn, 1)
	_next_label = UiKit.label("", 20, Color.WHITE)
	_next_label.add_theme_constant_override("outline_size", 5)
	_next_label.add_theme_color_override("font_outline_color", Art.INK)
	_next_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_next_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	end_box.add_child(_next_label)


func _make_overlay(title: String, buttons: Array) -> Control:
	var o := ColorRect.new()
	o.color = Color(0.03, 0.1, 0.2, 0.6)
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.visible = false
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.add_theme_constant_override("separation", 16)
	o.add_child(box)
	box.add_child(UiKit.title_label(title, 72))
	for b in buttons:
		var btn := UiKit.button(b[0], b[1], 32)
		btn.custom_minimum_size = Vector2(320, 64)
		btn.pressed.connect(b[2])
		box.add_child(btn)
	return o


# -------------------------------------------------------------- control --

func play(episode: EpisodeScript) -> void:
	ep = episode
	_total = maxf(ep.estimate_duration(), 1.0)
	Game.refresh_voices()
	_run()


func _play_next() -> void:
	if not on_next.is_valid():
		return
	_quit = true
	Game.stop_speaking()
	get_tree().paused = false
	on_next.call()


func _restart() -> void:
	_end_overlay.visible = false
	for p in _cast.values():
		p.queue_free()
	_cast.clear()
	_first_scene = true
	_done_time = 0.0
	_card.visible = false
	_run()


func toggle_pause() -> void:
	if _end_overlay.visible:
		return
	_paused = not _paused
	_world.get_tree().paused = _paused
	_pause_overlay.visible = _paused
	Game.pause_speaking(_paused)
	_pause_btn.text = ">" if _paused else "II"


func quit() -> void:
	_quit = true
	Game.stop_speaking()
	Synth.set_mood("off")
	get_tree().paused = false
	exited.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_hud_idle = 0.0
	if event.is_action_pressed("ui_cancel"):
		if _end_overlay.visible:
			quit()
		else:
			toggle_pause()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_P]:
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept"):
		_skip = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not _paused:
		_skip = true
		_hud_idle = 0.0
	elif event is InputEventScreenTouch and event.pressed:
		_hud_idle = 0.0


func _process(delta: float) -> void:
	if not _paused:
		_hud_idle += delta
		if _shake > 0.0:
			_shake -= delta
			_cam.offset = Vector2(randf_range(-9, 9), randf_range(-7, 7)) * clampf(_shake * 3.0, 0.0, 1.0)
		else:
			_cam.offset = Vector2.ZERO
	var hud_a := 1.0 if (_hud_idle < 2.5 or _paused) else 0.0
	_hud.modulate.a = move_toward(_hud.modulate.a, hud_a, delta * 4.0)
	# Only touch the bar/label when they change visibly (each redraw costs GPU uploads).
	var prog := snappedf(clampf(_done_time / _total, 0.0, 1.0), 0.002)
	if prog != _progress.value:
		_progress.value = prog
	var tl := "%s / %s" % [UiKit.fmt_time(_done_time), UiKit.fmt_time(_total)]
	if tl != _time_label.text:
		_time_label.text = tl
	# Up next: count down while autoplay is on (it can be switched on or off right here).
	if _end_overlay.visible and on_next.is_valid():
		var txt := "Up next: %s" % next_title
		if Game.autoplay:
			_next_t -= delta
			txt = "Up next in %d: %s" % [ceili(maxf(_next_t, 0.0)), next_title]
			if _next_t <= 0.0:
				_next_label.text = txt
				_play_next()
				return
		else:
			_next_t = AUTOPLAY_DELAY
		if txt != _next_label.text:
			_next_label.text = txt


## Waits `sec` seconds of un-paused time. Returns early when skipping if `skippable`.
func _wait(sec: float, skippable: bool = true) -> void:
	var t := 0.0
	while t < sec and not _quit:
		await get_tree().process_frame
		if _paused:
			continue
		var d := get_process_delta_time()
		t += d
		_done_time += d
		if skippable and _skip:
			break


func _run() -> void:
	_quit = false
	_skip = false
	var pos := {}
	for i in ep.commands.size():
		if _quit:
			return
		_index = i
		var c: Dictionary = ep.commands[i]
		var before := _done_time
		await _exec(c)
		# Keep the progress bar honest even if a command took more/less time than estimated.
		var est := ep.command_duration(c, pos)
		_done_time = maxf(_done_time, before + est * 0.25)
		_skip = false
	if not _quit:
		_done_time = _total
		_next_t = AUTOPLAY_DELAY
		_next_btn.visible = on_next.is_valid()
		_next_label.visible = on_next.is_valid()
		_end_overlay.visible = true


# ------------------------------------------------------------- commands --

func _exec(c: Dictionary) -> void:
	match c.type:
		"scene": await _do_scene(c)
		"place":
			var p := _puppet(c.who)
			p.position = Vector2(c.x, GROUND)
			if c.get("emotion", "") != "":
				p.set_emotion(c.emotion)
			if c.face in ["left", "right"]:
				p.facing = -1 if c.face == "left" else 1
			else:
				_auto_face(p)
		"enter":
			var p := _puppet(c.who)
			p.position = Vector2(EpisodeScript.SPOTS.offleft if c.from == "left" else EpisodeScript.SPOTS.offright, GROUND)
			if c.get("emotion", "") != "":
				p.set_emotion(c.emotion)
			await _walk(p, c.x, c.speed, c.parallel)
		"exit":
			if _cast.has(c.who):
				var p: Puppet = _cast[c.who]
				_cast.erase(c.who)
				var to: float = EpisodeScript.SPOTS.offleft if c.to == "left" else EpisodeScript.SPOTS.offright
				if p.walk_to(to, c.speed) <= 0.0:
					p.queue_free()
					return
				p.finished_move.connect(p.queue_free, CONNECT_ONE_SHOT)
				if not c.parallel:
					await p.finished_move
		"move":
			if _cast.has(c.who):
				await _walk(_cast[c.who], c.x, c.speed, c.parallel)
		"face":
			if _cast.has(c.who):
				var p: Puppet = _cast[c.who]
				if c.target != "" and _cast.has(c.target):
					p.facing = 1 if _cast[c.target].position.x > p.position.x else -1
				else:
					p.facing = -1 if c.dir == "left" else 1
		"emote":
			if _cast.has(c.who):
				_cast[c.who].set_emotion(c.emotion)
		"hold":
			if _cast.has(c.who):
				_cast[c.who].held = "" if c.prop in ["none", "nothing", ""] else c.prop
		"jump":
			if _cast.has(c.who):
				_cast[c.who].hop(60.0, 0.5)
				Synth.sfx("boing")
		"camera": await _do_camera(c)
		"shake":
			_shake = c.time
		"wait":
			await _wait(c.time)
		"sfx":
			Synth.sfx(c.name)
		"music":
			Synth.set_mood(c.mood, c.get("variant", 1))
		"say": await _do_say(c)
		"card": await _do_card([{"text": c.text, "size": 72}], c.text)
		"title":
			Synth.sfx("fanfare")
			await _do_card([
				{"text": "SHLANK PRESENTS", "size": 34, "color": Color.WHITE},
				{"text": ("%s  -  SEASON %d, EPISODE %d" % [ep.series.to_upper(), ep.season, ep.number]) if ep.series != "" else "EPISODE %d" % ep.number, "size": 40, "color": UiKit.PINK},
				{"text": ep.title.to_upper(), "size": 92, "color": UiKit.YELLOW}], "", 4.5, Color("3d8fe0"))
		"end":
			Synth.sfx("fanfare")
			await _do_card([{"text": c.text.to_upper(), "size": 120, "color": UiKit.YELLOW},
				{"text": "Thanks for watching!", "size": 34, "color": Color.WHITE}], "", 4.0, Color("e6452f"))


func _puppet(id: String) -> Puppet:
	if _cast.has(id):
		return _cast[id]
	var p := Puppet.new()
	p.setup(id, Game.characters.get(id, {}))
	_actors.add_child(p)
	_cast[id] = p
	return p


func _walk(p: Puppet, x: float, speed: float, parallel: bool) -> void:
	if p.walk_to(x, speed) <= 0.0:
		_auto_face(p)
		return
	if parallel:
		p.finished_move.connect(func() -> void: _auto_face(p), CONNECT_ONE_SHOT)
		return
	await p.finished_move
	_auto_face(p)


## Turn to face the rest of the cast (or the middle of the stage when alone).
func _auto_face(p: Puppet) -> void:
	if not is_instance_valid(p):
		return
	var sum := 0.0
	var n := 0
	for q in _cast.values():
		if q != p and not q.walking:
			sum += q.position.x
			n += 1
	var target := sum / n if n > 0 else 640.0
	if absf(target - p.position.x) > 10.0:
		p.facing = 1 if target > p.position.x else -1


## The show this episode belongs to (its @series), else the show of the location.
func _show_for(location: String) -> Dictionary:
	var name := ep.series if ep.series != "" else String(Game.locations.get(location, {}).get("show", ""))
	return Game.shows.get(name, {})


## Irises close in on whoever spoke last, like the old cartoons; otherwise centre stage.
func _iris_focus() -> Vector2:
	if _last_speaker != "" and _cast.has(_last_speaker):
		var p: Puppet = _cast[_last_speaker]
		return get_viewport().get_canvas_transform() * (p.global_position + Vector2(0, -150))
	return Vector2(640, 360)


func _do_scene(c: Dictionary) -> void:
	_sub_panel.visible = false
	if not _first_scene and not c.cut:
		# A scene can ask for its own transition; otherwise the show's default.
		var show := _show_for(c.location)
		var style: String = c.get("transition", "")
		var sfx := String(TRANSITION_SFX.get(style, ""))
		if style == "":
			style = String(show.get("transition", "fade"))
			sfx = String(show.get("transition_sfx", ""))
		_wipe.style = style
		_wipe.focus = _iris_focus()
		if sfx != "":
			Synth.sfx(sfx)
		await _wipe.cover()
	for p in _cast.values():
		p.queue_free()
	_cast.clear()
	_backdrop.set_location(c.location)
	_cam.position = Vector2(640, 360)
	_cam.zoom = Vector2.ONE
	if not _first_scene and not c.cut:
		await _wait(0.2, false)
		await _wipe.reveal()
	_first_scene = false
	var loc: Dictionary = Game.locations.get(c.location, {})
	_loc_label.text = String(loc.get("name", c.location))
	var tw := create_tween()
	tw.tween_property(_loc_label, "modulate:a", 1.0, 0.4)
	tw.tween_interval(2.2)
	tw.tween_property(_loc_label, "modulate:a", 0.0, 0.6)


func _do_camera(c: Dictionary) -> void:
	var target := Vector2(640, 360)
	var zoom := Vector2.ONE
	if c.mode != "wide" and _cast.has(c.who):
		var p: Puppet = _cast[c.who]
		var close: bool = c.mode == "close"
		zoom = Vector2.ONE * (1.75 if close else 1.3)
		target = Vector2(p.position.x, GROUND - (200.0 if close else 190.0))
		# Keep the view inside the set.
		var half := Vector2(640, 360) / zoom
		target.x = clampf(target.x, -60 + half.x, 1340 - half.x)
		target.y = clampf(target.y, -60 + half.y, 780 - half.y)
	var tw := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_cam, "position", target, 0.45)
	tw.tween_property(_cam, "zoom", zoom, 0.45)
	await _wait(0.45, false)


func _do_say(c: Dictionary) -> void:
	var who: String = c.who
	var cdata: Dictionary = Game.characters.get(who, {})
	_last_speaker = who
	var p: Puppet = _cast.get(who)
	if p and c.emotion != "":
		p.set_emotion(c.emotion)
	# Listeners look at the speaker.
	if p:
		for q in _cast.values():
			if q != p and not q.walking:
				q.facing = 1 if p.position.x > q.position.x else -1
	var text: String = c.text
	_sub_name.text = String(cdata.get("name", who)).to_upper()
	_sub_name.add_theme_color_override("font_color", Game.char_color(who) if who != "narrator" else UiKit.YELLOW)
	_sub_text.text = text
	_sub_text.visible_ratio = 0.0
	_sub_panel.visible = Game.subtitles
	var est := Game.speak(who, text)
	var mode := Game.effective_voice_mode()
	var reveal := create_tween()
	reveal.tween_property(_sub_text, "visible_ratio", 1.0, maxf(est * 0.8, 0.3))
	var t := 0.0
	var started := false
	while not _quit:
		await get_tree().process_frame
		if _paused:
			continue
		var d := get_process_delta_time()
		t += d
		_done_time += d
		var speaking := Game.is_speaking()
		if speaking:
			started = true
		if p:
			p.talking = speaking if (mode == "tts" and started) else t < est * 0.9
		if _skip:
			break
		if mode == "tts" and started:
			if not speaking:
				break
		elif t >= est:
			break
		if t > est * 3.0 + 4.0:
			break
	if _skip:
		Game.stop_speaking()
	reveal.kill()
	_sub_text.visible_ratio = 1.0
	if p:
		p.talking = false
	_skip = false
	await _wait(EpisodeScript.LINE_GAP, true)
	_sub_panel.visible = false


func _do_card(card_lines: Array, speak: String, hold: float = 0.0, color: Color = Color(0, 0, 0, 0)) -> void:
	_sub_panel.visible = false
	if color.a == 0.0:
		color = CARD_COLORS[_card_i % CARD_COLORS.size()]
		_card_i += 1
	_card.show_card(card_lines, color)
	var t := 0.0
	if speak != "":
		var est := Game.speak("narrator", speak)
		hold = maxf(hold, est + 0.6)
	while t < hold and not _quit:
		await get_tree().process_frame
		if _paused:
			continue
		var d := get_process_delta_time()
		t += d
		_done_time += d
		if _skip:
			break
	if _skip:
		Game.stop_speaking()
		_skip = false
	await _card.hide_card()
