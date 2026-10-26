extends Node
## Global data + settings: characters, locations, episode list and the voice system.

const SETTINGS_PATH := "user://settings.cfg"

var characters: Dictionary = {}
var locations: Dictionary = {}
## Per-show presentation settings (scene transition and its sound).
var shows: Dictionary = {}
var episodes: Array = []

# Settings
var voice_mode := "auto"  # auto | tts | babble | silent
var subtitles := true
var music_volume := 0.5
var voice_volume := 0.9
## Overall volume from the always-visible volume button (music, effects and voices).
var master_volume := 0.8

var _tts_voices: Array = []
var _voice_cache: Dictionary = {}
var _last_voice_check := -100000

# The line being spoken, so a volume change can re-speak the rest of it louder or quieter.
var _line := {}  # id, text, base (chars already spoken before this utterance), volume, started, est
var _line_pos := 0  # last word boundary reported for the current utterance
var _utterance := 0
var _restart_at := -1  # msec; re-speak the line once the volume slider settles
var _speaking_until := 0  # msec; counts as speaking while silently "saying" a muted line
var _tts_paused_at := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	characters = _load_json("res://data/characters.json")
	locations = _load_json("res://data/locations.json")
	shows = _load_json("res://data/shows.json")
	var index = _load_json("res://data/episodes/index.json")
	episodes = index.get("episodes", []) if index is Dictionary else []
	_load_settings()
	refresh_voices()
	if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_BOUNDARY, _on_tts_boundary)


func _process(_delta: float) -> void:
	if _restart_at >= 0 and Time.get_ticks_msec() >= _restart_at and _tts_paused_at < 0:
		_restart_at = -1
		_respeak_rest()


func _load_json(path: String) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Missing data file: %s" % path)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed == null:
		push_error("Invalid JSON: %s" % path)
		return {}
	return parsed


func load_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	return f.get_as_text() if f else ""


func char_color(id: String) -> Color:
	return Color(String(characters.get(id, {}).get("color", "#ffffff")))


# ------------------------------------------------------------- settings --

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		voice_mode = cfg.get_value("audio", "voice_mode", voice_mode)
		subtitles = cfg.get_value("video", "subtitles", subtitles)
		music_volume = cfg.get_value("audio", "music_volume", music_volume)
		voice_volume = cfg.get_value("audio", "voice_volume", voice_volume)
		master_volume = cfg.get_value("audio", "master_volume", master_volume)
	apply_settings()


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "voice_mode", voice_mode)
	cfg.set_value("video", "subtitles", subtitles)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "voice_volume", voice_volume)
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.save(SETTINGS_PATH)
	apply_settings()


func apply_settings() -> void:
	Synth.music_volume = music_volume
	Synth.sfx_volume = 0.8
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master_volume, 0.0001)))
	AudioServer.set_bus_mute(0, master_volume <= 0.001)
	# Text-to-speech doesn't go through Godot's audio buses: the volume is fixed
	# when a line starts, so re-speak the rest of the current line.
	if not _line.is_empty() and absf(float(_line.volume) - _tts_volume()) > 0.001 and is_speaking():
		_restart_at = Time.get_ticks_msec() + 250


# ---------------------------------------------------------------- voice --

func refresh_voices() -> void:
	_tts_voices = []
	_voice_cache.clear()
	if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		_tts_voices = DisplayServer.tts_get_voices()


func tts_available() -> bool:
	# Browsers load voices asynchronously; re-check now and then, not every frame.
	if _tts_voices.is_empty() and Time.get_ticks_msec() - _last_voice_check > 2000:
		_last_voice_check = Time.get_ticks_msec()
		refresh_voices()
	return not _tts_voices.is_empty()


## The voice mode actually in effect right now.
func effective_voice_mode() -> String:
	match voice_mode:
		"silent", "babble":
			return voice_mode
		"tts":
			return "tts" if tts_available() else "babble"
	return "tts" if tts_available() else "babble"


func voice_name_for(id: String) -> String:
	if not tts_available():
		return ""
	var v := _voice_for(id)
	for d in _tts_voices:
		if d.get("id", "") == v:
			return String(d.get("name", v))
	return v


func _voice_for(id: String) -> String:
	if _voice_cache.has(id):
		return _voice_cache[id]
	var prefs: Array = characters.get(id, {}).get("voice", {}).get("prefer", [])
	var used := _voice_cache.values()
	var best := ""
	var best_score := -9999.0
	var has_local := false
	for d in _tts_voices:
		var n := String(d.get("name", "")).to_lower()
		if String(d.get("language", "")).to_lower().begins_with("en") and not n.begins_with("google"):
			has_local = true
	for d in _tts_voices:
		var vid := String(d.get("id", ""))
		var vname := String(d.get("name", "")).to_lower()
		var lang := String(d.get("language", "")).to_lower()
		var score := 0.0
		# Chrome's online "Google ..." voices ignore the volume a page asks for,
		# so voices installed on the device win whenever there are any.
		if vname.begins_with("google") and has_local:
			score -= 40.0
		if lang.begins_with("en"):
			score += 20.0
		if lang.begins_with("en-us") or lang.begins_with("en_us"):
			score += 2.0
		for i in prefs.size():
			if vname.contains(String(prefs[i]).to_lower()):
				score += 12.0 - i
		if used.has(vid):
			score -= 6.0
		if vname.contains("novelty") or vname.contains("whisper") or vname.contains("bells"):
			score -= 30.0
		if score > best_score:
			best_score = score
			best = vid
	_voice_cache[id] = best
	return best


## Starts speaking a line. Returns a minimum duration estimate in seconds.
func speak(id: String, text: String) -> float:
	var clean := clean_for_speech(text)
	var est := estimate_line(clean)
	var mode := effective_voice_mode()
	var v: Dictionary = characters.get(id, {}).get("voice", {})
	_line = {}
	_restart_at = -1
	_speaking_until = 0
	match mode:
		"tts":
			DisplayServer.tts_stop()
			_line = {"id": id, "text": clean, "base": 0, "volume": _tts_volume(),
				"started": Time.get_ticks_msec(), "est": est}
			_say(clean, 0)
		"babble":
			var dur := Synth.babble(clean, float(v.get("babble", 300.0)), float(v.get("rate", 1.0)))
			est = maxf(est * 0.8, dur + 0.25)
	return est


func is_speaking() -> bool:
	if effective_voice_mode() == "tts":
		return DisplayServer.tts_is_speaking() or Time.get_ticks_msec() < _speaking_until
	return false


func stop_speaking() -> void:
	_line = {}
	_restart_at = -1
	_speaking_until = 0
	if not _tts_voices.is_empty():
		DisplayServer.tts_stop()


func pause_speaking(p: bool) -> void:
	if effective_voice_mode() == "tts":
		if p:
			_tts_paused_at = Time.get_ticks_msec()
			DisplayServer.tts_pause()
		else:
			if _tts_paused_at >= 0:
				var paused := Time.get_ticks_msec() - _tts_paused_at
				if not _line.is_empty():
					_line.started += paused
				if _speaking_until > 0:
					_speaking_until += paused
			_tts_paused_at = -1
			DisplayServer.tts_resume()


func _tts_volume() -> float:
	return clampf(voice_volume * master_volume, 0.0, 1.0)


## Speaks `text` (which starts `base` characters into the current line) at the current volume.
## A muted line isn't spoken, but still counts as speaking for as long as it would take.
func _say(text: String, base: int) -> void:
	_line.base = base
	_line.volume = _tts_volume()
	_line_pos = 0
	_utterance += 1
	var vol := int(round(_tts_volume() * 100.0))
	if vol <= 0:
		_speaking_until = Time.get_ticks_msec() + int(estimate_line(text) * 1000.0)
		return
	# Keep is_speaking() true across the gap before the browser starts the new utterance.
	_speaking_until = Time.get_ticks_msec() + 600 if base > 0 else 0
	var v: Dictionary = characters.get(_line.id, {}).get("voice", {})
	DisplayServer.tts_speak(text, _voice_for(_line.id), vol, float(v.get("pitch", 1.0)),
		float(v.get("rate", 1.0)), _utterance)


func _on_tts_boundary(pos: int, utterance_id: int) -> void:
	if utterance_id == _utterance:
		_line_pos = pos


## Re-speaks the unspoken part of the current line at the new volume.
func _respeak_rest() -> void:
	if _line.is_empty() or not is_speaking():
		return
	var text: String = _line.text
	var at: int = _line.base + _line_pos
	if _line_pos == 0:
		# No word boundaries from this voice: guess from how long it has been talking.
		var frac := float(Time.get_ticks_msec() - int(_line.started)) / (float(_line.est) * 1000.0)
		at = maxi(at, int(clampf(frac, 0.0, 1.0) * text.length()))
	# Back up to the start of the word.
	while at > 0 and at < text.length() and text[at - 1] != " ":
		at -= 1
	var rest := text.substr(at).strip_edges()
	if rest.is_empty():
		return
	DisplayServer.tts_stop()
	_say(rest, at)


static func clean_for_speech(text: String) -> String:
	var re := RegEx.create_from_string("\\*[^*]*\\*")
	return re.sub(text, "", true).strip_edges()


## Seconds a line takes at a natural reading/speaking pace.
static func estimate_line(text: String) -> float:
	var words := text.split(" ", false).size()
	return 0.35 + words / 3.2 + text.count(",") * 0.1 + (text.count(".") + text.count("!") + text.count("?")) * 0.12
