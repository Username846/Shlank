class_name EpisodeDoc
extends RefCounted
## Editable model of an episode: metadata plus a list of scenes, each with a
## location and an ordered list of "beats" (the commands from the script format).
## Converts to and from the plain-text screenplay format.

var id := ""
var title := "Untitled Episode"
var series := ""
## Badge shown on the episode's cards (see ShowIcon). Empty = use the series' badge.
var icon := ""
var number := 1
var description := ""
## [{location: String, cut: bool, beats: Array[Dictionary]}]
var scenes: Array = []

## Used only for its command_duration() helper.
var _timer := EpisodeScript.new()


static func from_text(text: String) -> EpisodeDoc:
	return from_script(EpisodeScript.parse(text, Game.characters))


static func from_script(sc: EpisodeScript) -> EpisodeDoc:
	var doc := EpisodeDoc.new()
	doc.title = sc.title
	doc.series = sc.series
	doc.icon = sc.icon
	doc.number = maxi(sc.number, 1)
	doc.description = sc.description
	var pending: Array = []  # commands before the first SCENE
	for c in sc.commands:
		var beat: Dictionary = c.duplicate()
		beat.erase("line")
		if beat.type == "scene":
			doc.scenes.append({"location": beat.location, "cut": beat.cut, "beats": pending})
			pending = []
		elif doc.scenes.is_empty():
			pending.append(beat)
		else:
			doc.scenes[-1].beats.append(beat)
	if doc.scenes.is_empty():
		doc.scenes.append({"location": doc.default_location(), "cut": true, "beats": pending})
	return doc


## A blank episode. It isn't tied to a show: any characters and locations can be used.
static func new_episode(p_icon: String) -> EpisodeDoc:
	var doc := EpisodeDoc.new()
	doc.icon = p_icon
	doc.title = "My New Episode"
	doc.description = "A brand new adventure."
	doc.scenes.append({"location": doc.default_location(), "cut": true, "beats": [
		{"type": "music", "mood": "happy", "variant": 1},
		{"type": "title"},
	]})
	return doc


func to_script() -> EpisodeScript:
	return EpisodeScript.parse(to_text(), Game.characters)


# ---------------------------------------------------------------- queries --

## Every character with a body. The episode's own series comes first, but
## any show's characters can appear in any episode.
func show_characters() -> Array:
	var mine := []
	var others := []
	for cid in Game.characters:
		var c: Dictionary = Game.characters[cid]
		if c.get("style", "none") == "none":
			continue
		if series != "" and c.get("show", "") == series:
			mine.append(cid)
		else:
			others.append(cid)
	return mine + others


## Every show that has locations, in data order.
static func location_shows() -> Array:
	var shows := []
	for lid in Game.locations:
		var sh: String = Game.locations[lid].get("show", "")
		if not shows.has(sh):
			shows.append(sh)
	return shows


static func locations_of(show: String) -> Array:
	return Game.locations.keys().filter(func(l): return Game.locations[l].get("show", "") == show)


func show_locations() -> Array:
	var out := []
	for lid in Game.locations:
		if series == "" or Game.locations[lid].get("show", "") == series:
			out.append(lid)
	return out if not out.is_empty() else Game.locations.keys()


func default_location() -> String:
	return show_locations()[0]


func beat_duration(beat: Dictionary, pos: Dictionary) -> float:
	return _timer.command_duration(beat, pos)


## Start time of every beat in a scene, plus the total length at the end.
func beat_times(scene_i: int) -> PackedFloat32Array:
	var times := PackedFloat32Array()
	var pos := {}
	var t := 0.0
	for b in scenes[scene_i].beats:
		times.append(t)
		t += beat_duration(b, pos)
	times.append(t)
	return times


func scene_length(scene_i: int) -> float:
	var times := beat_times(scene_i)
	return times[times.size() - 1]


## Where everybody is (and how they look) at time t within a scene.
## Returns {id: {x, facing, emotion, held, visible}} plus "_line": the beat being spoken.
func state_at(scene_i: int, t: float) -> Dictionary:
	var st := {}
	var motion := {}  # id -> [x0, x1, t0, dur]
	var pos := {}
	var time := 0.0
	var line := {}
	for b in scenes[scene_i].beats:
		if time > t + 0.0001:
			break
		var d := beat_duration(b, pos)
		var who: String = b.get("who", "")
		match b.type:
			"place":
				st[who] = _char(st, who)
				st[who].x = b.x
				st[who].visible = true
				if b.get("face", "") in ["left", "right"]:
					st[who].facing = -1 if b.face == "left" else 1
				motion.erase(who)
			"enter":
				var from: float = EpisodeScript.SPOTS.offleft if b.from == "left" else EpisodeScript.SPOTS.offright
				st[who] = _char(st, who)
				st[who].visible = true
				motion[who] = [from, b.x, time, absf(b.x - from) / maxf(b.speed, 1.0)]
			"move", "exit":
				if st.has(who):
					var x0 := _x_at(st, motion, who, time)
					var x1: float = b.x if b.type == "move" else (EpisodeScript.SPOTS.offleft if b.to == "left" else EpisodeScript.SPOTS.offright)
					motion[who] = [x0, x1, time, absf(x1 - x0) / maxf(b.speed, 1.0)]
					if b.type == "exit":
						st[who].exit_at = time + absf(x1 - x0) / maxf(b.speed, 1.0)
			"face":
				if st.has(who):
					if b.target != "" and st.has(b.target):
						st[who].facing = 1 if _x_at(st, motion, b.target, time) > _x_at(st, motion, who, time) else -1
					else:
						st[who].facing = -1 if b.dir == "left" else 1
			"emote":
				if st.has(who):
					st[who].emotion = b.emotion
			"hold":
				if st.has(who):
					st[who].held = "" if b.prop in ["none", ""] else b.prop
			"say":
				if st.has(who) and b.emotion != "":
					st[who].emotion = b.emotion
				if t < time + d:
					line = b
		time += d
	for who in st:
		var m: Array = motion.get(who, [])
		st[who].x = _x_at(st, motion, who, t)
		if not m.is_empty() and t < m[2] + m[3] and m[1] != m[0]:
			st[who].facing = 1 if m[1] > m[0] else -1
			st[who].walking = true
		if st[who].has("exit_at") and t >= st[who].exit_at:
			st[who].visible = false
	st["_line"] = line
	return st


func _char(st: Dictionary, who: String) -> Dictionary:
	return st.get(who, {"x": 640.0, "facing": 1, "emotion": "neutral", "held": "", "visible": true, "walking": false})


func _x_at(st: Dictionary, motion: Dictionary, who: String, t: float) -> float:
	if motion.has(who):
		var m: Array = motion[who]
		var k := 1.0 if m[3] <= 0.0 else clampf((t - m[2]) / m[3], 0.0, 1.0)
		return lerpf(m[0], m[1], k)
	return st[who].x if st.has(who) else 640.0


# ---------------------------------------------------------- serialization --

func to_text() -> String:
	var out := PackedStringArray()
	out.append("@title %s" % _one_line(title))
	if series != "":
		out.append("@series %s" % series)
	if icon != "":
		out.append("@icon %s" % icon)
	out.append("@number %d" % number)
	if description != "":
		out.append("@description %s" % _one_line(description))
	for i in scenes.size():
		var sc: Dictionary = scenes[i]
		out.append("")
		out.append("# ---- Scene %d: %s" % [i + 1, String(Game.locations.get(sc.location, {}).get("name", sc.location))])
		out.append("SCENE %s%s" % [sc.location, " cut" if sc.cut else ""])
		for b in sc.beats:
			out.append(beat_to_line(b))
	out.append("")
	return "\n".join(out)


static func beat_to_line(b: Dictionary) -> String:
	var amp := " &" if b.get("parallel", false) else ""
	var who := String(b.get("who", "")).to_upper()
	match b.type:
		"say":
			var emo: String = b.get("emotion", "")
			return "%s%s: %s" % [who, (" (%s)" % emo) if emo != "" else "", _one_line(b.text)]
		"place":
			var face: String = b.get("face", "")
			return "PLACE %s %s%s" % [who, _spot_name(b.x), (" " + face) if face != "" else ""]
		"enter":
			return "ENTER %s %s %s %d%s" % [who, b.from, _spot_name(b.x), int(b.speed), amp]
		"exit":
			return "EXIT %s %s %d%s" % [who, b.to, int(b.speed), amp]
		"move":
			return "MOVE %s %s %d%s" % [who, _spot_name(b.x), int(b.speed), amp]
		"face":
			return "FACE %s %s" % [who, String(b.target).to_upper() if b.get("target", "") != "" else b.dir]
		"emote":
			return "EMOTE %s %s" % [who, b.emotion]
		"hold":
			return "HOLD %s %s" % [who, b.prop if b.prop != "" else "none"]
		"jump":
			return "JUMP %s" % who
		"camera":
			match b.mode:
				"close": return "CLOSE %s" % who
				"medium": return "MEDIUM %s" % who
			return "WIDE"
		"shake":
			return "SHAKE %s" % _num(b.time)
		"wait":
			return "WAIT %s" % _num(b.time)
		"sfx":
			return "SFX %s" % b.name
		"music":
			var v: int = b.get("variant", 1)
			return "MUSIC %s%s" % [b.mood, (" %d" % v) if v > 1 and b.mood != "off" else ""]
		"card":
			return "CARD %s" % _one_line(b.text)
		"title":
			return "TITLE"
		"end":
			return "END %s" % _one_line(b.get("text", "The End"))
	return "# (unknown beat)"


static func _spot_name(x: float) -> String:
	for k in EpisodeScript.SPOTS:
		if absf(EpisodeScript.SPOTS[k] - x) < 0.5:
			return k
	return str(roundi(x))


static func _num(v: float) -> String:
	return str(snappedf(v, 0.1))


static func _one_line(s: String) -> String:
	return s.replace("\r", " ").replace("\n", " ").strip_edges()
