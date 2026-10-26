extends Node
## Global data + settings: characters, locations, episode list and the voice system.

const SETTINGS_PATH := "user://settings.cfg"

var characters: Dictionary = {}
var locations: Dictionary = {}
var episodes: Array = []

# Settings
var voice_mode := "auto"  # auto | tts | babble | silent
var subtitles := true
var music_volume := 0.5
var voice_volume := 0.9

var _tts_voices: Array = []
var _voice_cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	characters = _load_json("res://data/characters.json")
	locations = _load_json("res://data/locations.json")
	var index = _load_json("res://data/episodes/index.json")
	episodes = index.get("episodes", []) if index is Dictionary else []
	_load_settings()
	refresh_voices()


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
	apply_settings()


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "voice_mode", voice_mode)
	cfg.set_value("video", "subtitles", subtitles)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "voice_volume", voice_volume)
	cfg.save(SETTINGS_PATH)
	apply_settings()


func apply_settings() -> void:
	Synth.music_volume = music_volume
	Synth.sfx_volume = 0.8


# ---------------------------------------------------------------- voice --

func refresh_voices() -> void:
	_tts_voices = []
	_voice_cache.clear()
	if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		_tts_voices = DisplayServer.tts_get_voices()


func tts_available() -> bool:
	if _tts_voices.is_empty():
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
	for d in _tts_voices:
		var vid := String(d.get("id", ""))
		var vname := String(d.get("name", "")).to_lower()
		var lang := String(d.get("language", "")).to_lower()
		var score := 0.0
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
	match mode:
		"tts":
			DisplayServer.tts_stop()
			DisplayServer.tts_speak(clean, _voice_for(id), int(voice_volume * 100.0),
				float(v.get("pitch", 1.0)), float(v.get("rate", 1.0)))
		"babble":
			var dur := Synth.babble(clean, float(v.get("babble", 300.0)), float(v.get("rate", 1.0)))
			est = maxf(est * 0.8, dur + 0.25)
	return est


func is_speaking() -> bool:
	if effective_voice_mode() == "tts":
		return DisplayServer.tts_is_speaking()
	return false


func stop_speaking() -> void:
	if not _tts_voices.is_empty():
		DisplayServer.tts_stop()


func pause_speaking(p: bool) -> void:
	if effective_voice_mode() == "tts":
		if p:
			DisplayServer.tts_pause()
		else:
			DisplayServer.tts_resume()


static func clean_for_speech(text: String) -> String:
	var re := RegEx.create_from_string("\\*[^*]*\\*")
	return re.sub(text, "", true).strip_edges()


## Seconds a line takes at a natural reading/speaking pace.
static func estimate_line(text: String) -> float:
	var words := text.split(" ", false).size()
	return 0.35 + words / 3.2 + text.count(",") * 0.1 + (text.count(".") + text.count("!") + text.count("?")) * 0.12
