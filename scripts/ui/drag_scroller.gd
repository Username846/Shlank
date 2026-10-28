class_name DragScroller
extends Node
## Lets a finger (or a held mouse button) drag a ScrollContainer, even when the drag
## starts on a button or card inside it, with a little momentum on release.
## Short taps still reach the buttons; once the finger has moved past THRESHOLD
## pixels it becomes a scroll and the tap is cancelled.
##   DragScroller.attach(scroll)

const THRESHOLD := 14.0
const FRICTION := 0.04  # fraction of the fling speed left after one second

var _scroll: ScrollContainer
var _down := false
var _dragging := false
var _start := Vector2.ZERO
var _start_scroll := Vector2.ZERO
var _last_pos := Vector2.ZERO
var _last_us := 0
var _vel := Vector2.ZERO
var _fling := Vector2.ZERO  # sub-pixel remainder while flinging


static func attach(scroll: ScrollContainer) -> DragScroller:
	var d := DragScroller.new()
	scroll.add_child(d)
	return d


func _ready() -> void:
	_scroll = get_parent() as ScrollContainer
	set_process(false)


func _axes() -> Vector2:
	return Vector2(0.0 if _scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED else 1.0,
		0.0 if _scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED else 1.0)


func _input(event: InputEvent) -> void:
	if _scroll == null or not _scroll.is_visible_in_tree():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _scroll.get_global_rect().has_point(event.position) and _on_top(event.position):
				_down = true
				_dragging = false
				_start = event.position
				_last_pos = event.position
				_last_us = Time.get_ticks_usec()
				_start_scroll = Vector2(_scroll.scroll_horizontal, _scroll.scroll_vertical)
				_vel = Vector2.ZERO
				set_process(false)
		elif _down:
			_down = false
			if _dragging:
				_dragging = false
				# The finger was scrolling, not tapping: don't click what it ended on.
				get_viewport().set_input_as_handled()
				if _vel.length() > 60.0:
					_fling = Vector2.ZERO
					set_process(true)
	elif event is InputEventMouseMotion and _down:
		var d: Vector2 = (event.position - _start) * _axes()
		if not _dragging and d.length() > THRESHOLD:
			_dragging = true
			_cancel_press()
		if _dragging:
			_scroll.scroll_horizontal = int(_start_scroll.x - d.x)
			_scroll.scroll_vertical = int(_start_scroll.y - d.y)
			var now := Time.get_ticks_usec()
			var dt := maxf((now - _last_us) / 1000000.0, 0.001)
			_vel = _vel.lerp(-(event.position - _last_pos) * _axes() / dt, 0.5)
			_last_pos = event.position
			_last_us = now
			get_viewport().set_input_as_handled()


## Only start when the press isn't on a popup or dialog drawn above this list.
func _on_top(pos: Vector2) -> bool:
	var hit := get_viewport().gui_get_hovered_control()
	if hit == null or hit == _scroll or _scroll.is_ancestor_of(hit) or hit.is_ancestor_of(_scroll):
		return true
	# The hover may be stale (a finger lands without moving first); trust it only if it's under the press.
	return not hit.get_global_rect().has_point(pos)


## Releases the press on whatever button the finger started on, away from it, so it
## doesn't fire or stay stuck looking pressed.
func _cancel_press() -> void:
	# Buttons only notice the pointer leaving on a move, so move it away first, then let go.
	var away := InputEventMouseMotion.new()
	away.position = Vector2(-10000, -10000)
	away.global_position = away.position
	away.button_mask = MOUSE_BUTTON_MASK_LEFT
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = Vector2(-10000, -10000)
	up.global_position = up.position
	_down = false
	get_viewport().push_input(away)
	get_viewport().push_input(up)
	_down = true


func _process(delta: float) -> void:
	if _down or _vel.length() < 20.0:
		set_process(false)
		return
	_fling += _vel * delta
	var step := Vector2(roundf(_fling.x), roundf(_fling.y))
	_fling -= step
	var before := Vector2(_scroll.scroll_horizontal, _scroll.scroll_vertical)
	_scroll.scroll_horizontal += int(step.x)
	_scroll.scroll_vertical += int(step.y)
	if step != Vector2.ZERO and Vector2(_scroll.scroll_horizontal, _scroll.scroll_vertical) == before:
		set_process(false)  # hit the end
		return
	_vel *= pow(FRICTION, delta)
