extends Node
## Dev tool: checks that autoplay moves on to the next episode in a series.
## Saves two tiny episodes of the player's own, plays the first with autoplay on,
## and screenshots the end-of-episode countdown. Usage: -- <out_dir>
var out := "."

func _ready() -> void:
	out = OS.get_cmdline_user_args()[0]
	for i in 2:
		Library.save("zz_autoplay_test_%d" % i, "@title Autoplay Test %d\n@number %d\n\nSCENE green_greens cut\nPLACE kirbie center\nKIRBIE: Poyo!\nEND\n" % [i + 1, i + 1])
	var main = load("res://scripts/main.gd").new()
	add_child(main)
	await _frames(8)
	var was: bool = Game.autoplay
	if not Game.autoplay:
		main._auto_btn.pressed.emit()  # the real toggle, as a click would
	print("AUTOPLAY ", Game.autoplay)
	await _shot("auto_controls")
	main._reload_episodes()
	main._play_in_series(main.YOURS, 0)
	var first: EpisodePlayer = main._screen
	print("PLAYING ", first.ep.title, " next=", first.next_title)
	await _frames(30)
	await _shot("auto_playing")
	Engine.time_scale = 4.0
	while not first._end_overlay.visible:
		await get_tree().process_frame
	Engine.time_scale = 1.0
	await _frames(70)
	await _shot("auto_countdown")
	var t := 0.0
	while main._screen == first and t < 10.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	var second = main._screen
	print("NOW PLAYING ", second.ep.title if second is EpisodePlayer else "(not a player)", " after %.1fs" % t)
	print("LAST HAS NEXT: ", (second as EpisodePlayer).on_next.is_valid())
	if Game.autoplay != was:
		main._auto_btn.pressed.emit()
	for i in 2:
		Library.delete("zz_autoplay_test_%d" % i)
	get_tree().quit()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _shot(name: String) -> void:
	await _frames(4)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
