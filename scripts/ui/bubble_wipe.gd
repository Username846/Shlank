extends Control
## The classic underwater "bubble wipe" scene transition.

var progress := 0.0:
	set(v):
		progress = v
		visible = v > 0.001
		queue_redraw()

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
	tw.tween_property(self, "progress", 1.0, dur).from(0.0)
	await tw.finished


func reveal(dur: float = 0.65) -> void:
	var tw := create_tween()
	tw.tween_property(self, "progress", 0.0, dur).from(1.0)
	await tw.finished


func _draw() -> void:
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
