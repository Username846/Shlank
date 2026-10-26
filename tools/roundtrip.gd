extends Node
## Dev check: every episode must survive text -> EpisodeDoc -> text unchanged.
func _ready() -> void:
	_go.call_deferred()

func _go() -> void:
	var ok := true
	for e in Game.episodes:
		var text: String = Game.load_text(e.file)
		var a := EpisodeScript.parse(text, Game.characters)
		var doc := EpisodeDoc.from_script(a)
		var b := EpisodeScript.parse(doc.to_text(), Game.characters)
		var ca := _norm(a.commands)
		var cb := _norm(b.commands)
		var same := ca == cb and a.title == b.title and a.series == b.series and a.description == b.description and b.errors.is_empty()
		print("%s: %d cmds -> %d cmds, errors %s, %s" % [e.file.get_file(), ca.size(), cb.size(), b.errors, "OK" if same else "MISMATCH"])
		if not same:
			ok = false
			for i in mini(ca.size(), cb.size()):
				if ca[i] != cb[i]:
					print("  first diff at ", i, "\n  ", ca[i], "\n  ", cb[i])
					break
		print("  scenes: ", doc.scenes.size(), "  scene 1 length %.1fs" % doc.scene_length(0))
	print("ROUNDTRIP ", "PASS" if ok else "FAIL")
	get_tree().quit()

func _norm(cmds: Array) -> Array:
	# Commands before the first SCENE move into it, so compare scene-relative order.
	var out := []
	var pre := []
	var seen_scene := false
	for c in cmds:
		var d: Dictionary = c.duplicate()
		d.erase("line")
		if d.type == "scene":
			out.append(d)
			if not seen_scene:
				out.append_array(pre)
			seen_scene = true
		elif not seen_scene:
			pre.append(d)
		else:
			out.append(d)
	return out
