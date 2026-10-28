extends Node
## Dev tool: checks that a finger can drag the episode list without starting an
## episode, and that a plain tap on PLAY still plays. Prints SCROLL_TEST PASS/FAIL.

func _ready() -> void:
	var main = load("res://scripts/main.gd").new()
	add_child(main)
	await _frames(8)
	main.show_episode_list("SpongeBob SquarePants", 1)
	await _frames(5)
	var scroll: ScrollContainer = _find(main._screen, "ScrollContainer")
	var ok := true
	# Drag up from the middle of the first card's PLAY button
	var play: Button = _find_play(scroll)
	var start := play.get_global_rect().get_center()
	_touch(start, true)
	await _frames(2)
	for i in 12:
		_drag(start - Vector2(0, 20 * (i + 1)), Vector2(0, -20))
		await _frames(1)
	_touch(start - Vector2(0, 240), false)
	await _frames(30)
	print("scrolled to ", scroll.scroll_vertical)
	if scroll.scroll_vertical < 200:
		print("FAIL: list did not scroll")
		ok = false
	if main._screen is EpisodePlayer:
		print("FAIL: the drag started an episode")
		ok = false
	# A tap on a visible PLAY button still plays
	if ok:
		var p2: Button = _find_play(scroll, true)
		var at := p2.get_global_rect().get_center()
		_touch(at, true)
		await _frames(2)
		_touch(at, false)
		await _frames(5)
		if not main._screen is EpisodePlayer:
			print("FAIL: tap did not play")
			ok = false
	print("SCROLL_TEST ", "PASS" if ok else "FAIL")
	get_tree().quit()


func _touch(pos: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = 0
	e.position = pos
	e.pressed = pressed
	Input.parse_input_event(e)


func _drag(pos: Vector2, rel: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = 0
	e.position = pos
	e.relative = rel
	Input.parse_input_event(e)


func _find(n: Node, cls: String) -> Node:
	for c in n.get_children():
		if c.is_class(cls):
			return c
		var r := _find(c, cls)
		if r:
			return r
	return null


func _find_play(scroll: ScrollContainer, visible_only := false) -> Button:
	var r := scroll.get_global_rect()
	for b in scroll.find_children("*", "Button", true, false):
		if b.text == "PLAY" and (not visible_only or r.encloses(b.get_global_rect())):
			return b
	return null


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame
