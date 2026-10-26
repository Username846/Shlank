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
	return t


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
