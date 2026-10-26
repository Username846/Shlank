extends Control
## Full-screen cartoon title card ("Ten minutes later...", episode titles, The End).

var lines: Array = []  # [{text, size, color}]
var bg := Color("f5c542")
var font: Font = preload("res://assets/fonts/LuckiestGuy-Regular.ttf")
var _t := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func show_card(card_lines: Array, color: Color) -> void:
	lines = card_lines
	bg = color
	_t = 0.0
	visible = true
	modulate.a = 0.0
	scale = Vector2(1.15, 1.15)
	pivot_offset = size / 2.0
	var tw := create_tween().set_parallel()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)
	tw.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_card() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	await tw.finished
	visible = false


func _process(delta: float) -> void:
	if visible:
		_t += delta
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2(-40, -40), size + Vector2(80, 80))
	Art.gradient_rect(self, r, bg.lightened(0.25), bg.darkened(0.15))
	# Spinning sunburst
	var c := size / 2.0
	for i in 16:
		var a := _t * 0.15 + TAU * i / 16.0
		var tri := PackedVector2Array([c, c + Vector2(cos(a), sin(a)) * 1600.0, c + Vector2(cos(a + 0.18), sin(a + 0.18)) * 1600.0])
		draw_colored_polygon(tri, Color(1, 1, 1, 0.12))
	for i in 7:
		var p := Vector2(fmod(i * 233.0 + _t * 20.0, size.x + 200.0) - 100.0, 80.0 + (i * 157 % 560))
		Art.sky_flower(self, p, 46.0 + (i % 3) * 14.0, Color(1, 1, 1, 0.22), _t * 0.3 + i)
	var total_h := 0.0
	for l in lines:
		total_h += l.size * 1.15
	var y := c.y - total_h / 2.0
	for i in lines.size():
		var l: Dictionary = lines[i]
		y += l.size
		# Gentle wobble, Flash-tween style
		var wob := sin(_t * 3.0 + i) * 4.0
		draw_set_transform(Vector2(0, wob), sin(_t * 2.0 + i) * 0.012, Vector2.ONE)
		Art.text(self, font, Vector2(0, y), l.text, l.size, l.get("color", Color.WHITE), int(l.size / 5.0) + 4, HORIZONTAL_ALIGNMENT_CENTER, size.x)
		draw_set_transform(Vector2.ZERO)
		y += l.size * 0.15
