extends Control
## Full-screen scene transitions. Each show picks its own `style`
## (see data/shows.json):
##   bubbles - the underwater bubble wipe
##   iris    - classic cartoon iris-out: a black circle closes in, then opens
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
	var tw := create_tween()
	if style == "iris":
		tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "progress", 1.0, dur).from(0.0)
	await tw.finished


func reveal(dur: float = 0.65) -> void:
	var tw := create_tween()
	if style == "iris":
		tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "progress", 0.0, dur).from(1.0)
	await tw.finished


func _draw() -> void:
	match style:
		"bubbles": _draw_bubbles()
		"iris": _draw_iris()
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
