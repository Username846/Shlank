extends Node
## Dev tool: plays an episode fast and saves frames in the middle of scene transitions.
func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var main = load("res://scripts/main.gd").new()
	add_child(main)
	await get_tree().process_frame
	Game.voice_mode = "silent"
	if args[1] == "styles":
		# One scene change per transition style.
		var text := "@title Transitions\nSCENE pineapple_house cut\nPLACE spongebert center\nSPONGEBERT: Hi.\n"
		var locs := ["sunset_arms", "krusty_crab", "ps118", "treedome", "rooftop", "goo_lagoon", "classroom", "chum_bucket",
			"kamee_house", "wall_top", "mushroom_kingdom", "save_room"]
		for i in EpisodeScript.TRANSITIONS.size():
			text += "SCENE %s %s\nPLACE pat center\nPAT: %s.\n" % [locs[i], EpisodeScript.TRANSITIONS[i], EpisodeScript.TRANSITIONS[i]]
		main.play_episode(EpisodeScript.parse(text, Game.characters))
	else:
		main.play_episode(main._episodes[int(args[1])].script)
	var player: EpisodePlayer = main._screen
	Engine.time_scale = 6.0
	var shots := 0
	var armed := true
	var want := EpisodeScript.TRANSITIONS.size() if args[1] == "styles" else 4
	while shots < want and not player._end_overlay.visible:
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
