class_name UiKit
extends RefCounted
## Cartoon-styled theme and widget helpers shared by all screens.

const TITLE_FONT := preload("res://assets/fonts/LuckiestGuy-Regular.ttf")
const BODY_FONT := preload("res://assets/fonts/Fredoka-SemiBold.ttf")
const YELLOW := Color("f6df4c")
const BLUE := Color("3d8fe0")
const PINK := Color("f7a1b4")
const RED := Color("e6452f")
const TEAL := Color("63c3a5")


static func box(color: Color, radius: int = 18, border: int = 4, shadow: int = 6) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.set_border_width_all(border)
	s.border_color = Art.INK
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 0
	s.shadow_offset = Vector2(0, shadow)
	if shadow > 0:
		s.shadow_size = 1
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	s.anti_aliasing = true
	return s


static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font = BODY_FONT
	t.default_font_size = 24
	t.set_stylebox("normal", "Button", box(YELLOW))
	t.set_stylebox("hover", "Button", box(YELLOW.lightened(0.25)))
	t.set_stylebox("pressed", "Button", box(YELLOW.darkened(0.15), 18, 4, 2))
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), 18, 4, 0))
	t.set_stylebox("disabled", "Button", box(Color(0.7, 0.7, 0.7)))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(state, "Button", Art.INK)
	t.set_color("font_disabled_color", "Button", Color(0.3, 0.3, 0.3))
	t.set_stylebox("panel", "PanelContainer", box(Color(1, 1, 1, 0.92), 22, 4, 8))
	t.set_stylebox("panel", "Panel", box(Color(1, 1, 1, 0.92), 22, 4, 8))
	t.set_color("font_color", "Label", Art.INK)
	t.set_color("font_outline_color", "Label", Art.INK)
	t.set_stylebox("slider", "HSlider", box(Color(0.85, 0.9, 0.95), 8, 3, 0))
	t.set_stylebox("grabber_area", "HSlider", box(BLUE, 8, 3, 0))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(BLUE.lightened(0.2), 8, 3, 0))
	t.set_stylebox("background", "ProgressBar", box(Color(0, 0, 0, 0.35), 6, 2, 0))
	t.set_stylebox("fill", "ProgressBar", box(YELLOW, 6, 2, 0))
	var empty := StyleBoxEmpty.new()
	t.set_stylebox("focus", "CheckButton", empty)
	t.set_stylebox("focus", "OptionButton", empty)
	t.set_stylebox("normal", "OptionButton", box(Color.WHITE, 14, 3, 0))
	t.set_stylebox("hover", "OptionButton", box(Color(0.95, 0.97, 1.0), 14, 3, 0))
	t.set_stylebox("pressed", "OptionButton", box(Color(0.9, 0.93, 0.97), 14, 3, 0))
	t.set_color("font_color", "OptionButton", Art.INK)
	t.set_color("font_hover_color", "OptionButton", Art.INK)
	t.set_color("font_color", "CheckButton", Art.INK)
	t.set_color("font_hover_color", "CheckButton", Art.INK)
	t.set_color("font_pressed_color", "CheckButton", Art.INK)
	t.set_color("font_hover_pressed_color", "CheckButton", Art.INK)
	t.set_stylebox("panel", "PopupMenu", box(Color.WHITE, 12, 3, 0))
	t.set_color("font_color", "PopupMenu", Art.INK)
	t.set_color("font_hover_color", "PopupMenu", Art.INK)
	t.set_stylebox("hover", "PopupMenu", box(YELLOW, 8, 0, 0))
	# Text fields
	for type in ["LineEdit", "TextEdit"]:
		var field := box(Color.WHITE, 10, 3, 0)
		field.content_margin_top = 6
		field.content_margin_bottom = 6
		field.content_margin_left = 10
		field.content_margin_right = 10
		var focus := field.duplicate()
		focus.border_color = BLUE
		t.set_stylebox("normal", type, field)
		t.set_stylebox("focus", type, focus)
		t.set_stylebox("read_only", type, field)
		t.set_color("font_color", type, Art.INK)
		t.set_color("font_readonly_color", type, Art.INK.lightened(0.25))
		t.set_color("font_placeholder_color", type, Color(0.5, 0.5, 0.55))
		t.set_color("caret_color", type, Art.INK)
		t.set_color("selection_color", type, Color(0.55, 0.75, 1.0, 0.6))
		t.set_font_size("font_size", type, 18)
	t.set_color("background_color", "TextEdit", Color.WHITE)
	# Lists
	var list := box(Color.WHITE, 10, 3, 0)
	list.content_margin_top = 4
	list.content_margin_bottom = 4
	list.content_margin_left = 4
	list.content_margin_right = 4
	t.set_stylebox("panel", "ItemList", list)
	t.set_stylebox("focus", "ItemList", StyleBoxEmpty.new())
	t.set_stylebox("selected", "ItemList", box(YELLOW, 8, 0, 0))
	t.set_stylebox("selected_focus", "ItemList", box(YELLOW, 8, 0, 0))
	t.set_stylebox("hovered", "ItemList", box(Color(1, 0.96, 0.8), 8, 0, 0))
	t.set_color("font_color", "ItemList", Art.INK)
	t.set_color("font_selected_color", "ItemList", Art.INK)
	t.set_color("font_hovered_color", "ItemList", Art.INK)
	t.set_color("font_hovered_selected_color", "ItemList", Art.INK)
	t.set_stylebox("hovered_selected", "ItemList", box(YELLOW.lightened(0.15), 8, 0, 0))
	t.set_stylebox("hovered_selected_focus", "ItemList", box(YELLOW.lightened(0.15), 8, 0, 0))
	t.set_font_size("font_size", "ItemList", 17)
	# Dropdown-style buttons look like option buttons
	for state in ["normal", "hover", "pressed"]:
		t.set_stylebox(state, "MenuButton", box(YELLOW if state != "pressed" else YELLOW.darkened(0.15), 14, 3, 0))
	t.set_stylebox("focus", "MenuButton", StyleBoxEmpty.new())
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(c, "MenuButton", Art.INK)
		t.set_color(c, "CheckBox", Art.INK)
	t.set_stylebox("focus", "CheckBox", StyleBoxEmpty.new())
	t.set_font_size("font_size", "OptionButton", 18)
	t.set_font_size("font_size", "PopupMenu", 18)
	return t


## A dimmed full-screen overlay with a centred panel. `buttons` is
## [[text, color, callable], ...]; any button closes the dialog after its callable
## runs, unless the callable returns false.
static func modal(parent: Node, title: String, body: Control, buttons: Array) -> Control:
	var o := ColorRect.new()
	o.color = Color(0.03, 0.05, 0.12, 0.7)
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.mouse_filter = Control.MOUSE_FILTER_STOP
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", box(Color("fffaf0"), 22, 4, 8))
	center.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	panel.add_child(vb)
	vb.add_child(title_label(title, 40, YELLOW))
	if body:
		vb.add_child(body)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	vb.add_child(row)
	for b in buttons:
		var btn := button(b[0], b[1], 24)
		var cb: Callable = b[2]
		btn.pressed.connect(func() -> void:
			var keep_open = cb.call() if cb.is_valid() else null
			if keep_open != false and is_instance_valid(o):
				o.queue_free())
		row.add_child(btn)
	parent.add_child(o)
	return o


## A short message that pops up near the bottom of the screen and fades away.
static func toast(parent: Node, text: String) -> void:
	var l := title_label(text, 30, Color.WHITE)
	l.position = Vector2(0, 600)
	l.size = Vector2(1280, 50)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	var tw := l.create_tween()
	tw.tween_interval(1.4)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)


static func button(text: String, color: Color = YELLOW, font_size: int = 28) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", TITLE_FONT)
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_stylebox_override("normal", box(color))
	b.add_theme_stylebox_override("hover", box(color.lightened(0.25)))
	b.add_theme_stylebox_override("pressed", box(color.darkened(0.15), 18, 4, 2))
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func() -> void: Synth.sfx("pop"))
	return b


static func title_label(text: String, size: int = 64, color: Color = YELLOW) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", TITLE_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", int(size / 5.0) + 4)
	l.add_theme_color_override("font_outline_color", Art.INK)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


static func label(text: String, size: int = 22, color: Color = Art.INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func fmt_time(sec: float) -> String:
	var s := int(roundf(sec))
	return "%d:%02d" % [s / 60, s % 60]
