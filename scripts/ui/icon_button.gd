class_name IconButton
extends Button
## A square cartoon button with a vector icon drawn on top.

enum Icon { FULLSCREEN, EXIT_FULLSCREEN, VOLUME, MUTED, AUTOPLAY }

var icon_kind := Icon.VOLUME:
	set(v):
		icon_kind = v
		queue_redraw()
## AUTOPLAY: whether the toggle is on (drawn bold) or off (faded, with a slash).
var on := true:
	set(v):
		on = v
		queue_redraw()
## 0..1, only used by the VOLUME icon to choose how many sound waves to show.
var level := 1.0:
	set(v):
		level = v
		queue_redraw()


static func make(kind: Icon, color: Color, tip: String) -> IconButton:
	var b := IconButton.new()
	b.icon_kind = kind
	b.tooltip_text = tip
	b.custom_minimum_size = Vector2(56, 56)
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_stylebox_override("normal", UiKit.box(color, 16))
	b.add_theme_stylebox_override("hover", UiKit.box(color.lightened(0.25), 16))
	b.add_theme_stylebox_override("pressed", UiKit.box(color.darkened(0.15), 16, 4, 2))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return b


func _draw() -> void:
	var c := size / 2.0 + Vector2(0, -2 if not button_pressed else 1)
	var s := minf(size.x, size.y) * 0.3
	match icon_kind:
		Icon.FULLSCREEN, Icon.EXIT_FULLSCREEN:
			var inward := icon_kind == Icon.EXIT_FULLSCREEN
			for sx in [-1, 1]:
				for sy in [-1, 1]:
					var corner := c + Vector2(sx, sy) * s
					var d := 0.55 * s
					var a := corner + Vector2(-sx * d, 0)
					var b := corner + Vector2(0, -sy * d)
					if inward:
						corner = c + Vector2(sx, sy) * s * 0.45
						a = corner + Vector2(sx * d, 0)
						b = corner + Vector2(0, sy * d)
					draw_polyline(PackedVector2Array([a, corner, b]), Art.INK, 4.0, true)
		Icon.VOLUME, Icon.MUTED:
			var body := PackedVector2Array([c + Vector2(-s, -s * 0.35), c + Vector2(-s * 0.45, -s * 0.35),
				c + Vector2(0.05 * s, -s * 0.85), c + Vector2(0.05 * s, s * 0.85), c + Vector2(-s * 0.45, s * 0.35), c + Vector2(-s, s * 0.35)])
			draw_colored_polygon(body, Art.INK)
			if icon_kind == Icon.MUTED or level <= 0.001:
				var x := c + Vector2(s * 0.65, 0)
				var r := s * 0.32
				draw_line(x + Vector2(-r, -r), x + Vector2(r, r), Art.INK, 4.0, true)
				draw_line(x + Vector2(-r, r), x + Vector2(r, -r), Art.INK, 4.0, true)
			else:
				var waves := 1 if level < 0.34 else (2 if level < 0.67 else 3)
				for i in waves:
					var r := s * (0.45 + i * 0.35)
					draw_arc(c + Vector2(0.05 * s, 0), r, -0.8, 0.8, 10, Art.INK, 3.5, true)
		Icon.AUTOPLAY:
			# "Play next": a play triangle running into a bar
			var col := Art.INK if on else Color(Art.INK, 0.4)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-s * 0.9, -s * 0.8), c + Vector2(s * 0.45, 0),
				c + Vector2(-s * 0.9, s * 0.8)]), col)
			draw_rect(Rect2(c + Vector2(s * 0.55, -s * 0.8), Vector2(s * 0.32, s * 1.6)), col)
			if not on:
				draw_line(c + Vector2(-s, s), c + Vector2(s, -s), Art.INK, 4.0, true)
