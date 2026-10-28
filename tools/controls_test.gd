extends Node
## Dev tool: checks the playback controls. A tap on the picture must not skip the line;
## NEXT SCENE jumps to the next SCENE; pressing it repeatedly reaches the end screen.
## Usage: -- <out_dir>   Prints CONTROLS_TEST PASS/FAIL.
var out := "."

func _ready() -> void:
	out = OS.get_cmdline_user_args()[0]
	Game.voice_mode = "silent"
	var main = load("res://scripts/main.gd").new()
	add_child(main)
	await _frames(8)
	main.play_episode(main._episodes[0].script)
	var player: EpisodePlayer = main._screen
	var ok := true
	await _wait_for(func() -> bool: return player._sub_panel.visible, 15.0)
	await _shot("controls")
	# A tap in the middle of the screen must not move on to the next line
	var line: int = player._index
	_tap(Vector2(640, 400))
	await _frames(3)
	if player._index != line:
		print("FAIL: a tap skipped the line")
		ok = false
	# NEXT SCENE: the next command run must be a SCENE
	var scenes := []
	for i in player.ep.commands.size():
		if player.ep.commands[i].type == "scene":
			scenes.append(i)
	var target: int = scenes.filter(func(s: int) -> bool: return s > player._index)[0]
	player._scene_btn.pressed.emit()
	await _wait_for(func() -> bool: return player._index >= target, 10.0)
	if player._index != target:
		print("FAIL: NEXT SCENE went to command %d, expected %d" % [player._index, target])
		ok = false
	# Keep pressing until the end screen
	for i in scenes.size() + 2:
		if player._end_overlay.visible:
			break
		var at: int = player._index
		player._scene_btn.pressed.emit()
		await _wait_for(func() -> bool: return player._index > at or player._end_overlay.visible, 10.0)
	await _wait_for(func() -> bool: return player._end_overlay.visible, 10.0)
	if not player._end_overlay.visible:
		print("FAIL: never reached the end")
		ok = false
	print("CONTROLS_TEST ", "PASS" if ok else "FAIL")
	get_tree().quit()


func _tap(pos: Vector2) -> void:
	for pressed in [true, false]:
		var e := InputEventScreenTouch.new()
		e.position = pos
		e.pressed = pressed
		Input.parse_input_event(e)


func _wait_for(cond: Callable, sec: float) -> void:
	var t := 0.0
	while not cond.call() and t < sec:
		await get_tree().process_frame
		t += get_process_delta_time()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
