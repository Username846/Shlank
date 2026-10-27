extends Node
## Dev tool: renders screens to PNGs. Usage:
##   godot --path . res://tools/snapshot.tscn -- <out_dir> <mode> [arg]
## modes: menu | props | prop_check | holds <id:prop ...> | cast | cast_ids <ids> | locations | loc_ids <ids> | episode <time_scale> | estimate <index> | estimate_files <paths...>

var out := "."
var main: Node


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	out = args[0] if args.size() > 0 else "."
	var mode := args[1] if args.size() > 1 else "menu"
	main = load("res://scripts/main.gd").new()
	add_child(main)
	await _frames(10)
	match mode:
		"estimate":
			var sc: EpisodeScript = main._episodes[int(args[2]) if args.size() > 2 else 0].script
			var by := {}
			var pos := {}
			for c in sc.commands:
				by[c.type] = by.get(c.type, 0.0) + sc.command_duration(c, pos)
			print("ESTIMATE ", UiKit.fmt_time(sc.estimate_duration()), " ", by, " errors=", sc.errors)
		"estimate_files":
			# Runtime of each episode file named after the mode: -- <out> estimate_files a.txt b.txt ...
			for path in args.slice(2):
				var sc := EpisodeScript.parse(FileAccess.get_file_as_string(path), Game.characters)
				print("ESTIMATE %s %s errors=%s" % [path.get_file(), UiKit.fmt_time(sc.estimate_duration()), sc.errors])
		"menu":
			await _shot("menu")
			main.show_episodes()
			await _frames(5)
			await _shot("episodes")
			main.show_seasons("SpongeBob SquarePants")
			await _frames(5)
			await _shot("seasons_spongebob")
			main.show_episode_list("Kirby")
			await _frames(5)
			await _shot("episodes_kirby")
			main.show_episode_list(main.YOURS)
			await _frames(5)
			await _shot("episodes_yours")
			main.show_settings()
			await _frames(5)
			await _shot("settings")
		"picker":
			main.show_cast_picker()
			await _frames(5)
			await _shot("picker")
			main.show_library()
			await _frames(5)
			await _shot("library")
			main.show_library_seasons("Hey Arnold!")
			await _frames(5)
			await _shot("library_seasons")
			main.show_library_list("Hey Arnold!")
			await _frames(5)
			await _shot("library_hillwood")
			main.show_library_list(main.YOURS)
			await _frames(5)
			await _shot("library_yours")
			main.show_library()
			await _frames(3)
			main._new_episode_dialog(main._screen)
			await _frames(5)
			await _shot("new_episode")
		"props":
			# Contact sheets of every prop, 40 to a page.
			var ids := Props.ids()
			for page in ceili(ids.size() / 40.0):
				var sheet := Control.new()
				sheet.set_anchors_preset(Control.PRESET_FULL_RECT)
				var bg := ColorRect.new()
				bg.color = Color("dfe9f2")
				bg.set_anchors_preset(Control.PRESET_FULL_RECT)
				sheet.add_child(bg)
				var canvas := Control.new()
				canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
				sheet.add_child(canvas)
				var chunk := ids.slice(page * 40, page * 40 + 40)
				canvas.draw.connect(func() -> void:
					for i in chunk.size():
						var pos := Vector2(64 + (i % 10) * 128, 150 + (i / 10) * 180)
						canvas.draw_circle(pos, 9, Color(0.95, 0.75, 0.6))
						Props.draw(canvas, chunk[i], pos, Vector2.UP, 0.3)
						canvas.draw_string(ThemeDB.fallback_font, pos + Vector2(-60, 26), chunk[i], HORIZONTAL_ALIGNMENT_CENTER, 120, 13, Color.BLACK))
				add_child(sheet)
				await _frames(3)
				await _shot("props_%d" % page)
				sheet.queue_free()
		"prop_check":
			# Lists characters whose drawing never draws the held prop.
			var missing := []
			for i in main._cast_order.size():
				main.show_cast("", i)
				await _frames(2)
				var p: Puppet = null
				for c in main._screen.get_children():
					if c is Puppet:
						p = c
				p.held = "dodgeball"
				var before := Props.draw_count
				await _frames(3)
				if Props.draw_count == before:
					missing.append(main._cast_order[i])
			print("PROP_CHECK missing=%d %s" % [missing.size(), " ".join(missing)])
		"holds":
			# Characters holding props in the cast viewer: -- <out> holds spongebob:spatula luigi:vacuum ...
			for pair in args.slice(2):
				var bits: PackedStringArray = pair.split(":")
				main.show_cast("", main._cast_order.find(bits[0]))
				await _frames(2)
				for c in main._screen.get_children():
					if c is Puppet:
						c.held = bits[1]
				await _frames(5)
				await _shot("hold_%s_%s" % [bits[0], bits[1]])
		"cast":
			for i in main._cast_order.size():
				main.show_cast("", i)
				await _frames(5)
				await _shot("cast_%d" % i)
		"emotions":
			main.show_cast("", int(args[2]) if args.size() > 2 else 0)
			await _frames(3)
			var p: Puppet = null
			for c in main._screen.get_children():
				if c is Puppet:
					p = c
			for e in Puppet.EMOTIONS:
				p.set_emotion(e)
				p.talking = e == "neutral"
				await _frames(30)
				await _shot("emo_%s_%s" % [p.id, e])
		"cast_ids":
			# Only the named characters: -- <out> cast_ids id1 id2 ...
			for id in args.slice(2):
				main.show_cast("", main._cast_order.find(id))
				await _frames(5)
				await _shot("cast_%s" % id)
		"loc_ids":
			# Only the named locations: -- <out> loc_ids id1 id2 ...
			for id in args.slice(2):
				main.show_locations("", main._location_order.find(id))
				await _frames(5)
				await _shot("loc_%s" % id)
		"locations":
			for i in main._location_order.size():
				main.show_locations("", i)
				await _frames(5)
				await _shot("loc_%d" % i)
		"episode":
			var ts := float(args[2]) if args.size() > 2 else 8.0
			Game.voice_mode = "silent"
			main.play_episode(main._episodes[int(args[4]) if args.size() > 4 else 0].script)
			var player: EpisodePlayer = main._screen
			Engine.time_scale = ts
			var real := 0.0
			var next := 0.0
			var n := 0
			while not player._end_overlay.visible:
				await get_tree().process_frame
				real += get_process_delta_time() / ts
				var game_t := player._done_time
				if game_t >= next:
					await _shot("ep_%03d" % n)
					n += 1
					next += float(args[3]) if args.size() > 3 else 12.0
				if real > 900:
					break
			print("EPISODE_DONE game_time=%.1f est=%.1f cmds=%d" % [player._done_time, player._total, player.ep.commands.size()])
			await _shot("ep_end")
	get_tree().quit()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s.png" % [out, name])
