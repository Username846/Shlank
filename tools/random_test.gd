extends Node
## Dev tool: checks the RANDOM EPISODE buttons on the series, season and episode screens.
## Usage: -- <out_dir>   Prints RANDOM_TEST PASS/FAIL.
var out := "."
var main

func _ready() -> void:
	out = OS.get_cmdline_user_args()[0]
	Game.voice_mode = "silent"
	main = load("res://scripts/main.gd").new()
	add_child(main)
	await _frames(8)
	var ok := true
	# Series picker: any series, never the player's own
	ok = await _check("series", main.show_episodes, func(sc: EpisodeScript) -> bool: return sc.series != "") and ok
	# Season picker: any season of that series
	ok = await _check("seasons", main.show_seasons.bind("Kirby"), func(sc: EpisodeScript) -> bool: return sc.series == "Kirby") and ok
	# Episode list: only that season
	ok = await _check("episodes", main.show_episode_list.bind("Kirby", 2),
		func(sc: EpisodeScript) -> bool: return sc.series == "Kirby" and sc.season == 2) and ok
	print("RANDOM_TEST ", "PASS" if ok else "FAIL")
	get_tree().quit()


func _check(name: String, open: Callable, belongs: Callable) -> bool:
	var seen := {}
	for i in 8:
		open.call()
		await _frames(3)
		if i == 0:
			await _shot("random_" + name)
		var b: Button = null
		for c in main._screen.find_children("*", "Button", true, false):
			if c.text == "RANDOM EPISODE":
				b = c
		if b == null:
			print("FAIL: no RANDOM EPISODE button on the %s screen" % name)
			return false
		b.pressed.emit()
		await _frames(2)
		var player = main._screen
		if not player is EpisodePlayer:
			print("FAIL: %s button didn't play" % name)
			return false
		if not belongs.call(player.ep):
			print("FAIL: %s button played %s S%d" % [name, player.ep.series, player.ep.season])
			return false
		if not player.on_next.is_valid():
			print("FAIL: %s button has no up-next" % name)
			return false
		seen[player.ep.title] = true
		player.quit()
		await _frames(2)
	print("%s: %d different episodes in 8 presses" % [name, seen.size()])
	return seen.size() > 1


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _shot(n: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, n])
