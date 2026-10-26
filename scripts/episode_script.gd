class_name EpisodeScript
extends RefCounted
## Parses the screenplay-style episode format (see README.md) into commands.

const SPOTS := {
	"offleft": -160.0, "farleft": 150.0, "left": 300.0, "midleft": 470.0, "center": 640.0,
	"midright": 810.0, "right": 980.0, "farright": 1130.0, "offright": 1440.0,
}

var title := "Untitled"
var number := 0
var description := ""
var commands: Array[Dictionary] = []
var errors: PackedStringArray = []


static func parse(text: String, characters: Dictionary) -> EpisodeScript:
	var ep := EpisodeScript.new()
	var aliases := _aliases(characters)
	var dialogue_re := RegEx.create_from_string("^([A-Za-z][A-Za-z0-9_.' ]*?)\\s*(?:\\(([^)]*)\\))?\\s*:\\s*(.+)$")
	var lines := text.split("\n")
	for i in lines.size():
		var line := lines[i].strip_edges()
		if line == "" or line.begins_with("#") or line.begins_with("//"):
			continue
		var ln := i + 1
		if line.begins_with("@"):
			var sp := line.find(" ")
			var key := line.substr(1, sp - 1 if sp > 0 else -1).to_lower()
			var val := line.substr(sp + 1).strip_edges() if sp > 0 else ""
			match key:
				"title": ep.title = val
				"number": ep.number = int(val)
				"description": ep.description = val
			continue
		var m := dialogue_re.search(line)
		if m:
			var who := String(aliases.get(m.get_string(1).strip_edges().to_upper(), ""))
			if who != "":
				ep.commands.append({"type": "say", "who": who, "emotion": m.get_string(2).strip_edges().to_lower(),
					"text": m.get_string(3).strip_edges(), "line": ln})
				continue
		var cmd := _parse_command(line, aliases, ln)
		if cmd.is_empty():
			ep.errors.append("Line %d: can't understand \"%s\"" % [ln, line])
		else:
			ep.commands.append(cmd)
	return ep


static func _aliases(characters: Dictionary) -> Dictionary:
	var a := {}
	for id in characters:
		var name := String(characters[id].get("name", id)).to_upper()
		a[String(id).to_upper()] = id
		a[name] = id
		a[name.replace(".", "")] = id
		var parts := name.replace(".", "").split(" ", false)
		if parts.size() > 1:
			if not a.has(parts[0]) and parts[0] != "MR":
				a[parts[0]] = id
			if not a.has(parts[parts.size() - 1]):
				a[parts[parts.size() - 1]] = id
	return a


static func _who(token: String, aliases: Dictionary) -> String:
	var u := token.to_upper()
	if aliases.has(u):
		return aliases[u]
	return String(aliases.get(u.replace("_", " "), ""))


static func spot(token: String, default: float = 640.0) -> float:
	var t := token.to_lower()
	if SPOTS.has(t):
		return SPOTS[t]
	if t.is_valid_float():
		return float(t)
	return default


static func _parse_command(line: String, aliases: Dictionary, ln: int) -> Dictionary:
	var parallel := line.ends_with("&")
	if parallel:
		line = line.trim_suffix("&").strip_edges()
	var parts := line.split(" ", false)
	var op := parts[0].to_upper()
	var arg := func(i: int, d: String = "") -> String: return parts[i] if parts.size() > i else d
	var rest := line.substr(parts[0].length()).strip_edges()
	var c := {"line": ln, "parallel": parallel}
	match op:
		"SCENE":
			c.merge({"type": "scene", "location": arg.call(1).to_lower(), "cut": arg.call(2).to_lower() == "cut"})
		"PLACE":
			c.merge({"type": "place", "who": _who(arg.call(1), aliases), "x": spot(arg.call(2, "center")), "face": arg.call(3, "").to_lower()})
		"ENTER":
			var side: String = arg.call(2, "left").to_lower()
			c.merge({"type": "enter", "who": _who(arg.call(1), aliases), "from": side,
				"x": spot(arg.call(3, "center")), "speed": float(arg.call(4, "340"))})
		"EXIT":
			c.merge({"type": "exit", "who": _who(arg.call(1), aliases), "to": arg.call(2, "right").to_lower(), "speed": float(arg.call(3, "380"))})
		"MOVE", "WALK":
			c.merge({"type": "move", "who": _who(arg.call(1), aliases), "x": spot(arg.call(2, "center")), "speed": float(arg.call(3, "240"))})
		"RUN":
			c.merge({"type": "move", "who": _who(arg.call(1), aliases), "x": spot(arg.call(2, "center")), "speed": float(arg.call(3, "520"))})
		"FACE":
			c.merge({"type": "face", "who": _who(arg.call(1), aliases), "dir": arg.call(2, "right").to_lower(),
				"target": _who(arg.call(2, ""), aliases)})
		"EMOTE":
			c.merge({"type": "emote", "who": _who(arg.call(1), aliases), "emotion": arg.call(2, "neutral").to_lower()})
		"HOLD":
			c.merge({"type": "hold", "who": _who(arg.call(1), aliases), "prop": arg.call(2, "none").to_lower()})
		"JUMP", "HOP":
			c.merge({"type": "jump", "who": _who(arg.call(1), aliases)})
		"CLOSE", "CLOSEUP":
			c.merge({"type": "camera", "mode": "close", "who": _who(arg.call(1), aliases)})
		"MEDIUM":
			c.merge({"type": "camera", "mode": "medium", "who": _who(arg.call(1), aliases)})
		"WIDE":
			c.merge({"type": "camera", "mode": "wide", "who": ""})
		"SHAKE":
			c.merge({"type": "shake", "time": float(arg.call(1, "0.6"))})
		"WAIT", "PAUSE", "BEAT":
			c.merge({"type": "wait", "time": float(arg.call(1, "1.0"))})
		"SFX", "SOUND":
			c.merge({"type": "sfx", "name": arg.call(1, "pop").to_lower()})
		"MUSIC":
			c.merge({"type": "music", "mood": arg.call(1, "happy").to_lower()})
		"CARD":
			c.merge({"type": "card", "text": rest})
		"TITLE":
			c.merge({"type": "title"})
		"END":
			c.merge({"type": "end", "text": rest if rest != "" else "The End"})
		_:
			return {}
	if c.has("who") and c.type != "camera" and c.who == "":
		return {}
	return c


## Rough runtime in seconds, used for the menu and the progress bar.
func estimate_duration() -> float:
	var t := 0.0
	var pos := {}
	for c in commands:
		t += command_duration(c, pos)
	return t


func command_duration(c: Dictionary, pos: Dictionary) -> float:
	match c.type:
		"say": return Game.estimate_line(Game.clean_for_speech(c.text)) + 0.25
		"scene":
			pos.clear()
			return 0.4 if c.cut else 1.5
		"place":
			pos[c.who] = c.x
			return 0.0
		"enter":
			var from: float = SPOTS.offleft if c.from == "left" else SPOTS.offright
			pos[c.who] = c.x
			return 0.0 if c.parallel else absf(c.x - from) / c.speed
		"exit":
			var to: float = SPOTS.offleft if c.to == "left" else SPOTS.offright
			var d: float = absf(to - float(pos.get(c.who, 640.0))) / c.speed
			pos.erase(c.who)
			return 0.0 if c.parallel else d
		"move":
			var d: float = absf(c.x - float(pos.get(c.who, c.x))) / c.speed
			pos[c.who] = c.x
			return 0.0 if c.parallel else d
		"wait": return c.time
		"shake": return 0.0
		"camera": return 0.5
		"card": return 1.2 + Game.estimate_line(c.text)
		"title": return 6.0
		"end": return 5.0
	return 0.0
