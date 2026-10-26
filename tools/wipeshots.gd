extends Node
## Dev tool: plays an episode fast and saves frames in the middle of scene transitions.
func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var main = load("res://scripts/main.gd").new()
	add_child(main)
	await get_tree().process_frame
	Game.voice_mode = "silent"
	main.play_episode(main._episodes[int(args[1])].script)
	var player: EpisodePlayer = main._screen
	Engine.time_scale = 6.0
	var shots := 0
	var armed := true
	while shots < 4 and not player._end_overlay.visible:
		await get_tree().process_frame
		var p: float = player._wipe.progress
		if armed and p > 0.55 and p < 0.97:
			Engine.time_scale = 0.0001
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/wipe_%s_%d.png" % [args[0], args[1], shots])
			shots += 1
			armed = false
			Engine.time_scale = 6.0
		elif p < 0.05:
			armed = true
	get_tree().quit()
