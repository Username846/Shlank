class_name EpisodeEditor
extends Control
## The in-app episode editor: scenes on the left, a live stage preview in the
## middle (drag characters to move them), the selected beat's settings on the
## right, and the scene's timeline with a scrub bar along the bottom.

signal exited
signal test_play(doc: EpisodeDoc, scene_i: int)
signal test_scene(doc: EpisodeDoc, scene_i: int)

const STAGE_SCALE := 0.52
const STAGE_POS := Vector2(298, 76)
const STAGE_SIZE := Vector2(666, 374)
const GROUND := 612.0
const MOODS := ["happy", "jazz", "tense", "sad", "sneaky", "spooky", "action", "romantic", "off"]
const SFX_NAMES := ["pop", "boing", "gasp", "whoosh", "slam", "splat", "sting", "ding", "cash", "fanfare", "wahwah",
	"drumroll", "sparkle", "chomp", "sizzle", "beep", "detector", "detector_crazy", "clarinet", "squeak", "bubbles", "slide_whistle"]
const PROPS := ["none", "golden_spatula", "patty", "net", "clarinet", "detector", "money", "locket", "ice_cream", "fishing_rod", "beeper"]
const SPEEDS := [["Slow", 150.0], ["Walk", 300.0], ["Run", 520.0]]

var doc: EpisodeDoc
var scene_i := 0
var selected := -1
var playhead := 0.0
var dirty := false

var _playing := false
var _times := PackedFloat32Array()
var _drag_id := ""
var _drag_start := Vector2.ZERO

var _title_edit: LineEdit
var _scene_list: ItemList
var _loc_btn: Button
var _music_btn: Button
var _cut_opt: OptionButton
## See-through copy of a character showing where the selected entrance/walk ends.
var _ghost: Puppet
var _picker: Control
var _preview_row: Button
var _stage: Control
var _world: Node2D
var _backdrop: Backdrop
var _actors: Node2D
var _puppets: Dictionary = {}
var _line_label: Label
var _inspector: VBoxContainer
var _strip: TimelineStrip
var _strip_scroll: ScrollContainer
var _scrub: HSlider
var _time_label: Label
var _play_btn: Button


func setup(p_doc: EpisodeDoc, p_scene: int = 0, p_dirty: bool = false) -> void:
	doc = p_doc
	scene_i = clampi(p_scene, 0, doc.scenes.size() - 1)
	dirty = p_dirty


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiKit.make_theme()
	_build_ui()
	_load_scene(scene_i)


# ------------------------------------------------------------------- layout --

func _panel(r: Rect2) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.box(Color("fffaf0"), 16, 4, 5))
	p.position = r.position
	p.size = r.size
	p.custom_minimum_size = r.size
	add_child(p)
	return p


func _small_button(text: String, color: Color, cb: Callable, size_px: int = 16) -> Button:
	var b := UiKit.button(text, color, size_px)
	if size_px < 18:
		# Compact padding so rows of these fit the side panels.
		for state in ["normal", "hover", "pressed"]:
			var sb: StyleBoxFlat = b.get_theme_stylebox(state).duplicate()
			sb.content_margin_left = 9
			sb.content_margin_right = 9
			sb.content_margin_top = 5
			sb.content_margin_bottom = 5
			b.add_theme_stylebox_override(state, sb)
	if cb.is_valid():
		b.pressed.connect(cb)
	return b


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("2a1430")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Top bar (the right 150px belong to the always-on volume/fullscreen buttons)
	var top := HBoxContainer.new()
	top.position = Vector2(12, 14)
	top.size = Vector2(1110, 52)
	top.add_theme_constant_override("separation", 10)
	add_child(top)
	top.add_child(_small_button("< BACK", UiKit.PINK, _on_back, 20))
	_title_edit = LineEdit.new()
	_title_edit.text = doc.title
	_title_edit.placeholder_text = "Episode name"
	_title_edit.custom_minimum_size = Vector2(250, 48)
	_title_edit.add_theme_font_size_override("font_size", 22)
	_title_edit.text_changed.connect(func(t: String) -> void:
		doc.title = t
		_mark_dirty())
	top.add_child(_title_edit)
	top.add_child(_small_button("INFO", Color.WHITE, _open_info, 20))
	top.add_child(_small_button("SAVE", UiKit.YELLOW, _save, 20))
	top.add_child(_small_button("TEST SCENE", UiKit.TEAL, func() -> void: test_scene.emit(doc, scene_i), 20))
	top.add_child(_small_button("TEST EPISODE", UiKit.TEAL, func() -> void: test_play.emit(doc, scene_i), 20))
	top.add_child(_small_button("EXPORT", Color("b48be0"), _export, 20))

	# Scenes panel
	var left := _panel(Rect2(10, 76, 278, 404))
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 6)
	left.add_child(lv)
	lv.add_child(UiKit.title_label("SCENES", 22, UiKit.RED))
	_scene_list = ItemList.new()
	_scene_list.custom_minimum_size = Vector2(0, 112)
	_scene_list.item_selected.connect(func(i: int) -> void: _load_scene(i))
	lv.add_child(_scene_list)
	var srow := HBoxContainer.new()
	srow.add_theme_constant_override("separation", 4)
	lv.add_child(srow)
	srow.add_child(_small_button("+ ADD", UiKit.YELLOW, _add_scene, 14))
	srow.add_child(_small_button("UP", Color.WHITE, func() -> void: _move_scene(-1), 14))
	srow.add_child(_small_button("DOWN", Color.WHITE, func() -> void: _move_scene(1), 14))
	srow.add_child(_small_button("DEL", UiKit.RED, _delete_scene, 14))
	for b in srow.get_children():
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# One labelled row per setting. Location and Music open picker windows.
	_loc_btn = _picker_button(_open_location_picker)
	lv.add_child(_setting_row("Location", _loc_btn))
	_music_btn = _picker_button(_open_music_picker)
	lv.add_child(_setting_row("Music", _music_btn))
	_cut_opt = _compact_option()
	_cut_opt.add_item("Show default")
	_cut_opt.add_item("Cut")
	for t in EpisodeScript.TRANSITIONS:
		_cut_opt.add_item(_transition_name(t))
	lv.add_child(_setting_row("Transition", _cut_opt))
	_cut_opt.item_selected.connect(func(i: int) -> void:
		var sc: Dictionary = doc.scenes[scene_i]
		sc.cut = i == 1
		sc.transition = EpisodeScript.TRANSITIONS[i - 2] if i >= 2 else ""
		_mark_dirty())

	# Stage preview
	_stage = Control.new()
	_stage.position = STAGE_POS
	_stage.size = STAGE_SIZE
	_stage.clip_contents = true
	_stage.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_stage.gui_input.connect(_on_stage_input)
	add_child(_stage)
	_world = Node2D.new()
	_world.scale = Vector2.ONE * STAGE_SCALE
	_stage.add_child(_world)
	_backdrop = Backdrop.new()
	_world.add_child(_backdrop)
	_actors = Node2D.new()
	_actors.y_sort_enabled = true
	_world.add_child(_actors)
	var frame := Panel.new()
	frame.add_theme_stylebox_override("panel", _frame_box())
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(frame)
	_line_label = UiKit.label("", 16, Color.WHITE)
	_line_label.add_theme_constant_override("outline_size", 6)
	_line_label.add_theme_color_override("font_outline_color", Art.INK)
	_line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_line_label.position = Vector2(20, STAGE_SIZE.y - 64)
	_line_label.size = Vector2(STAGE_SIZE.x - 40, 56)
	_line_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_line_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_line_label)
	var hint := UiKit.label("Drag characters to move them at this moment", 13, Color(1, 1, 1, 0.85))
	hint.add_theme_constant_override("outline_size", 4)
	hint.add_theme_color_override("font_outline_color", Art.INK)
	hint.autowrap_mode = TextServer.AUTOWRAP_OFF
	hint.position = Vector2(12, 8)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(hint)

	# Beat inspector
	var right := _panel(Rect2(974, 76, 296, 404))
	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 6)
	right.add_child(rv)
	var add := MenuButton.new()
	add.text = "+ ADD BEAT"
	add.add_theme_font_override("font", UiKit.TITLE_FONT)
	add.add_theme_font_size_override("font_size", 20)
	add.flat = false
	var pop := add.get_popup()
	for i in _beat_templates().size():
		pop.add_item(_beat_templates()[i][0], i)
	pop.id_pressed.connect(func(i: int) -> void: _insert_beat(_beat_templates()[i][1].call()))
	rv.add_child(add)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rv.add_child(scroll)
	_inspector = VBoxContainer.new()
	_inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inspector.add_theme_constant_override("separation", 6)
	scroll.add_child(_inspector)

	# Timeline + scrubber
	var bottom := _panel(Rect2(10, 488, 1260, 222))
	var bv := VBoxContainer.new()
	bv.add_theme_constant_override("separation", 6)
	bottom.add_child(bv)
	var brow := HBoxContainer.new()
	brow.add_theme_constant_override("separation", 8)
	bv.add_child(brow)
	brow.add_child(UiKit.title_label("TIMELINE", 22, UiKit.RED))
	brow.add_child(_small_button("|<", Color.WHITE, func() -> void: _step_beat(-1), 16))
	_play_btn = _small_button(">", UiKit.YELLOW, _toggle_play, 16)
	_play_btn.tooltip_text = "Preview the scene's movement"
	brow.add_child(_play_btn)
	brow.add_child(_small_button(">|", Color.WHITE, func() -> void: _step_beat(1), 16))
	_time_label = UiKit.label("", 16, Art.INK)
	_time_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	brow.add_child(_time_label)
	var tips := UiKit.label("Click a beat to edit it  •  click or drag the strip to move the playhead", 14, Color(0.4, 0.4, 0.45))
	tips.autowrap_mode = TextServer.AUTOWRAP_OFF
	tips.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tips.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	brow.add_child(tips)
	_strip_scroll = ScrollContainer.new()
	_strip_scroll.custom_minimum_size = Vector2(0, 118)
	_strip_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bv.add_child(_strip_scroll)
	_strip = TimelineStrip.new()
	_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_strip.beat_clicked.connect(_select_beat)
	_strip.seek.connect(func(t: float) -> void:
		_playing = false
		if selected != -1:
			selected = -1
			_build_inspector()
		_set_playhead(t))
	_strip_scroll.add_child(_strip)
	_scrub = HSlider.new()
	_scrub.step = 0.05
	_scrub.custom_minimum_size = Vector2(0, 26)
	_scrub.tooltip_text = "Scrub through the scene"
	_scrub.add_theme_stylebox_override("slider", UiKit.box(Color("e8dccb"), 8, 3, 0))
	_scrub.add_theme_stylebox_override("grabber_area", UiKit.box(UiKit.RED.lightened(0.2), 8, 3, 0))
	_scrub.add_theme_stylebox_override("grabber_area_highlight", UiKit.box(UiKit.RED.lightened(0.35), 8, 3, 0))
	_scrub.value_changed.connect(func(v: float) -> void:
		_playing = false
		_set_playhead(v))
	bv.add_child(_scrub)


func _setting_row(text: String, ctrl: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	var l := UiKit.label(text, 14, Color(0.35, 0.35, 0.4))
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.custom_minimum_size = Vector2(68, 0)
	row.add_child(l)
	ctrl.add_theme_font_size_override("font_size", 15)
	ctrl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ctrl.custom_minimum_size = Vector2(0, 38)
	row.add_child(ctrl)
	return row


## Dropdowns normally grow to fit their longest option, which would stretch the side panels.
func _compact_option() -> OptionButton:
	var o := OptionButton.new()
	o.fit_to_longest_item = false
	o.clip_text = true
	return o


func _frame_box() -> StyleBoxFlat:
	var b := UiKit.box(Color(0, 0, 0, 0), 12, 4, 0)
	b.draw_center = false
	return b


# ------------------------------------------------------------------ scenes --

func _load_scene(i: int) -> void:
	scene_i = clampi(i, 0, doc.scenes.size() - 1)
	selected = -1
	playhead = 0.0
	_playing = false
	for p in _puppets.values():
		p.queue_free()
	_puppets.clear()
	var sc: Dictionary = doc.scenes[scene_i]
	_backdrop.set_location(sc.location)
	_update_scene_buttons()
	var tr: String = sc.get("transition", "")
	_cut_opt.select(1 if sc.cut else (EpisodeScript.TRANSITIONS.find(tr) + 2 if tr != "" else 0))
	_refresh_scene_list()
	_refresh(true)


func _refresh_scene_list() -> void:
	_scene_list.clear()
	for i in doc.scenes.size():
		var sc: Dictionary = doc.scenes[i]
		_scene_list.add_item("%d. %s" % [i + 1, String(Game.locations.get(sc.location, {}).get("name", sc.location))])
	_scene_list.select(scene_i)


func _add_scene() -> void:
	var loc: String = doc.scenes[scene_i].location
	doc.scenes.insert(scene_i + 1, {"location": loc, "cut": false, "beats": []})
	_mark_dirty()
	_load_scene(scene_i + 1)


func _delete_scene() -> void:
	if doc.scenes.size() <= 1:
		UiKit.toast(self, "An episode needs at least one scene")
		return
	UiKit.modal(self, "DELETE SCENE %d?" % (scene_i + 1), UiKit.label("Its %d beats will be removed." % doc.scenes[scene_i].beats.size(), 20),
		[["DELETE", UiKit.RED, func() -> void:
			doc.scenes.remove_at(scene_i)
			_mark_dirty()
			_load_scene(mini(scene_i, doc.scenes.size() - 1))], ["CANCEL", Color.WHITE, Callable()]])


func _move_scene(d: int) -> void:
	var j := scene_i + d
	if j < 0 or j >= doc.scenes.size():
		return
	var tmp = doc.scenes[j]
	doc.scenes[j] = doc.scenes[scene_i]
	doc.scenes[scene_i] = tmp
	_mark_dirty()
	_load_scene(j)


func _picker_button(cb: Callable) -> Button:
	var b := Button.new()
	b.clip_text = true
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_stylebox_override("normal", UiKit.box(Color.WHITE, 12, 3, 0))
	b.add_theme_stylebox_override("hover", UiKit.box(Color("fff3c4"), 12, 3, 0))
	b.add_theme_stylebox_override("pressed", UiKit.box(Color("f6df4c"), 12, 3, 0))
	b.pressed.connect(cb)
	return b


static func _transition_name(t: String) -> String:
	return {"bubbles": "Bubble wipe", "iris": "Iris", "star": "Star wipe", "heart": "Heart iris",
		"slide": "Slide", "checker": "Checkerboard", "pinwheel": "Pinwheel", "fade": "Fade"}.get(t, t.capitalize())


func _update_scene_buttons() -> void:
	var lid: String = doc.scenes[scene_i].location
	_loc_btn.text = String(Game.locations.get(lid, {}).get("name", lid)) + "  >"
	_loc_btn.tooltip_text = "%s (%s)" % [_loc_btn.text, Game.locations.get(lid, {}).get("show", "")]
	var music := _scene_music()
	_music_btn.text = ("(keep playing)" if music.is_empty() else _music_name(music.mood, music.get("variant", 1))) + "  >"


# ------------------------------------------------------- picker windows --

## Thumbnails of every location, one section per series.
func _open_location_picker() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(900, 470)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 10)
	scroll.add_child(vb)
	var current: String = doc.scenes[scene_i].location
	for show in EpisodeDoc.location_shows():
		var head := HBoxContainer.new()
		head.add_theme_constant_override("separation", 10)
		head.add_child(ShowIcon.make(show, 40.0))
		head.add_child(UiKit.title_label(show.to_upper(), 26, UiKit.RED))
		vb.add_child(head)
		var grid := GridContainer.new()
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		vb.add_child(grid)
		for lid in EpisodeDoc.locations_of(show):
			grid.add_child(_location_tile(lid, lid == current))
	_picker = UiKit.modal(self, "CHOOSE A LOCATION", scroll, [["CANCEL", Color.WHITE, Callable()]])


func _location_tile(lid: String, is_current: bool) -> Button:
	var tile := Button.new()
	tile.custom_minimum_size = Vector2(208, 146)
	tile.focus_mode = Control.FOCUS_NONE
	tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var col := UiKit.YELLOW if is_current else Color.WHITE
	tile.add_theme_stylebox_override("normal", UiKit.box(col, 12, 3 if not is_current else 5, 0))
	tile.add_theme_stylebox_override("hover", UiKit.box(Color("fff3c4"), 12, 4, 0))
	tile.add_theme_stylebox_override("pressed", UiKit.box(UiKit.YELLOW, 12, 4, 0))
	var pic := TextureRect.new()
	pic.position = Vector2(8, 8)
	pic.size = Vector2(192, 108)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(pic)
	_load_thumb(pic, lid)
	var l := UiKit.label(String(Game.locations.get(lid, {}).get("name", lid)), 14, Art.INK)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.clip_text = true
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(4, 118)
	l.size = Vector2(200, 22)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(l)
	tile.pressed.connect(func() -> void:
		_set_location(lid)
		if is_instance_valid(_picker):
			_picker.queue_free())
	return tile


## Portraits of every character, one section per series. Calls `on_pick` with the chosen id.
func _open_character_picker(current: String, with_narrator: bool, on_pick: Callable) -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(900, 470)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 10)
	scroll.add_child(vb)
	if with_narrator:
		var nb := UiKit.button("NARRATOR", UiKit.YELLOW if current == "narrator" else Color.WHITE, 18)
		nb.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		nb.pressed.connect(_pick_character.bind("narrator", on_pick))
		vb.add_child(nb)
	for show in EpisodeDoc.character_shows():
		var head := HBoxContainer.new()
		head.add_theme_constant_override("separation", 10)
		head.add_child(ShowIcon.make(show, 40.0))
		head.add_child(UiKit.title_label(show.to_upper(), 26, UiKit.RED))
		vb.add_child(head)
		var grid := GridContainer.new()
		grid.columns = 6
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		vb.add_child(grid)
		for cid in EpisodeDoc.characters_of(show):
			grid.add_child(_character_tile(cid, cid == current, on_pick))
	_picker = UiKit.modal(self, "CHOOSE A CHARACTER", scroll, [["CANCEL", Color.WHITE, Callable()]])


func _character_tile(cid: String, is_current: bool, on_pick: Callable) -> Button:
	var tile := Button.new()
	tile.custom_minimum_size = Vector2(136, 176)
	tile.focus_mode = Control.FOCUS_NONE
	tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var col := UiKit.YELLOW if is_current else Color.WHITE
	tile.add_theme_stylebox_override("normal", UiKit.box(col, 12, 3 if not is_current else 5, 0))
	tile.add_theme_stylebox_override("hover", UiKit.box(Color("fff3c4"), 12, 4, 0))
	tile.add_theme_stylebox_override("pressed", UiKit.box(UiKit.YELLOW, 12, 4, 0))
	var pic := TextureRect.new()
	pic.position = Vector2(8, 6)
	pic.size = Vector2(120, 142)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	pic.material = mat
	tile.add_child(pic)
	_load_portrait(pic, cid)
	var l := UiKit.label(TimelineStrip.char_name(cid), 14, Art.INK)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.clip_text = true
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(4, 148)
	l.size = Vector2(128, 22)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(l)
	tile.pressed.connect(_pick_character.bind(cid, on_pick))
	return tile


func _pick_character(cid: String, on_pick: Callable) -> void:
	if is_instance_valid(_picker):
		_picker.queue_free()
	on_pick.call(cid)


func _load_portrait(pic: TextureRect, cid: String) -> void:
	var tex: Texture2D = await Puppet.make_portrait(self, cid)
	if is_instance_valid(pic) and tex:
		pic.texture = tex


func _load_thumb(pic: TextureRect, lid: String) -> void:
	var tex: Texture2D = await Backdrop.make_thumbnail(self, lid)
	if is_instance_valid(pic) and tex:
		pic.texture = tex


## Every tune, each with a preview button.
func _open_music_picker() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(560, 450)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 6)
	scroll.add_child(vb)
	var music := _scene_music()
	vb.add_child(_music_row("(keep playing)", "", 0, music.is_empty()))
	for m in MOODS:
		if m == "off":
			continue
		vb.add_child(UiKit.title_label(m.to_upper(), 22, UiKit.RED))
		for v in [1, 2, 3]:
			var cur: bool = not music.is_empty() and music.mood == m and music.get("variant", 1) == v
			vb.add_child(_music_row(_music_name(m, v), m, v, cur))
	vb.add_child(UiKit.title_label("SILENCE", 22, UiKit.RED))
	vb.add_child(_music_row("Off (silence)", "off", 1, not music.is_empty() and music.mood == "off"))
	_picker = UiKit.modal(self, "CHOOSE MUSIC", scroll, [["CANCEL", Color.WHITE, func() -> void: _stop_preview()]])


func _music_row(text: String, mood: String, v: int, is_current: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.box(UiKit.YELLOW if is_current else Color.WHITE, 10, 3, 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	var l := UiKit.label(text + ("   (current)" if is_current else ""), 18, Art.INK)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	if mood != "" and mood != "off":
		var prev := _small_button("PREVIEW", UiKit.TEAL, Callable(), 14)
		prev.pressed.connect(func() -> void: _toggle_preview(prev, mood, v))
		row.add_child(prev)
	row.add_child(_small_button("USE", UiKit.YELLOW, func() -> void:
		_stop_preview()
		_set_scene_music(mood, v)
		if is_instance_valid(_picker):
			_picker.queue_free(), 14))
	return panel


func _toggle_preview(btn: Button, mood: String, v: int) -> void:
	if _preview_row == btn:
		_stop_preview()
		return
	_stop_preview()
	_preview_row = btn
	btn.text = "STOP"
	Synth.set_mood(mood, v)


func _stop_preview() -> void:
	if is_instance_valid(_preview_row):
		_preview_row.text = "PREVIEW"
	_preview_row = null
	Synth.set_mood("off")


func _set_location(lid: String) -> void:
	doc.scenes[scene_i].location = lid
	_backdrop.set_location(lid)
	_refresh_scene_list()
	_update_scene_buttons()
	_mark_dirty()


static func _music_name(mood: String, v: int) -> String:
	return "Off (silence)" if mood == "off" else "%s %d" % [mood.capitalize(), v]


func _scene_music() -> Dictionary:
	for b in doc.scenes[scene_i].beats:
		if b.type == "music":
			return b
	return {}


## Sets (or removes, for mood "") the music that starts the current scene.
func _set_scene_music(mood: String, v: int) -> void:
	var beats: Array = doc.scenes[scene_i].beats
	var idx := -1
	for k in beats.size():
		if beats[k].type == "music":
			idx = k
			break
	if mood == "":
		if idx >= 0:
			beats.remove_at(idx)
	elif idx >= 0:
		beats[idx].mood = mood
		beats[idx].variant = v
	else:
		beats.insert(0, {"type": "music", "mood": mood, "variant": v})
	selected = -1
	_update_scene_buttons()
	_mark_dirty()
	_refresh(true)


# ------------------------------------------------------------------- beats --

func _beat_templates() -> Array:
	return [
		["Dialogue line", func() -> Dictionary: return {"type": "say", "who": _default_who(), "emotion": "", "text": "Type the line here."}],
		["Narration", func() -> Dictionary: return {"type": "say", "who": "narrator", "emotion": "", "text": "Meanwhile..."}],
		["Character enters", func() -> Dictionary: return {"type": "enter", "who": _default_who(true), "from": "left", "x": 640.0, "speed": 300.0, "emotion": "", "parallel": false}],
		["Character exits", func() -> Dictionary: return {"type": "exit", "who": _default_who(), "to": "right", "speed": 300.0, "parallel": false}],
		["Walk to a spot", func() -> Dictionary: return {"type": "move", "who": _default_who(), "x": 640.0, "speed": 300.0, "parallel": false}],
		["Put on stage", func() -> Dictionary: return {"type": "place", "who": _default_who(true), "x": 640.0, "face": "", "emotion": ""}],
		["Change emotion", func() -> Dictionary: return {"type": "emote", "who": _default_who(), "emotion": "happy"}],
		["Hold a prop", func() -> Dictionary: return {"type": "hold", "who": _default_who(), "prop": "locket"}],
		["Turn around", func() -> Dictionary: return {"type": "face", "who": _default_who(), "dir": "left", "target": ""}],
		["Jump", func() -> Dictionary: return {"type": "jump", "who": _default_who()}],
		["Camera close-up", func() -> Dictionary: return {"type": "camera", "mode": "close", "who": _default_who()}],
		["Camera wide shot", func() -> Dictionary: return {"type": "camera", "mode": "wide", "who": ""}],
		["Screen shake", func() -> Dictionary: return {"type": "shake", "time": 0.5}],
		["Pause", func() -> Dictionary: return {"type": "wait", "time": 1.0}],
		["Sound effect", func() -> Dictionary: return {"type": "sfx", "name": "pop"}],
		["Change music", func() -> Dictionary: return {"type": "music", "mood": "happy"}],
		["Text card", func() -> Dictionary: return {"type": "card", "text": "Meanwhile..."}],
		["Episode title card", func() -> Dictionary: return {"type": "title"}],
		["The End card", func() -> Dictionary: return {"type": "end", "text": "The End"}],
	]


## Who a new beat is about: someone on stage now, else the show's first character.
## `offstage` prefers someone who isn't on stage yet (for entrances).
func _default_who(offstage: bool = false) -> String:
	var st := doc.state_at(scene_i, playhead)
	var cast := doc.show_characters()
	for cid in cast:
		var on: bool = st.has(cid) and st[cid].visible
		if on != offstage:
			return cid
	return cast[0]


func _insert_index() -> int:
	if selected >= 0:
		return selected + 1
	var idx := 0
	for i in _times.size() - 1:
		if _times[i] <= playhead + 0.001:
			idx = i + 1
	return idx


func _insert_beat(b: Dictionary) -> void:
	var idx := _insert_index()
	doc.scenes[scene_i].beats.insert(idx, b)
	selected = idx
	_mark_dirty()
	_times = doc.beat_times(scene_i)
	playhead = _times[idx]
	_refresh(true)


func _select_beat(i: int) -> void:
	_playing = false
	selected = i
	_set_playhead(_times[i], false)
	_build_inspector()


func _delete_beat() -> void:
	if selected < 0:
		return
	doc.scenes[scene_i].beats.remove_at(selected)
	selected = -1
	_mark_dirty()
	_refresh(true)


func _shift_beat(d: int) -> void:
	var beats: Array = doc.scenes[scene_i].beats
	var j := selected + d
	if selected < 0 or j < 0 or j >= beats.size():
		return
	var tmp = beats[j]
	beats[j] = beats[selected]
	beats[selected] = tmp
	selected = j
	_mark_dirty()
	_times = doc.beat_times(scene_i)
	playhead = _times[j]
	_refresh(true)


func _step_beat(d: int) -> void:
	_playing = false
	if _times.size() <= 1:
		return
	var n := _times.size() - 1
	var i := selected
	if i < 0:
		i = 0
		for k in n:
			if _times[k] <= playhead + 0.001:
				i = k
		if d < 0 and _times[i] < playhead - 0.001:
			d = 0
	_select_beat(clampi(i + d, 0, n - 1))


# --------------------------------------------------------------- inspector --

func _build_inspector() -> void:
	for c in _inspector.get_children():
		c.queue_free()
	if selected < 0 or selected >= doc.scenes[scene_i].beats.size():
		_build_cast_palette()
		return
	var b: Dictionary = doc.scenes[scene_i].beats[selected]
	_inspector.add_child(UiKit.title_label(TimelineStrip.beat_label(b).get_slice(":", 0).to_upper().left(22), 18, UiKit.BLUE))
	match b.type:
		"say":
			_char_field(b, true)
			_choice_field("Emotion", b, "emotion", [["(no change)", ""]] + _pairs(Puppet.EMOTIONS))
			_inspector.add_child(UiKit.label("Line", 15, Color(0.35, 0.35, 0.4)))
			var te := TextEdit.new()
			te.text = b.text
			te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
			te.custom_minimum_size = Vector2(0, 96)
			te.text_changed.connect(func() -> void:
				b.text = te.text.replace("\n", " ")
				_mark_dirty()
				_refresh(false))
			_inspector.add_child(te)
		"enter":
			_char_field(b)
			_emotion_field(b)
			_choice_field("Comes in from", b, "from", [["Left", "left"], ["Right", "right"]])
			_position_field(b)
			_speed_field(b)
			_parallel_field(b)
		"exit":
			_char_field(b)
			_choice_field("Leaves to the", b, "to", [["Left", "left"], ["Right", "right"]])
			_speed_field(b)
			_parallel_field(b)
		"move":
			_char_field(b)
			_position_field(b)
			_speed_field(b)
			_parallel_field(b)
		"place":
			_char_field(b)
			_emotion_field(b)
			_position_field(b)
			_choice_field("Facing", b, "face", [["Automatic", ""], ["Left", "left"], ["Right", "right"]])
		"face":
			_char_field(b)
			_choice_field("Direction", b, "dir", [["Left", "left"], ["Right", "right"]])
		"emote":
			_char_field(b)
			_choice_field("Emotion", b, "emotion", _pairs(Puppet.EMOTIONS))
		"hold":
			_char_field(b)
			_choice_field("Prop", b, "prop", _pairs(PROPS))
		"jump":
			_char_field(b)
		"camera":
			_choice_field("Shot", b, "mode", [["Wide", "wide"], ["Medium", "medium"], ["Close-up", "close"]])
			if b.mode != "wide":
				_char_field(b)
		"shake", "wait":
			_number_field("Seconds", b, "time", 0.1, 10.0)
		"sfx":
			_choice_field("Sound", b, "name", _pairs(SFX_NAMES))
			_inspector.add_child(_small_button("PLAY SOUND", Color.WHITE, func() -> void: Synth.sfx(b.name), 14))
		"music":
			if not b.has("variant"):
				b.variant = 1
			_choice_field("Mood", b, "mood", _pairs(MOODS))
			if b.mood != "off":
				_choice_field("Variant", b, "variant", [["Variant 1", 1], ["Variant 2", 2], ["Variant 3", 3]])
			var prow := HBoxContainer.new()
			prow.add_theme_constant_override("separation", 6)
			prow.add_child(_small_button("PREVIEW", Color.WHITE, func() -> void: Synth.set_mood(b.mood, b.variant), 14))
			prow.add_child(_small_button("STOP", Color.WHITE, func() -> void: Synth.set_mood("off"), 14))
			_inspector.add_child(prow)
		"card", "end":
			_inspector.add_child(UiKit.label("Text", 15, Color(0.35, 0.35, 0.4)))
			var le := LineEdit.new()
			le.text = b.get("text", "")
			le.text_changed.connect(func(t: String) -> void:
				b.text = t
				_mark_dirty()
				_refresh(false))
			_inspector.add_child(le)
		"title":
			_inspector.add_child(UiKit.label("Shows the episode's name, series and number.", 15))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.add_child(_small_button("EARLIER", Color.WHITE, func() -> void: _shift_beat(-1), 13))
	row.add_child(_small_button("LATER", Color.WHITE, func() -> void: _shift_beat(1), 13))
	row.add_child(_small_button("DELETE", UiKit.RED, _delete_beat, 13))
	_inspector.add_child(row)


func _build_cast_palette() -> void:
	_inspector.add_child(UiKit.label("Pick a beat on the timeline to edit it, or add one with + ADD BEAT.", 15))
	var put := UiKit.button("PUT ON STAGE...", UiKit.TEAL, 16)
	put.pressed.connect(func() -> void:
		_open_character_picker("", false, func(cid: String) -> void:
			var st := doc.state_at(scene_i, playhead)
			if st.has(cid) and st[cid].visible:
				UiKit.toast(self, "Already on stage - drag them to move")
			else:
				_insert_beat({"type": "place", "who": cid, "x": 640.0, "face": ""})))
	_inspector.add_child(put)


func _pairs(values: Array) -> Array:
	return values.map(func(v): return [String(v).replace("_", " ").capitalize(), v])


func _choice_field(label: String, b: Dictionary, key: String, options: Array) -> OptionButton:
	_inspector.add_child(UiKit.label(label, 15, Color(0.35, 0.35, 0.4)))
	var opt := _compact_option()
	for i in options.size():
		opt.add_item(options[i][0])
		if options[i][1] == b.get(key, ""):
			opt.select(i)
	opt.item_selected.connect(func(i: int) -> void:
		b[key] = options[i][1]
		_mark_dirty()
		_refresh(key == "mode"))
	_inspector.add_child(opt)
	return opt


## The beat's character: a button that opens the character window.
func _char_field(b: Dictionary, with_narrator: bool = false) -> void:
	_inspector.add_child(UiKit.label("Character", 15, Color(0.35, 0.35, 0.4)))
	var btn := _picker_button(func() -> void:
		_open_character_picker(b.who, with_narrator, func(cid: String) -> void:
			b.who = cid
			_mark_dirty()
			_refresh(true)))
	btn.text = TimelineStrip.char_name(b.who) + "  >"
	btn.tooltip_text = String(Game.characters.get(b.who, {}).get("show", ""))
	_inspector.add_child(btn)


func _emotion_field(b: Dictionary) -> void:
	if not b.has("emotion"):
		b.emotion = ""
	_choice_field("Emotion", b, "emotion", [["(as before)", ""]] + _pairs(Puppet.EMOTIONS))


func _position_field(b: Dictionary) -> void:
	var lbl := UiKit.label("", 15, Color(0.35, 0.35, 0.4))
	_inspector.add_child(lbl)
	var s := HSlider.new()
	s.min_value = 40
	s.max_value = 1240
	s.step = 10
	s.value = b.x
	var show_pos := func(v: float) -> void: lbl.text = "Position: %s" % EpisodeDoc._spot_name(v)
	show_pos.call(b.x)
	s.value_changed.connect(func(v: float) -> void:
		b.x = v
		show_pos.call(v)
		_mark_dirty()
		_refresh(false))
	_inspector.add_child(s)


func _speed_field(b: Dictionary) -> void:
	var opts := SPEEDS.duplicate()
	if not opts.any(func(o): return absf(o[1] - b.speed) < 1.0):
		opts.append(["Speed %d" % int(b.speed), b.speed])
	_choice_field("Speed", b, "speed", opts)


func _parallel_field(b: Dictionary) -> void:
	var cb := CheckBox.new()
	cb.text = "Next beat starts right away"
	cb.add_theme_font_size_override("font_size", 14)
	cb.button_pressed = b.get("parallel", false)
	cb.toggled.connect(func(on: bool) -> void:
		b.parallel = on
		_mark_dirty()
		_refresh(false))
	_inspector.add_child(cb)


func _number_field(label: String, b: Dictionary, key: String, lo: float, hi: float) -> void:
	_inspector.add_child(UiKit.label(label, 15, Color(0.35, 0.35, 0.4)))
	var sp := SpinBox.new()
	sp.min_value = lo
	sp.max_value = hi
	sp.step = 0.1
	sp.value = b[key]
	sp.value_changed.connect(func(v: float) -> void:
		b[key] = v
		_mark_dirty()
		_refresh(false))
	_inspector.add_child(sp)


# ------------------------------------------------------------------ preview --

func _refresh(rebuild_inspector: bool) -> void:
	_times = doc.beat_times(scene_i)
	var length: float = _times[_times.size() - 1]
	playhead = clampf(playhead, 0.0, length)
	_strip.doc = doc
	_strip.scene_i = scene_i
	_strip.selected = selected
	_strip.refresh()
	_scrub.max_value = maxf(length, 0.1)
	_scrub.set_value_no_signal(playhead)
	_update_preview()
	if rebuild_inspector:
		_build_inspector()


func _set_playhead(t: float, keep_visible: bool = true) -> void:
	playhead = clampf(t, 0.0, _times[_times.size() - 1])
	_scrub.set_value_no_signal(playhead)
	_strip.playhead = playhead
	_strip.selected = selected
	_strip.queue_redraw()
	if keep_visible:
		var x := _strip.time_to_x(playhead)
		var view := _strip_scroll.size.x
		if x < _strip_scroll.scroll_horizontal + 40 or x > _strip_scroll.scroll_horizontal + view - 40:
			_strip_scroll.scroll_horizontal = int(maxf(x - view * 0.3, 0.0))
	_update_preview()


func _update_preview() -> void:
	var st := doc.state_at(scene_i, playhead)
	var line: Dictionary = st.get("_line", {})
	for cid in st:
		if cid == "_line":
			continue
		var s: Dictionary = st[cid]
		var p: Puppet = _puppets.get(cid)
		if p == null:
			p = Puppet.new()
			p.setup(cid, Game.characters.get(cid, {}))
			_actors.add_child(p)
			_puppets[cid] = p
		p.visible = s.visible
		if cid != _drag_id:
			p.position = Vector2(s.x, GROUND)
		p.facing = s.facing
		if p.emotion != s.emotion:
			p.emotion = s.emotion
			p._redraw_now()
		if p.held != s.held:
			p.held = s.held
		p.walking = _playing and s.walking
		p.talking = _playing and not line.is_empty() and line.who == cid
	for cid in _puppets:
		if not st.has(cid):
			_puppets[cid].visible = false
	if line.is_empty():
		_line_label.text = ""
	else:
		_line_label.text = "%s: %s" % [TimelineStrip.char_name(line.who), line.text]
	_update_ghost(st)
	_strip.playhead = playhead
	_strip.queue_redraw()
	_time_label.text = "%s / %s" % [_fmt(playhead), _fmt(_times[_times.size() - 1])]


## While an entrance or walk is selected, a see-through copy of the character
## stands where they'll end up (and can be dragged to change it).
func _update_ghost(st: Dictionary) -> void:
	var beats: Array = doc.scenes[scene_i].beats
	var b: Dictionary = beats[selected] if selected >= 0 and selected < beats.size() else {}
	if b.is_empty() or not b.type in ["enter", "move"]:
		if _ghost:
			_ghost.visible = false
		return
	if _ghost == null or _ghost.id != b.who:
		if _ghost:
			_ghost.queue_free()
		_ghost = Puppet.new()
		_ghost.setup(b.who, Game.characters.get(b.who, {}))
		# Premultiplied output: scale colour and alpha together for an even fade.
		_ghost.modulate = Color(0.55, 0.55, 0.55, 0.55)
		_actors.add_child(_ghost)
	_ghost.visible = true
	var s: Dictionary = st.get(b.who, {})
	var from: float
	if b.type == "enter":
		from = EpisodeScript.SPOTS.offleft if b.from == "left" else EpisodeScript.SPOTS.offright
	else:
		from = s.get("x", b.x)
	if _drag_id != "__ghost":
		_ghost.position = Vector2(b.x, GROUND)
	if absf(b.x - from) > 1.0:
		_ghost.facing = 1 if b.x > from else -1
	var emo: String = b.get("emotion", "") if b.type == "enter" else ""
	if emo == "":
		emo = s.get("emotion", "neutral")
	if _ghost.emotion != emo:
		_ghost.emotion = emo
		_ghost._redraw_now()


static func _fmt(t: float) -> String:
	return "%d:%04.1f" % [int(t) / 60, fmod(t, 60.0)]


func _toggle_play() -> void:
	_playing = not _playing
	if _playing and playhead >= _times[_times.size() - 1] - 0.05:
		playhead = 0.0
	_play_btn.text = "II" if _playing else ">"


func _process(delta: float) -> void:
	if _playing:
		var length: float = _times[_times.size() - 1]
		if playhead >= length:
			_playing = false
			_play_btn.text = ">"
			_update_preview()
			return
		_set_playhead(playhead + delta)
	elif _play_btn and _play_btn.text != ">":
		_play_btn.text = ">"


# --------------------------------------------------------------- dragging --

func _on_stage_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drag_id = _pick(event.position)
			_drag_start = event.position
			if _drag_id != "":
				_playing = false
		elif _drag_id != "":
			if event.position.distance_to(_drag_start) > 4.0:
				_commit_drag(_drag_node().position.x)
			_drag_id = ""
		_stage.accept_event()
	elif event is InputEventMouseMotion and _drag_id != "":
		_drag_node().position.x = clampf(event.position.x / STAGE_SCALE, 40.0, 1240.0)
		_stage.accept_event()


func _drag_node() -> Puppet:
	return _ghost if _drag_id == "__ghost" else _puppets[_drag_id]


func _pick(stage_pos: Vector2) -> String:
	var w := stage_pos / STAGE_SCALE
	var best := ""
	var best_d := 80.0
	# The destination ghost wins when it's under the pointer.
	if _ghost and _ghost.visible and w.y > GROUND - 320 and w.y < GROUND + 30 and absf(w.x - _ghost.position.x) < 70.0:
		return "__ghost"
	for cid in _puppets:
		var p: Puppet = _puppets[cid]
		if not p.visible or w.y < GROUND - 320 or w.y > GROUND + 30:
			continue
		var d := absf(w.x - p.position.x)
		if d < best_d:
			best_d = d
			best = cid
	return best


## A drag adjusts the selected beat if it's that character's move/placement;
## otherwise it adds a "walk there" beat at the playhead.
func _commit_drag(x: float) -> void:
	x = snappedf(x, 10.0)
	var beats: Array = doc.scenes[scene_i].beats
	if _drag_id == "__ghost":
		beats[selected].x = x
		_mark_dirty()
		_refresh(true)
		return
	if selected >= 0 and selected < beats.size():
		var b: Dictionary = beats[selected]
		if b.get("who", "") == _drag_id and b.type in ["move", "place", "enter"]:
			b.x = x
			_mark_dirty()
			_refresh(true)
			return
	_insert_beat({"type": "move", "who": _drag_id, "x": x, "speed": 300.0, "parallel": false})
	UiKit.toast(self, "%s walks there" % TimelineStrip.char_name(_drag_id).get_slice(" ", 0))


# ------------------------------------------------------- saving / dialogs --

func _mark_dirty() -> void:
	dirty = true


func _save() -> void:
	if doc.id == "":
		doc.id = Library.new_id(doc.title)
	if Library.save(doc.id, doc.to_text()):
		dirty = false
		UiKit.toast(self, "Saved!")
	else:
		UiKit.toast(self, "Couldn't save")


func _export() -> void:
	var text := doc.to_text()
	Library.copy_to_clipboard(text)
	var te := TextEdit.new()
	te.text = text
	te.editable = false
	te.custom_minimum_size = Vector2(640, 300)
	var vb := VBoxContainer.new()
	vb.add_child(UiKit.label("Copied to your clipboard! You can also select the text below.", 18))
	vb.add_child(te)
	UiKit.modal(self, "EXPORT", vb, [["DONE", UiKit.YELLOW, Callable()]])


func _open_info() -> void:
	var vb := VBoxContainer.new()
	vb.custom_minimum_size = Vector2(620, 0)
	vb.add_theme_constant_override("separation", 6)
	vb.add_child(UiKit.label("Series (shown on the title card; also picks the transition style)", 16, Color(0.35, 0.35, 0.4)))
	var series := OptionButton.new()
	var shows: Array = Game.shows.keys()
	for sh in shows:
		series.add_item(sh)
	series.add_item("(no series)")
	series.select(shows.find(doc.series) if shows.has(doc.series) else shows.size())
	vb.add_child(series)
	vb.add_child(UiKit.label("Icon", 16, Color(0.35, 0.35, 0.4)))
	var chosen := [doc.icon]  # holder: lambdas capture by value
	var icons := HFlowContainer.new()
	icons.add_theme_constant_override("h_separation", 4)
	vb.add_child(icons)
	var icon_btns := []
	var highlight := func() -> void:
		for ib in icon_btns:
			ib[0].modulate = Color.WHITE if ib[1] == chosen[0] else Color(1, 1, 1, 0.35)
	for ic in ShowIcon.episode_icons():
		var kind: String = ic[0]
		var btn := UiKit.icon_button(kind, ic[1], 50.0)
		btn.pressed.connect(func() -> void:
			chosen[0] = kind
			highlight.call())
		icons.add_child(btn)
		icon_btns.append([btn, kind])
	highlight.call()
	vb.add_child(UiKit.label("Episode number", 16, Color(0.35, 0.35, 0.4)))
	var num := SpinBox.new()
	num.min_value = 1
	num.max_value = 999
	num.value = doc.number
	vb.add_child(num)
	vb.add_child(UiKit.label("Description", 16, Color(0.35, 0.35, 0.4)))
	var desc := TextEdit.new()
	desc.text = doc.description
	desc.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	desc.custom_minimum_size = Vector2(0, 110)
	vb.add_child(desc)
	UiKit.modal(self, "EPISODE INFO", vb, [["OK", UiKit.YELLOW, func() -> void:
		doc.series = shows[series.selected] if series.selected < shows.size() else ""
		doc.icon = chosen[0]
		doc.number = int(num.value)
		doc.description = desc.text.replace("\n", " ")
		_mark_dirty()
		_load_scene(scene_i)], ["CANCEL", Color.WHITE, Callable()]])


func _on_back() -> void:
	if not dirty:
		exited.emit()
		return
	UiKit.modal(self, "UNSAVED CHANGES", UiKit.label("Save this episode before leaving?", 20), [
		["SAVE", UiKit.YELLOW, func() -> void:
			_save()
			exited.emit()],
		["DON'T SAVE", UiKit.RED, func() -> void: exited.emit()],
		["CANCEL", Color.WHITE, Callable()]])
