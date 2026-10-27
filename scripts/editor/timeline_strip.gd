class_name TimelineStrip
extends Control
## Horizontal timeline of one scene. Beats that take time (lines, walks, waits,
## cards) are blocks on the main row; instant beats (emotions, props, sounds,
## music) are markers on the row above. Click a beat to select it, click empty
## space to move the playhead there.

signal beat_clicked(index: int)
signal seek(time: float)

const PX_PER_SEC := 46.0
const MARKER_ROW := Rect2(0, 22, 0, 22)
const BLOCK_ROW := Rect2(0, 50, 0, 46)
const LEFT := 12.0

var doc: EpisodeDoc
var scene_i := 0
var playhead := 0.0
var selected := -1

var _times := PackedFloat32Array()
var _hit: Array = []  # [Rect2, index]
var _font: Font = UiKit.BODY_FONT


func refresh() -> void:
	_times = doc.beat_times(scene_i) if doc else PackedFloat32Array([0.0])
	var total: float = _times[_times.size() - 1]
	custom_minimum_size = Vector2(maxf(LEFT * 2.0 + (total + 3.0) * PX_PER_SEC, 400.0), 104)
	queue_redraw()


func time_to_x(t: float) -> float:
	return LEFT + t * PX_PER_SEC


func _draw() -> void:
	_hit.clear()
	draw_rect(Rect2(Vector2.ZERO, size), Color("fffaf0"))
	if doc == null:
		return
	var total: float = _times[_times.size() - 1]
	# Second ticks
	for s in int(total) + 4:
		var x := time_to_x(s)
		var major := s % 5 == 0
		draw_line(Vector2(x, 0), Vector2(x, 10 if not major else 16), Color(0, 0, 0, 0.35), 1.0)
		if major:
			draw_string(_font, Vector2(x + 3, 14), "%d:%02d" % [s / 60, s % 60], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0, 0, 0, 0.5))
	draw_line(Vector2(0, 47), Vector2(size.x, 47), Color(0, 0, 0, 0.1), 1.0)
	var beats: Array = doc.scenes[scene_i].beats
	var stack := {}  # marker x -> how many markers already there
	for i in beats.size():
		var b: Dictionary = beats[i]
		var t0: float = _times[i]
		var dur: float = _times[i + 1] - t0
		var col := beat_color(b)
		if dur > 0.05:
			var r := Rect2(time_to_x(t0) + 1, BLOCK_ROW.position.y, maxf(dur * PX_PER_SEC - 2, 6), BLOCK_ROW.size.y)
			draw_style_box(UiKit.box(col, 8, 3 if i != selected else 5, 0), r)
			var label := beat_label(b)
			var max_chars := int((r.size.x - 10) / 7.2)
			if max_chars > 2:
				if label.length() > max_chars:
					label = label.left(max_chars - 1) + "…"
				draw_string(_font, r.position + Vector2(6, 28), label, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 8, 13, Art.INK)
			_hit.append([r, i])
		else:
			var x := time_to_x(t0)
			var key := int(x)
			var n: int = stack.get(key, 0)
			stack[key] = n + 1
			var c := Vector2(x + n * 15, MARKER_ROW.position.y + 11)
			var r := 7.0 if i != selected else 9.0
			draw_circle(c, r + 2.5, Art.INK, true, -1.0, true)
			draw_circle(c, r, col, true, -1.0, true)
			_hit.append([Rect2(c - Vector2(9, 11), Vector2(18, 22)), i])
	# Playhead
	var px := time_to_x(playhead)
	draw_line(Vector2(px, 0), Vector2(px, size.y), UiKit.RED, 3.0)
	draw_colored_polygon(PackedVector2Array([Vector2(px - 7, 0), Vector2(px + 7, 0), Vector2(px, 9)]), UiKit.RED)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Markers are drawn on top, so test them first.
		for k in range(_hit.size() - 1, -1, -1):
			if _hit[k][0].has_point(event.position):
				beat_clicked.emit(_hit[k][1])
				accept_event()
				return
		seek.emit(maxf((event.position.x - LEFT) / PX_PER_SEC, 0.0))
		accept_event()
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		seek.emit(maxf((event.position.x - LEFT) / PX_PER_SEC, 0.0))
		accept_event()


static func beat_color(b: Dictionary) -> Color:
	match b.type:
		"say":
			return Game.char_color(b.who).lerp(Color.WHITE, 0.45) if b.who != "narrator" else Color("ffe9a8")
		"enter", "exit", "move", "place", "face", "jump":
			return Color("8fd6c6")
		"emote", "hold":
			return Color("f7a1b4")
		"sfx", "music":
			return Color("b48be0")
		"camera", "shake":
			return Color("f2a65a")
		"card", "title", "end":
			return Color("f6df4c")
		"wait":
			return Color("cfd3d8")
	return Color.WHITE


static func char_name(id: String) -> String:
	return String(Game.characters.get(id, {}).get("name", id))


## One-line human description of a beat (timeline blocks, scene list).
static func beat_label(b: Dictionary) -> String:
	match b.type:
		"say": return "%s: %s" % [char_name(b.who), b.text]
		"enter": return "%s enters from the %s" % [char_name(b.who), b.from]
		"exit": return "%s exits %s" % [char_name(b.who), b.to]
		"move": return "%s %s" % [char_name(b.who), "runs" if b.speed >= 450 else "walks"]
		"place": return "%s is on stage" % char_name(b.who)
		"face": return "%s faces %s" % [char_name(b.who), b.dir]
		"emote": return "%s looks %s" % [char_name(b.who), b.emotion]
		"hold": return "%s holds %s" % [char_name(b.who), Props.label(String(b.prop)).to_lower()]
		"jump": return "%s jumps" % char_name(b.who)
		"camera": return "Camera: %s%s" % [b.mode, (" on " + char_name(b.who)) if b.who != "" else ""]
		"shake": return "Shake"
		"wait": return "Pause %.1fs" % b.time
		"sfx": return "Sound: %s" % b.name
		"music": return "Music: %s" % b.mood
		"card": return "Card: %s" % b.text
		"title": return "Title card"
		"end": return "End card: %s" % b.get("text", "The End")
	return b.type
