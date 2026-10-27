extends Node
## Dev tool: drives the episode editor end to end and saves screenshots.
var out := "."

func _ready() -> void:
	out = OS.get_cmdline_user_args()[0]
	var main = load("res://scripts/main.gd").new()
	add_child(main)
	await _frames(8)
	main.show_cast_picker()
	await _shot("t_cast_picker")
	main.show_cast("Hey Arnold!", 1)
	await _shot("t_cast_hillwood")
	main.show_location_picker()
	await _shot("t_loc_picker")
	main.show_episodes()
	await _shot("t_episodes")
	main.show_library()
	await _shot("t_library")
	main._new_episode_dialog(main._screen)
	await _shot("t_new_dialog")
	# Open the Hey Arnold! episode in the editor
	var entry = main._episodes[1]
	var doc := EpisodeDoc.from_script(entry.script)
	doc.id = "test_edit_" + str(Time.get_ticks_msec())
	main.open_editor(doc, 1)
	await _frames(6)
	var ed: EpisodeEditor = main._screen
	await _shot("t_editor")
	ed._select_beat(6)
	await _shot("t_editor_selected")
	# A HOLD beat shows a category picker and an item picker
	var hold_at := Vector2i(-1, -1)
	for si in doc.scenes.size():
		for bi in doc.scenes[si].beats.size():
			if hold_at.x < 0 and doc.scenes[si].beats[bi].type == "hold":
				hold_at = Vector2i(si, bi)
	if hold_at.x >= 0:
		ed._load_scene(hold_at.x)
		await _frames(3)
		ed._select_beat(hold_at.y)
		await _frames(3)
		print("HOLD BEAT: ", doc.scenes[hold_at.x].beats[hold_at.y].prop)
		await _shot("t_hold_inspector")
		ed._load_scene(0)
		await _frames(3)
	ed._open_location_picker()
	await _frames(40)
	await _shot("t_loc_picker")
	ed._picker.queue_free()
	ed._open_music_picker()
	await _shot("t_music_picker")
	ed._picker.queue_free()
	ed._open_character_picker("helga", true, func(cid: String) -> void: print("PICKED ", cid))
	await _frames(40)
	await _shot("t_char_picker")
	ed._pick_character("phil", func(cid: String) -> void: print("PICKED ", cid))
	# Entrance with an emotion: select Helga's ENTER (beat 2 of scene 2) and check the ghost
	var enter_i := -1
	for i in doc.scenes[1].beats.size():
		if doc.scenes[1].beats[i].type == "enter":
			enter_i = i
			break
	ed._select_beat(enter_i)
	doc.scenes[1].beats[enter_i].emotion = "nervous"
	ed._refresh(true)
	await _shot("t_enter_ghost")
	ed._drag_id = "__ghost"
	ed._commit_drag(300.0)
	ed._drag_id = ""
	print("GHOST DRAG: x=", doc.scenes[1].beats[enter_i].x, " line: ", EpisodeDoc.beat_to_line(doc.scenes[1].beats[enter_i]))
	await _shot("t_enter_ghost_moved")
	ed._set_playhead(9.0)
	await _shot("t_editor_scrub")
	# Drag Helga to the far right at this moment
	var before: int = doc.scenes[1].beats.size()
	ed.selected = -1
	ed._drag_id = "helga"
	ed._commit_drag(1100.0)
	ed._drag_id = ""
	await _frames(4)
	print("DRAG inserted beat: ", doc.scenes[1].beats.size() == before + 1, " -> ", doc.scenes[1].beats[ed.selected])
	ed._set_playhead(ed._times[ed.selected] + 3.0)
	await _shot("t_editor_after_drag")
	ed._open_info()
	await _shot("t_info")
	for c in ed.get_children():
		if c is ColorRect and c.color.a < 0.9:
			c.queue_free()
	ed._save()
	print("SAVED: ", Library.user_ids().has(doc.id))
	var reparsed := EpisodeScript.parse(Library.load_user(doc.id), Game.characters)
	print("RELOAD errors: ", reparsed.errors, " cmds ", reparsed.commands.size())
	Library.delete(doc.id)
	# Brand-new episode built from templates
	var nd := EpisodeDoc.new_episode("bolt")
	main.open_editor(nd, 0, true)
	await _frames(4)
	ed = main._screen
	var tpl: Array = ed._beat_templates()
	for name in ["Character enters", "Dialogue line", "Change emotion", "Walk to a spot", "Sound effect", "Narration", "The End card"]:
		for t in tpl:
			if t[0] == name:
				ed._insert_beat(t[1].call())
	ed._add_scene()
	ed._set_location("sunset_arms")
	ed._insert_beat(tpl[0][1].call())
	for t in tpl:
		if t[0] == "Change music":
			var mb: Dictionary = t[1].call()
			mb.mood = "spooky"
			mb.variant = 3
			ed._insert_beat(mb)
	ed._open_info()
	await _shot("t_info_icons")
	for c in ed.get_children():
		if c is ColorRect and c.color.a < 0.9:
			c.queue_free()
	await _shot("t_new_episode")
	var text := nd.to_text()
	print("NEW EPISODE TEXT:\n", text)
	var sc := EpisodeScript.parse(text, Game.characters)
	print("NEW errors: ", sc.errors, " est ", sc.estimate_duration(), " icon=", sc.icon, " has spooky 3: ", text.contains("MUSIC spooky 3"))
	# Make sure it plays to the end
	Game.voice_mode = "silent"
	main.play_episode(sc, func() -> void: pass)
	var player: EpisodePlayer = main._screen
	Engine.time_scale = 10.0
	var t0 := Time.get_ticks_msec()
	while not player._end_overlay.visible and Time.get_ticks_msec() - t0 < 60000:
		await get_tree().process_frame
	print("NEW EPISODE PLAYED TO END: ", player._end_overlay.visible)
	# Test Scene: just scene 2 of The Locket
	var single := EpisodeScript.parse(doc.scene_text(1), Game.characters)
	print("SCENE TEXT errors ", single.errors, " cmds ", single.commands.size(), " first: ", single.commands[0])
	main.play_episode(single, func() -> void: pass)
	player = main._screen
	t0 = Time.get_ticks_msec()
	while not player._end_overlay.visible and Time.get_ticks_msec() - t0 < 60000:
		await get_tree().process_frame
	print("TEST SCENE PLAYED TO END: ", player._end_overlay.visible)
	Engine.time_scale = 1.0
	# Leaving the editor goes back to the series list it was opened from
	main.show_library_list("Kirby")
	await _frames(3)
	main.open_editor(EpisodeDoc.from_script(main._episodes.filter(func(e): return e.script.series == "Kirby")[0].script))
	await _frames(3)
	main._screen.exited.emit()
	await _frames(3)
	print("BACK TO LIBRARY LIST: ", main._library_series)
	get_tree().quit()

func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame

func _shot(name: String) -> void:
	await _frames(4)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
