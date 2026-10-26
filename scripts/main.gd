extends Node
## App shell: menus (episodes, cast, locations, settings) and the episode player.

const PROPS := ["none", "golden_spatula", "patty", "net", "clarinet", "detector", "money", "locket", "ice_cream", "fishing_rod", "beeper"]

var _screen: Node
## Everyone with a puppet, in data order (the narrator has no body).
var _cast_order: Array = []
var _location_order: Array = []
var _theme: Theme
var _episodes: Array = []  # [{id, path, origin, text, script}] built-in + the player's own


func _reload_episodes() -> void:
	_episodes.clear()
	for e in Library.entries():
		var sc := EpisodeScript.parse(e.text, Game.characters)
		for err in sc.errors:
			push_warning("%s: %s" % [e.path, err])
		e["script"] = sc
		_episodes.append(e)


func _ready() -> void:
	_theme = UiKit.make_theme()
	for id in Game.characters:
		if Game.characters[id].get("style", "none") != "none":
			_cast_order.append(id)
	_location_order = Game.locations.keys()
	_reload_episodes()
	_setup_perf_overlay()
	_setup_global_controls()
	show_menu()


# ------------------------------------------- always-on controls (top right) --

const GLOBAL_CONTROLS_WIDTH := 140.0  ## screens keep their own top-right UI left of this

var _vol_btn: IconButton
var _full_btn: IconButton
var _vol_popup: PanelContainer
var _vol_slider: VSlider
var _vol_label: Label


func _setup_global_controls() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = _theme
	layer.add_child(root)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	bar.position = Vector2(1280 - 18 - 56 * 2 - 10, 16)
	root.add_child(bar)
	_vol_btn = IconButton.make(IconButton.Icon.VOLUME, Color.WHITE, "Volume")
	_vol_btn.level = Game.master_volume
	_vol_btn.pressed.connect(func() -> void: _vol_popup.visible = not _vol_popup.visible)
	bar.add_child(_vol_btn)
	_full_btn = IconButton.make(IconButton.Icon.FULLSCREEN, Color.WHITE, "Fullscreen")
	_full_btn.pressed.connect(_toggle_fullscreen)
	bar.add_child(_full_btn)

	_vol_popup = PanelContainer.new()
	_vol_popup.add_theme_stylebox_override("panel", UiKit.box(Color.WHITE, 16, 4, 6))
	_vol_popup.position = Vector2(bar.position.x - 2, 82)
	_vol_popup.visible = false
	root.add_child(_vol_popup)
	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 6)
	_vol_popup.add_child(vb)
	_vol_label = UiKit.label("", 18)
	_vol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_vol_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	vb.add_child(_vol_label)
	_vol_slider = VSlider.new()
	_vol_slider.min_value = 0.0
	_vol_slider.max_value = 1.0
	_vol_slider.step = 0.01
	_vol_slider.custom_minimum_size = Vector2(32, 170)
	_vol_slider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_vol_slider.add_theme_stylebox_override("slider", UiKit.box(Color(0.85, 0.9, 0.95), 8, 3, 0))
	_vol_slider.add_theme_stylebox_override("grabber_area", UiKit.box(UiKit.BLUE, 8, 3, 0))
	_vol_slider.add_theme_stylebox_override("grabber_area_highlight", UiKit.box(UiKit.BLUE.lightened(0.2), 8, 3, 0))
	_vol_slider.value = Game.master_volume
	_vol_slider.value_changed.connect(_on_volume)
	vb.add_child(_vol_slider)
	_on_volume(Game.master_volume, false)


func _on_volume(v: float, save: bool = true) -> void:
	Game.master_volume = v
	_vol_btn.level = v
	_vol_label.text = "%d%%" % roundi(v * 100.0)
	Game.apply_settings()
	if save:
		Game.save_settings()


func _toggle_fullscreen() -> void:
	var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)


func _input(event: InputEvent) -> void:
	# Clicking anywhere outside the volume popup closes it.
	if _vol_popup and _vol_popup.visible and event is InputEventMouseButton and event.pressed:
		var p: Vector2 = event.position
		if not _vol_popup.get_global_rect().has_point(p) and not _vol_btn.get_global_rect().has_point(p):
			_vol_popup.visible = false


# ------------------------------------------------------- perf overlay (F3) --

var _perf_label: Label
var _perf_t := 0.0


func _setup_perf_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_perf_label = UiKit.label("", 16, Color.WHITE)
	_perf_label.add_theme_constant_override("outline_size", 5)
	_perf_label.add_theme_color_override("font_outline_color", Art.INK)
	_perf_label.position = Vector2(10, 690)
	_perf_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	layer.add_child(_perf_label)
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	var debug := false
	if OS.has_feature("web"):
		debug = str(JavaScriptBridge.eval("window.location.search")).contains("debug")
	_perf_label.visible = debug


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		_perf_label.visible = not _perf_label.visible


func _process(delta: float) -> void:
	# Keep the fullscreen icon in sync (the browser can leave fullscreen on Esc).
	var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	var kind := IconButton.Icon.EXIT_FULLSCREEN if full else IconButton.Icon.FULLSCREEN
	if _full_btn and _full_btn.icon_kind != kind:
		_full_btn.icon_kind = kind
		_full_btn.tooltip_text = "Exit fullscreen" if full else "Fullscreen"
	if not _perf_label.visible:
		return
	_perf_t -= delta
	if _perf_t > 0.0:
		return
	_perf_t = 0.5
	var vp := get_viewport().get_viewport_rid()
	_perf_label.text = "%d fps | script %.1f ms | render cpu %.1f ms gpu %.1f ms | draw calls %d" % [
		Engine.get_frames_per_second(),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		RenderingServer.viewport_get_measured_render_time_cpu(vp) + RenderingServer.get_frame_setup_time_cpu(),
		RenderingServer.viewport_get_measured_render_time_gpu(vp),
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)]
	if OS.has_feature("web") and str(JavaScriptBridge.eval("window.location.search")).contains("debug"):
		print("PERF ", _perf_label.text)


func _set_screen(n: Node) -> void:
	if _screen:
		_screen.queue_free()
	Game.stop_speaking()
	_screen = n
	add_child(n)


func _screen_root(location: String) -> Control:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.theme = _theme
	var bd := Backdrop.new()
	bd.set_location(location)
	root.add_child(bd)
	root.set_meta("backdrop", bd)
	return root


func _back_button(root: Control, target: Callable = show_menu) -> void:
	var b := UiKit.button("< BACK", UiKit.PINK, 24)
	b.position = Vector2(20, 18)
	b.pressed.connect(target)
	root.add_child(b)


# ----------------------------------------------------------------- menu --

func show_menu() -> void:
	Synth.set_mood("happy")
	var root := _screen_root("title_stage")
	_set_screen(root)
	var logo := UiKit.title_label("SHLANK", 124, UiKit.YELLOW)
	logo.position = Vector2(390, 76)
	logo.size = Vector2(500, 150)
	logo.pivot_offset = Vector2(250, 75)
	root.add_child(logo)
	var tw := logo.create_tween().set_loops()
	tw.tween_property(logo, "rotation", 0.03, 1.2).set_trans(Tween.TRANS_SINE)
	tw.tween_property(logo, "rotation", -0.03, 1.2).set_trans(Tween.TRANS_SINE)
	var sub := UiKit.title_label("CARTOON THEATER", 34, Color.WHITE)
	sub.position = Vector2(390, 200)
	sub.size = Vector2(500, 50)
	root.add_child(sub)
	var box := VBoxContainer.new()
	box.position = Vector2(470, 280)
	box.size = Vector2(340, 300)
	box.add_theme_constant_override("separation", 10)
	root.add_child(box)
	for b in [["WATCH EPISODES", UiKit.YELLOW, show_episodes], ["EDIT / CREATE", Color("f2a65a"), show_library],
			["MEET THE CAST", UiKit.PINK, show_cast_picker], ["LOCATIONS", UiKit.TEAL, show_location_picker],
			["SETTINGS", Color("b48be0"), show_settings]]:
		var btn := UiKit.button(b[0], b[1], 28)
		btn.custom_minimum_size = Vector2(340, 56)
		btn.pressed.connect(b[2])
		box.add_child(btn)
	var hint := UiKit.label("Voices use your browser's speech synthesizer.", 18, Color.WHITE)
	hint.add_theme_constant_override("outline_size", 5)
	hint.add_theme_color_override("font_outline_color", Art.INK)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(340, 626)
	hint.size = Vector2(600, 30)
	root.add_child(hint)


# ------------------------------------------------------------- episodes --

func show_episodes() -> void:
	_reload_episodes()
	var root := _screen_root("theater")
	_set_screen(root)
	_back_button(root)
	var title := UiKit.title_label("EPISODES", 72)
	title.position = Vector2(0, 30)
	title.size = Vector2(1280, 90)
	root.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(200, 130)
	scroll.size = Vector2(880, 500)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 16)
	scroll.add_child(list)
	for e in _episodes:
		var sc: EpisodeScript = e.script
		var card := PanelContainer.new()
		list.add_child(card)
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 18)
		card.add_child(hb)
		hb.add_child(ShowIcon.for_episode(sc, 92.0))
		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hb.add_child(vb)
		vb.add_child(UiKit.label(_series_line(sc, e.origin), 16, UiKit.BLUE))
		var t := UiKit.title_label(sc.title.to_upper(), 34, UiKit.RED)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		vb.add_child(t)
		var d := UiKit.label(sc.description, 20)
		d.custom_minimum_size = Vector2(480, 0)
		vb.add_child(d)
		var meta := UiKit.label("Runtime ~%s" % UiKit.fmt_time(sc.estimate_duration()), 16, Color(0.3, 0.3, 0.35))
		vb.add_child(meta)
		var play := UiKit.button("PLAY", UiKit.YELLOW, 34)
		play.custom_minimum_size = Vector2(150, 80)
		play.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		play.pressed.connect(func() -> void: play_episode(sc))
		hb.add_child(play)
	var more := UiKit.label("Make your own episodes with EDIT / CREATE on the title screen!", 18, Color.WHITE)
	more.add_theme_constant_override("outline_size", 5)
	more.add_theme_color_override("font_outline_color", Art.INK)
	more.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	more.position = Vector2(140, 650)
	more.size = Vector2(1000, 30)
	root.add_child(more)


func _series_line(sc: EpisodeScript, origin: String) -> String:
	var s := ("%s  •  EPISODE %d" % [sc.series.to_upper(), sc.number]) if sc.series != "" else "EPISODE %d" % sc.number
	match origin:
		"mine": s += "  •  MY EPISODE"
		"edited": s += "  •  EDITED"
	return s


func play_episode(sc: EpisodeScript, on_exit: Callable = show_episodes) -> void:
	Synth.set_mood("off")
	var player := EpisodePlayer.new()
	_set_screen(player)
	player.exited.connect(on_exit)
	player.play(sc)


# ---------------------------------------------------------- edit / create --

func show_library() -> void:
	_reload_episodes()
	Synth.set_mood("happy")
	var root := _screen_root("theater")
	_set_screen(root)
	_back_button(root)
	var title := UiKit.title_label("EDIT / CREATE", 64)
	title.position = Vector2(0, 30)
	title.size = Vector2(1280, 80)
	root.add_child(title)
	var actions := HBoxContainer.new()
	actions.position = Vector2(200, 116)
	actions.size = Vector2(880, 56)
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 14)
	root.add_child(actions)
	var new_btn := UiKit.button("+ NEW EPISODE", UiKit.YELLOW, 26)
	new_btn.pressed.connect(func() -> void: _new_episode_dialog(root))
	actions.add_child(new_btn)
	var imp := UiKit.button("IMPORT FROM CLIPBOARD", UiKit.TEAL, 26)
	imp.pressed.connect(func() -> void: _import_dialog(root))
	actions.add_child(imp)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(200, 186)
	scroll.size = Vector2(880, 450)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	for e in _episodes:
		var sc: EpisodeScript = e.script
		var card := PanelContainer.new()
		list.add_child(card)
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 14)
		card.add_child(hb)
		hb.add_child(ShowIcon.for_episode(sc, 64.0))
		var vb := VBoxContainer.new()
		vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		hb.add_child(vb)
		vb.add_child(UiKit.label(_series_line(sc, e.origin), 14, UiKit.BLUE))
		var t := UiKit.title_label(sc.title.to_upper(), 28, UiKit.RED)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		vb.add_child(t)
		var edit := UiKit.button("EDIT", UiKit.YELLOW, 22)
		edit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		edit.pressed.connect(func() -> void:
			var doc := EpisodeDoc.from_script(sc)
			doc.id = e.id
			open_editor(doc))
		hb.add_child(edit)
		var copy := UiKit.button("COPY", UiKit.TEAL, 22)
		copy.tooltip_text = "Copy this episode's script to the clipboard"
		copy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		copy.pressed.connect(func() -> void:
			Library.copy_to_clipboard(e.text)
			UiKit.toast(root, "Copied \"%s\" to the clipboard" % sc.title))
		hb.add_child(copy)
		if e.origin != "built-in":
			var del := UiKit.button("RESET" if e.origin == "edited" else "DELETE", UiKit.RED, 22)
			del.tooltip_text = "Go back to the original" if e.origin == "edited" else "Delete this episode"
			del.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			del.pressed.connect(func() -> void:
				var msg := "Undo your changes to \"%s\"?" % sc.title if e.origin == "edited" else "Delete \"%s\" for good?" % sc.title
				UiKit.modal(root, "ARE YOU SURE?", UiKit.label(msg, 20), [
					["YES", UiKit.RED, func() -> void:
						Library.delete(e.id)
						show_library()],
					["CANCEL", Color.WHITE, Callable()]]))
			hb.add_child(del)


func _new_episode_dialog(root: Control) -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	vb.add_child(UiKit.label("Pick an icon for your episode. You can use characters and locations from any show.", 20))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 12)
	vb.add_child(grid)
	var dialog := []  # holder: lambdas capture by value, so share it through an array
	for ic in ShowIcon.episode_icons():
		var kind: String = ic[0]
		var btn := UiKit.icon_button(kind, ic[1], 96.0)
		btn.pressed.connect(func() -> void:
			dialog[0].queue_free()
			open_editor(EpisodeDoc.new_episode(kind), 0, true))
		grid.add_child(btn)
	dialog.append(UiKit.modal(root, "NEW EPISODE", vb, [["CANCEL", Color.WHITE, Callable()]]))


func _import_dialog(root: Control) -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.add_child(UiKit.label("Paste an episode script below (Ctrl+V / Cmd+V), or use the button to read your clipboard.", 18))
	var te := TextEdit.new()
	te.placeholder_text = "@title My Episode\n@series Hillwood\n..."
	te.custom_minimum_size = Vector2(640, 260)
	vb.add_child(te)
	var status := UiKit.label("", 16, UiKit.RED)
	vb.add_child(status)
	var paste := UiKit.button("PASTE FROM CLIPBOARD", Color.WHITE, 18)
	paste.pressed.connect(func() -> void:
		Library.read_clipboard(func(text: String) -> void:
			if text.strip_edges() == "":
				status.text = "Couldn't read the clipboard - try Ctrl+V in the box instead."
			else:
				te.text = text
				status.text = ""))
	vb.add_child(paste)
	UiKit.modal(root, "IMPORT EPISODE", vb, [
		["IMPORT", UiKit.YELLOW, func() -> Variant:
			var sc := EpisodeScript.parse(te.text, Game.characters)
			if not sc.commands.any(func(c): return c.type == "scene"):
				status.text = "That doesn't look like an episode script (it has no SCENE lines)."
				return false
			var doc := EpisodeDoc.from_script(sc)
			doc.id = Library.new_id(doc.title)
			Library.save(doc.id, doc.to_text())
			var note := "" if sc.errors.is_empty() else " (%d lines skipped)" % sc.errors.size()
			show_library()
			UiKit.toast(_screen, "Imported \"%s\"%s" % [doc.title, note])
			return true],
		["CANCEL", Color.WHITE, Callable()]])


func open_editor(doc: EpisodeDoc, scene_i: int = 0, dirty: bool = false) -> void:
	Synth.set_mood("off")
	var ed := EpisodeEditor.new()
	ed.setup(doc, scene_i, dirty)
	_set_screen(ed)
	ed.exited.connect(show_library)
	ed.test_scene.connect(func(d: EpisodeDoc, si: int) -> void:
		var was_dirty := ed.dirty
		play_episode(EpisodeScript.parse(d.scene_text(si), Game.characters), func() -> void: open_editor(d, si, was_dirty)))
	ed.test_play.connect(func(d: EpisodeDoc, si: int) -> void:
		var was_dirty := ed.dirty
		play_episode(d.to_script(), func() -> void: open_editor(d, si, was_dirty)))


# ----------------------------------------------------------------- cast --

## First step of "Meet the Cast" / "Locations": pick a series.
func _series_picker(heading: String, items: Dictionary, open: Callable) -> void:
	var root := _screen_root("theater")
	_set_screen(root)
	_back_button(root)
	var title := UiKit.title_label(heading, 64)
	title.position = Vector2(0, 30)
	title.size = Vector2(1280, 80)
	root.add_child(title)
	var sub := UiKit.title_label("PICK A SERIES", 28, Color.WHITE)
	sub.position = Vector2(0, 108)
	sub.size = Vector2(1280, 40)
	root.add_child(sub)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	row.position = Vector2(0, 190)
	row.size = Vector2(1280, 320)
	root.add_child(row)
	for show in items:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(224, 300)
		row.add_child(card)
		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.add_theme_constant_override("separation", 8)
		card.add_child(vb)
		var icon := ShowIcon.make(show, 120.0)
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vb.add_child(icon)
		vb.add_child(UiKit.title_label(show.to_upper(), 24, UiKit.RED))
		var count := UiKit.label(items[show], 18, Color(0.35, 0.35, 0.4))
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vb.add_child(count)
		var go := UiKit.button("OPEN", UiKit.YELLOW, 24)
		go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		go.pressed.connect(open.bind(show))
		vb.add_child(go)


func show_cast_picker() -> void:
	var items := {}
	for id in _cast_order:
		var sh: String = Game.characters[id].get("show", "")
		items[sh] = "%d characters" % (_cast_order.filter(func(c): return Game.characters[c].get("show", "") == sh).size())
	_series_picker("MEET THE CAST", items, func(show: String) -> void: show_cast(show, 0))


func show_location_picker() -> void:
	var items := {}
	for show in EpisodeDoc.location_shows():
		items[show] = "%d locations" % EpisodeDoc.locations_of(show).size()
	_series_picker("LOCATIONS", items, func(show: String) -> void: show_locations(show, 0))


func show_cast(show: String = "", index: int = 0) -> void:
	var order := _cast_order.filter(func(c): return show == "" or Game.characters[c].get("show", "") == show)
	index = posmod(index, order.size())
	var id: String = order[index]
	var cdata: Dictionary = Game.characters[id]
	var root := _screen_root(String(cdata.get("home", _location_order[0])))
	_set_screen(root)
	_back_button(root, show_cast_picker)
	var p := Puppet.new()
	p.setup(id, cdata)
	p.position = Vector2(400, 650)
	p.size_scale = 1.35
	root.add_child(p)
	var panel := PanelContainer.new()
	panel.position = Vector2(700, 110)
	panel.custom_minimum_size = Vector2(520, 0)
	root.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	panel.add_child(vb)
	var show_l := UiKit.label("%s  •  %d/%d" % [String(cdata.get("show", "")).to_upper(), index + 1, order.size()], 16, UiKit.BLUE)
	vb.add_child(show_l)
	var name_l := UiKit.title_label(String(cdata.name).to_upper(), 48, Game.char_color(id))
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vb.add_child(name_l)
	var bio := UiKit.label(String(cdata.get("bio", "")), 22)
	bio.custom_minimum_size = Vector2(480, 0)
	vb.add_child(bio)
	var quote := UiKit.label("\"%s\"" % cdata.get("catchphrase", ""), 22, Color(0.35, 0.2, 0.45))
	quote.custom_minimum_size = Vector2(480, 0)
	vb.add_child(quote)
	var voice_name := Game.voice_name_for(id)
	var vl := UiKit.label("Voice: %s" % (voice_name if voice_name != "" else "synth babble"), 16, Color(0.35, 0.35, 0.4))
	vb.add_child(vl)
	var say := UiKit.button("HEAR VOICE", UiKit.YELLOW, 26)
	say.pressed.connect(func() -> void: _cast_say(p, String(cdata.get("catchphrase", "Hello!"))))
	vb.add_child(say)
	var emo := HFlowContainer.new()
	emo.add_theme_constant_override("h_separation", 8)
	emo.add_theme_constant_override("v_separation", 8)
	vb.add_child(emo)
	for e in Puppet.EMOTIONS:
		var b := UiKit.button(e.to_upper(), Color.WHITE, 16)
		b.pressed.connect(func() -> void: p.set_emotion(e))
		emo.add_child(b)
	var props := HFlowContainer.new()
	props.add_theme_constant_override("h_separation", 8)
	vb.add_child(props)
	for pr in PROPS:
		var b := UiKit.button(pr.replace("_", " ").to_upper(), Color("dff1fb"), 14)
		b.pressed.connect(func() -> void: p.held = "" if pr == "none" else pr)
		props.add_child(b)
	_arrows(root, func(d: int) -> void: show_cast(show, index + d))
	var walk := UiKit.button("WALK", UiKit.TEAL, 20)
	walk.position = Vector2(330, 670)
	walk.pressed.connect(func() -> void:
		p.walk_to(560.0 if p.position.x < 450.0 else 260.0, 200.0))
	root.add_child(walk)


func _cast_say(p: Puppet, text: String) -> void:
	var est := Game.speak(p.id, text)
	var mode := Game.effective_voice_mode()
	p.talking = true
	var t := 0.0
	var started := false
	while is_instance_valid(p):
		await get_tree().process_frame
		if not is_instance_valid(p):
			return
		t += get_process_delta_time()
		var sp := Game.is_speaking()
		started = started or sp
		if mode == "tts" and started:
			p.talking = sp
			if not sp:
				break
		elif t >= est:
			break
		if t > est * 3.0 + 3.0:
			break
	if is_instance_valid(p):
		p.talking = false


func _arrows(root: Control, cb: Callable) -> void:
	var l := UiKit.button("<", Color.WHITE, 40)
	l.position = Vector2(20, 320)
	l.pressed.connect(cb.bind(-1))
	root.add_child(l)
	var r := UiKit.button(">", Color.WHITE, 40)
	r.position = Vector2(1200, 320)
	r.pressed.connect(cb.bind(1))
	root.add_child(r)


# ------------------------------------------------------------ locations --

func show_locations(show: String = "", index: int = 0) -> void:
	var order: Array = _location_order if show == "" else EpisodeDoc.locations_of(show)
	index = posmod(index, order.size())
	var id: String = order[index]
	var root := _screen_root(id)
	_set_screen(root)
	_back_button(root, show_location_picker)
	var loc: Dictionary = Game.locations.get(id, {})
	var panel := PanelContainer.new()
	panel.position = Vector2(290, 566)
	panel.custom_minimum_size = Vector2(700, 0)
	root.add_child(panel)
	var vb := VBoxContainer.new()
	panel.add_child(vb)
	var t := UiKit.title_label("%d/%d  %s" % [index + 1, order.size(), String(loc.get("name", id)).to_upper()], 32, UiKit.RED)
	vb.add_child(t)
	var sh := UiKit.label(String(loc.get("show", "")).to_upper(), 16, UiKit.BLUE)
	sh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sh)
	var d := UiKit.label(String(loc.get("description", "")), 20)
	d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(d)
	_arrows(root, func(dd: int) -> void: show_locations(show, index + dd))


# ------------------------------------------------------------- settings --

func show_settings() -> void:
	var root := _screen_root("treedome")
	_set_screen(root)
	_back_button(root)
	Game.refresh_voices()
	var panel := PanelContainer.new()
	panel.position = Vector2(340, 90)
	panel.custom_minimum_size = Vector2(600, 0)
	root.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	panel.add_child(vb)
	vb.add_child(UiKit.title_label("SETTINGS", 54, UiKit.BLUE))

	var modes := ["auto", "tts", "babble", "silent"]
	var mode_names := ["Auto (speech if available)", "Speech synthesizer", "Cartoon babble", "Silent (subtitles only)"]
	var opt := OptionButton.new()
	for i in modes.size():
		opt.add_item(mode_names[i], i)
	opt.selected = maxi(modes.find(Game.voice_mode), 0)
	opt.item_selected.connect(func(i: int) -> void:
		Game.voice_mode = modes[i]
		Game.save_settings())
	vb.add_child(_row("Voices", opt))

	var subs := CheckButton.new()
	subs.button_pressed = Game.subtitles
	subs.toggled.connect(func(on: bool) -> void:
		Game.subtitles = on
		Game.save_settings())
	vb.add_child(_row("Subtitles", subs))

	vb.add_child(_row("Music", _slider(Game.music_volume, func(v: float) -> void:
		Game.music_volume = v
		Game.save_settings())))
	vb.add_child(_row("Voice volume", _slider(Game.voice_volume, func(v: float) -> void:
		Game.voice_volume = v
		Game.save_settings())))

	var n := Game._tts_voices.size()
	var info := UiKit.label("Speech voices found in this browser: %d" % n if n > 0 else
		"No speech voices found in this browser yet - using cartoon babble. (Some browsers load voices after the first click; reopen this page to re-check.)", 18, Color(0.3, 0.3, 0.35))
	info.custom_minimum_size = Vector2(540, 0)
	vb.add_child(info)
	var test := UiKit.button("TEST VOICES", UiKit.YELLOW, 26)
	test.pressed.connect(func() -> void:
		Game.refresh_voices()
		Game.speak("narrator", "Ah, Bikini Bottom. Testing, one, two, three."))
	vb.add_child(test)


func _row(text: String, ctrl: Control) -> HBoxContainer:
	var hb := HBoxContainer.new()
	var l := UiKit.label(text, 24)
	l.custom_minimum_size = Vector2(200, 0)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	hb.add_child(l)
	ctrl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(ctrl)
	return hb


func _slider(value: float, cb: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(300, 30)
	s.value_changed.connect(cb)
	return s
