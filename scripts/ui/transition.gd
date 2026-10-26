extends Control
## Full-screen scene transitions. Each show picks its own `style`
## (see data/shows.json):
##   bubbles - the underwater bubble wipe
##   iris    - classic cartoon iris-out: a black circle closes in, then opens
##   star    - star wipe: a star-shaped iris
##   heart   - heart-shaped iris
##   slide   - a striped curtain slides across
##   checker - checkerboard tiles pop in, then away
##   pinwheel - spinning pinwheel blades sweep the screen
##   fade    - plain fade through black (the default for shows without one)

var style := "bubbles":
	set(v):
		style = v
		queue_redraw()

var progress := 0.0:
	set(v):
		progress = v
		visible = v > 0.001
		queue_redraw()

## Where the iris closes in (stage coordinates).
var focus := Vector2(640, 360)

var _bubbles: Array = []
var _revealing := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for gx in 10:
		for gy in 6:
			var p := Vector2(gx * 142.0 - 10.0 + rng.randf_range(-30, 30), gy * 140.0 - 10.0 + rng.randf_range(-30, 30))
			# Bubbles near the bottom start first so the wipe rises.
			var delay := (1.0 - p.y / 720.0) * 0.35 + rng.randf_range(0.0, 0.15)
			_bubbles.append({"p": p, "r": rng.randf_range(110, 150), "d": delay})
	progress = 0.0


func cover(dur: float = 0.65) -> void:
	_revealing = false
	var tw := create_tween()
	if style in ["iris", "star", "heart"]:
		tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "progress", 1.0, dur).from(0.0)
	await tw.finished


func reveal(dur: float = 0.65) -> void:
	_revealing = true
	var tw := create_tween()
	if style in ["iris", "star", "heart"]:
		tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "progress", 0.0, dur).from(1.0)
	await tw.finished


func _draw() -> void:
	match style:
		"bubbles": _draw_bubbles()
		"iris": _draw_iris()
		"star": _draw_shape_iris(_star_pts(), Color("1b1033"), Color("f6df4c"))
		"heart": _draw_shape_iris(_heart_pts(), Color("4a0f2a"), Color("ef5a9a"))
		"slide": _draw_slide()
		"checker": _draw_checker()
		"pinwheel": _draw_pinwheel()
		_: draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, progress))


func _draw_bubbles() -> void:
	if progress >= 0.999:
		draw_rect(Rect2(Vector2.ZERO, size), Color("4aa3e0"))
	for b in _bubbles:
		var k := clampf((progress - b.d) / 0.5, 0.0, 1.0)
		if k <= 0.0:
			continue
		var r: float = b.r * ease(k, -2.0)
		var c: Vector2 = b.p + Vector2(0, (1.0 - k) * 120.0)
		draw_circle(c, r + 4.0, Art.INK, true, -1.0, true)
		draw_circle(c, r, Color("4aa3e0").lerp(Color("a9e3fb"), fmod(b.p.x * 0.013, 1.0) * 0.5), true, -1.0, true)
		draw_arc(c, r * 0.7, PI * 1.1, PI * 1.45, 10, Color(1, 1, 1, 0.75), maxf(r * 0.08, 2.0), true)


func _draw_iris() -> void:
	if progress >= 0.999:
		draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
		return
	# Black everywhere outside a shrinking circle: one very thick ring.
	var far := (size + Vector2(200, 200)).length()
	var r := (1.0 - progress) * far * 0.62
	var thick := far * 1.2
	draw_arc(focus, r + thick * 0.5, 0.0, TAU, 96, Color.BLACK, thick, true)
	if r > 1.0:
		draw_arc(focus, r + 2.0, 0.0, TAU, 96, Color(0.1, 0.1, 0.1), 4.0, true)


## Shrinking-shape iris for any outline that is star-shaped around `focus`:
## everything outside it is filled with wedges radiating out from each edge.
func _draw_shape_iris(unit: PackedVector2Array, fill: Color, rim: Color) -> void:
	if progress >= 0.999:
		draw_rect(Rect2(Vector2.ZERO, size), fill)
		return
	var far := (size + Vector2(200, 200)).length()
	var sc := (1.0 - progress) * far * 0.75
	var spin := progress * 0.8
	var pts := PackedVector2Array()
	for p in unit:
		pts.append(focus + p.rotated(spin) * sc)
	var n := pts.size()
	for i in n:
		var a := pts[i]
		var b := pts[(i + 1) % n]
		draw_colored_polygon(PackedVector2Array([a, b, focus + (b - focus) * 40.0, focus + (a - focus) * 40.0]), fill)
	if sc > 2.0:
		var ring := pts.duplicate()
		ring.append(pts[0])
		draw_polyline(ring, rim, 6.0, true)


static func _star_pts() -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2 + TAU * i / 10.0
		pts.append(Vector2(cos(a), sin(a)) * (1.0 if i % 2 == 0 else 0.45))
	return pts


static func _heart_pts() -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 48:
		var t := TAU * i / 48.0
		var x := 16.0 * pow(sin(t), 3)
		var y := 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
		pts.append(Vector2(x, -y - 3.0) / 17.0)
	return pts


## A striped curtain that slides in from the left, then off to the right.
func _draw_slide() -> void:
	var x := (progress - 1.0) * size.x if not _revealing else (1.0 - progress) * size.x
	var r := Rect2(Vector2(x, 0), size)
	draw_rect(r, Color("e6452f"))
	for i in 12:
		var sx := x + i * size.x / 12.0
		draw_rect(Rect2(Vector2(sx, 0), Vector2(size.x / 24.0, size.y)), Color("c1272d"))
	var edge := x + size.x if not _revealing else x
	draw_line(Vector2(edge, 0), Vector2(edge, size.y), Color("f2c14e"), 14.0)
	draw_line(Vector2(edge, 0), Vector2(edge, size.y), Art.INK, 4.0)


## Checkerboard tiles that pop in along a diagonal.
func _draw_checker() -> void:
	var cols := 10
	var rows := 6
	var cell := Vector2(size.x / cols, size.y / rows)
	for gy in rows:
		for gx in cols:
			var delay := float(gx + gy) / float(cols + rows) * 0.5
			var k := clampf((progress - delay) / 0.5, 0.0, 1.0)
			if k <= 0.0:
				continue
			var c := Vector2(gx + 0.5, gy + 0.5) * cell
			var half := cell * 0.5 * ease(k, -1.6) * 1.02
			var col := Color("3d8fe0") if (gx + gy) % 2 == 0 else Color("f6df4c")
			draw_rect(Rect2(c - half, half * 2.0), col)


## Pinwheel blades that sweep round until they cover the screen.
func _draw_pinwheel() -> void:
	if progress >= 0.999:
		draw_rect(Rect2(Vector2.ZERO, size), Color("b48be0"))
		return
	var c := size / 2.0
	var far := size.length()
	var blades := 6
	var spin := progress * 1.6 * (1.0 if not _revealing else -1.0)
	for i in blades:
		var a0 := TAU * i / blades + spin
		var a1 := a0 + TAU / blades * progress
		var pts := PackedVector2Array([c])
		for k in 9:
			var a := lerpf(a0, a1, k / 8.0)
			pts.append(c + Vector2(cos(a), sin(a)) * far)
		draw_colored_polygon(pts, Color("b48be0") if i % 2 == 0 else Color("6b4fd6"))
