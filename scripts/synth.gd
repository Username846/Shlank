extends Node
## Tiny software synthesizer: background music, sound effects and the
## "babble" voice used when the browser has no text-to-speech voices.

const RATE := 22050.0

enum Wave { SINE, TRIANGLE, SQUARE, NOISE, PLUCK }

class Note:
	var freq := 440.0
	var phase := 0.0
	var t := 0.0
	var dur := 0.2
	var wave := 0
	var vol := 0.3
	var attack := 0.005
	var decay := 0.0
	var slide := 1.0
	var vib := 0.0
	var vib_rate := 6.0
	var music := false
	var wait := 0  # samples to wait before starting

var music_volume := 0.5
var sfx_volume := 0.8
var mood := "off"

var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _notes: Array[Note] = []
var _noise := 0x1234
var _step := 0
var _step_t := 0.0  # seconds from the start of the next block until the next music step
var _block_offset := 0  # sample offset of the music step being scheduled

## Every mood has 3 variants. Optional per-song keys: "strum" / "bass" (which of
## the 8 eighth-note steps per bar they play on), "lead" (melody waveform) and
## "vib" (melody vibrato depth).
const MOODS := ["happy", "jazz", "tense", "sad", "sneaky", "spooky", "action", "romantic"]
const SONGS := {
	"happy": [
		{"bpm": 112, "chords": [[60, 64, 67], [57, 60, 64], [53, 57, 60], [55, 59, 62]],
			"melody": [72, -1, 76, 74, 72, -1, 69, -1, 69, -1, 72, 69, 67, -1, -1, -1, 65, -1, 69, 72, 74, -1, 72, -1, 71, -1, 67, -1, 74, 72, 71, -1]},
		{"bpm": 124, "lead": "square", "chords": [[55, 59, 62], [60, 64, 67], [62, 66, 69], [55, 59, 62]],
			"melody": [67, -1, 71, 74, -1, 71, 67, -1, 72, -1, 76, -1, 72, 71, 69, -1, 74, -1, 78, -1, 76, 74, 72, -1, 71, -1, 67, -1, 67, -1, -1, -1]},
		{"bpm": 104, "lead": "triangle", "strum": [0, 2, 4, 6], "chords": [[53, 57, 60], [50, 53, 57], [46, 50, 53], [48, 52, 55]],
			"melody": [72, -1, 69, -1, 72, 74, 77, -1, 74, -1, 72, -1, 69, -1, -1, -1, 70, -1, 74, -1, 77, -1, 74, -1, 72, -1, 76, -1, 79, -1, -1, -1]},
	],
	"jazz": [
		{"bpm": 116, "chords": [[50, 53, 57, 60], [55, 59, 62, 65], [48, 52, 55, 59], [57, 61, 64, 67]],
			"melody": [69, -1, 72, -1, 74, 72, 69, -1, 67, -1, 71, -1, 74, -1, 77, -1, 76, -1, 72, -1, 67, -1, 64, -1, 69, -1, 73, 76, -1, 73, 69, -1]},
		{"bpm": 100, "lead": "triangle", "chords": [[48, 52, 55, 59], [57, 61, 64, 67], [50, 53, 57, 60], [55, 59, 62, 65]],
			"melody": [76, -1, 74, 72, -1, 69, -1, 67, 69, -1, 73, -1, 76, -1, -1, -1, 77, -1, 76, 74, 72, -1, 69, -1, 71, -1, 74, -1, 77, 76, 74, -1]},
		{"bpm": 132, "strum": [0, 3, 6], "chords": [[53, 57, 60, 64], [55, 58, 62, 65], [57, 60, 64, 67], [48, 52, 55, 58]],
			"melody": [72, -1, -1, 76, -1, 72, 69, -1, 70, -1, 74, -1, -1, 70, 67, -1, 72, -1, 76, -1, 79, -1, 76, -1, 70, -1, 72, -1, -1, -1, -1, -1]},
	],
	"tense": [
		{"bpm": 96, "chords": [[57, 60, 64], [53, 57, 60], [52, 56, 59], [57, 60, 64]],
			"melody": [69, -1, -1, 68, 69, -1, 72, -1, 71, -1, 69, -1, 65, -1, -1, -1, 64, -1, 68, -1, 71, -1, 68, -1, 69, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 120, "lead": "square", "strum": [0, 2, 4, 6], "chords": [[52, 55, 59], [48, 52, 55], [47, 51, 54], [52, 55, 59]],
			"melody": [64, -1, 64, -1, 67, -1, 66, -1, 64, -1, -1, -1, 60, -1, 59, -1, 59, -1, 63, -1, 66, -1, 63, -1, 64, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 84, "strum": [0, 4], "chords": [[50, 53, 57], [46, 50, 53], [43, 46, 50], [45, 49, 52]],
			"melody": [62, -1, -1, -1, 65, -1, 64, -1, 62, -1, -1, -1, 58, -1, -1, -1, 55, -1, 58, -1, 62, -1, 61, -1, 57, -1, -1, -1, -1, -1, -1, -1]},
	],
	"sad": [
		{"bpm": 76, "chords": [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]],
			"melody": [76, -1, 74, -1, 72, -1, -1, -1, 69, -1, 72, -1, 67, -1, -1, -1, 64, -1, 67, -1, 72, -1, 71, -1, 67, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 70, "lead": "triangle", "strum": [0, 4], "chords": [[48, 52, 55], [52, 55, 59], [57, 60, 64], [53, 57, 60]],
			"melody": [67, -1, -1, -1, 64, -1, 62, -1, 64, -1, -1, -1, -1, -1, -1, -1, 69, -1, -1, -1, 67, -1, 64, -1, 65, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 66, "strum": [0], "chords": [[50, 53, 57], [55, 58, 62], [48, 52, 55], [53, 57, 60]],
			"melody": [69, -1, -1, 67, 65, -1, -1, -1, 67, -1, -1, 65, 62, -1, -1, -1, 64, -1, -1, 62, 60, -1, -1, -1, 65, -1, -1, -1, -1, -1, -1, -1]},
	],
	"sneaky": [
		{"bpm": 100, "chords": [[50, 53, 57], [50, 53, 57], [52, 55, 58], [49, 52, 56]],
			"melody": [62, -1, 65, -1, -1, -1, 62, -1, 64, -1, 67, -1, -1, -1, 64, -1, 62, -1, 65, -1, 69, -1, 68, -1, 65, -1, -1, -1, 61, -1, -1, -1]},
		{"bpm": 92, "lead": "square", "strum": [2, 6], "chords": [[45, 48, 52], [45, 48, 52], [52, 56, 59], [45, 48, 52]],
			"melody": [57, -1, 59, -1, 60, -1, -1, -1, 59, -1, 57, -1, 56, -1, -1, -1, 57, -1, 59, -1, 60, -1, 62, -1, 64, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 108, "lead": "triangle", "strum": [0, 6], "chords": [[48, 51, 55], [48, 51, 55], [44, 48, 51], [43, 47, 50]],
			"melody": [60, -1, -1, 63, -1, -1, 60, -1, 58, -1, -1, 60, -1, -1, -1, -1, 56, -1, -1, 60, -1, -1, 63, -1, 62, -1, -1, -1, 59, -1, -1, -1]},
	],
	"spooky": [
		{"bpm": 80, "vib": 0.02, "strum": [0], "chords": [[45, 48, 52], [41, 44, 48], [45, 48, 52], [40, 44, 47]],
			"melody": [69, -1, -1, 68, -1, -1, 69, -1, 72, -1, -1, -1, 71, -1, -1, -1, 68, -1, -1, 65, -1, -1, 64, -1, 68, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 96, "lead": "square", "vib": 0.01, "strum": [0, 3], "chords": [[50, 53, 57], [49, 52, 55], [50, 53, 57], [46, 50, 53]],
			"melody": [62, -1, 65, -1, 69, -1, 68, -1, 67, -1, -1, -1, 64, -1, -1, -1, 62, -1, 65, -1, 69, -1, 73, -1, 74, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 70, "vib": 0.025, "strum": [0], "chords": [[40, 43, 47], [36, 40, 43], [40, 43, 47], [35, 39, 42]],
			"melody": [76, -1, -1, -1, 75, -1, -1, -1, 72, -1, -1, -1, 71, -1, -1, -1, 76, -1, 79, -1, 78, -1, -1, -1, 75, -1, -1, -1, -1, -1, -1, -1]},
	],
	"action": [
		{"bpm": 150, "lead": "square", "strum": [0, 1, 2, 3, 4, 5, 6, 7], "bass": [0, 2, 4, 6], "chords": [[52, 55, 59], [50, 54, 57], [48, 52, 55], [50, 54, 57]],
			"melody": [64, 64, -1, 67, -1, 64, 71, -1, 69, 69, -1, 67, -1, 66, 64, -1, 67, 67, -1, 71, -1, 72, 71, -1, 69, -1, 66, -1, 62, -1, -1, -1]},
		{"bpm": 140, "lead": "square", "strum": [0, 2, 3, 4, 6, 7], "bass": [0, 2, 4, 6], "chords": [[45, 48, 52], [41, 45, 48], [43, 47, 50], [45, 48, 52]],
			"melody": [69, -1, 72, -1, 76, -1, 72, -1, 77, -1, 76, -1, 72, -1, 69, -1, 71, -1, 74, -1, 79, -1, 77, -1, 76, -1, -1, 72, -1, 69, -1, -1]},
		{"bpm": 160, "lead": "triangle", "strum": [0, 1, 2, 3, 4, 5, 6, 7], "bass": [0, 2, 4, 6], "chords": [[48, 51, 55], [46, 50, 53], [44, 48, 51], [46, 50, 53]],
			"melody": [72, -1, 72, 75, -1, 72, 70, -1, 70, -1, 70, 74, -1, 70, 67, -1, 68, -1, 68, 72, -1, 68, 67, -1, 70, -1, -1, -1, 74, -1, -1, -1]},
	],
	"romantic": [
		{"bpm": 72, "vib": 0.006, "strum": [0, 2, 4, 6], "chords": [[53, 57, 60], [57, 60, 64], [58, 62, 65], [60, 64, 67]],
			"melody": [69, -1, -1, 72, -1, -1, 77, -1, 76, -1, -1, 72, -1, -1, -1, -1, 74, -1, -1, 77, -1, -1, 81, -1, 79, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 66, "lead": "triangle", "strum": [0, 3, 4, 6], "chords": [[48, 52, 55], [45, 48, 52], [50, 53, 57], [43, 47, 50]],
			"melody": [76, -1, -1, -1, 74, -1, 72, -1, 72, -1, -1, -1, 69, -1, -1, -1, 74, -1, -1, -1, 72, -1, 71, -1, 67, -1, -1, -1, -1, -1, -1, -1]},
		{"bpm": 84, "vib": 0.006, "chords": [[51, 55, 58], [48, 51, 55], [44, 48, 51], [46, 50, 53]],
			"melody": [67, -1, 70, -1, 75, -1, -1, -1, 74, -1, 72, -1, 67, -1, -1, -1, 68, -1, 72, -1, 75, -1, 77, -1, 75, -1, -1, -1, -1, -1, -1, -1]},
	],
}

const LEAD_WAVES := {"sine": Wave.SINE, "triangle": Wave.TRIANGLE, "square": Wave.SQUARE}

var variant := 1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = RATE
	# Generous buffer: the mixer runs on the main thread, so it must survive a slow frame.
	gen.buffer_length = 0.35
	_player = AudioStreamPlayer.new()
	_player.stream = gen
	# Web builds default to "sample" playback, which can't play generated audio.
	_player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback()


## Switches the background music. `v` picks one of the mood's 3 variants.
func set_mood(m: String, v: int = 1) -> void:
	m = m.to_lower()
	if m != "off" and not SONGS.has(m):
		m = "happy"
	v = clampi(v, 1, 3)
	if m == mood and (m == "off" or v == variant):
		return
	mood = m
	variant = v
	_step = 0
	_step_t = 0.0
	for n in _notes:
		if n.music:
			n.dur = minf(n.dur, n.t + 0.05)


func stop_all() -> void:
	_notes.clear()


func _process(_delta: float) -> void:
	if _playback == null:
		return
	var frames := _playback.get_frames_available()
	if frames <= 0:
		return
	var block := frames / RATE
	# Schedule the music steps that fall inside this block, sample-accurately.
	if mood != "off":
		while _step_t < block:
			_block_offset = int(_step_t * RATE)
			_music_step()
		_step_t -= block
	_block_offset = 0
	var mix := PackedFloat32Array()
	mix.resize(frames)
	var k := 0
	while k < _notes.size():
		var n := _notes[k]
		_render(n, mix)
		if n.t >= n.dur:
			_notes.remove_at(k)
		else:
			k += 1
	var buf := PackedVector2Array()
	buf.resize(frames)
	for f in frames:
		var v := clampf(mix[f], -1.0, 1.0)
		buf[f] = Vector2(v, v)
	_playback.push_buffer(buf)


## Adds one note into the mix buffer (kept to local variables: this is the hot loop).
func _render(n: Note, mix: PackedFloat32Array) -> void:
	var count := mix.size()
	if n.wait >= count:
		n.wait -= count
		return
	var i := n.wait
	n.wait = 0
	var dt := 1.0 / RATE
	var t := n.t
	var dur := n.dur
	var phase := n.phase
	var wave := n.wave
	var gain := n.vol * (music_volume if n.music else sfx_volume)
	var attack := n.attack
	var amp := exp(-t * n.decay) if n.decay > 0.0 else 1.0
	var dk := exp(-n.decay * dt) if n.decay > 0.0 else 1.0
	var fr := n.freq * pow(n.slide, t) if n.slide != 1.0 else n.freq
	var fk := pow(n.slide, dt) if n.slide != 1.0 else 1.0
	var vib := n.vib
	var vib_w := TAU * n.vib_rate
	var noise := _noise
	while i < count and t < dur:
		var f := fr
		if vib > 0.0:
			f *= 1.0 + sin(t * vib_w) * vib
		phase += f * dt
		if phase >= 1.0:
			phase -= floorf(phase)
		var o := 0.0
		if wave == Wave.SINE:
			o = sin(phase * TAU)
		elif wave == Wave.TRIANGLE:
			o = 4.0 * absf(phase - 0.5) - 1.0
		elif wave == Wave.SQUARE:
			o = 0.6 if phase < 0.5 else -0.6
		elif wave == Wave.NOISE:
			noise = (noise * 1103515245 + 12345) & 0x7fffffff
			o = float(noise) / 1073741824.0 - 1.0
		else:
			o = (4.0 * absf(phase - 0.5) - 1.0) * 0.7 + sin(phase * TAU * 2.0) * 0.3
		var env := amp
		if t < attack:
			env *= t / attack
		var rel := dur - t
		if rel < 0.03:
			env *= rel / 0.03
		mix[i] += o * env * gain
		amp *= dk
		fr *= fk
		t += dt
		i += 1
	n.t = t
	n.phase = phase
	_noise = noise


func note(freq: float, dur: float, wave: int = Wave.SINE, vol: float = 0.3, decay: float = 0.0,
		slide: float = 1.0, vib: float = 0.0, delay: float = 0.0, music: bool = false) -> void:
	var n := Note.new()
	n.freq = freq
	n.dur = dur
	n.wave = wave
	n.vol = vol
	n.decay = decay
	n.slide = slide
	n.vib = vib
	n.music = music
	n.wait = _block_offset + int(delay * RATE)
	_notes.append(n)


static func midi(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)


func _music_step() -> void:
	var song: Dictionary = SONGS[mood][variant - 1]
	var step_len: float = 60.0 / float(song.bpm) / 2.0
	_step_t += step_len
	var bar := (_step / 8) % 4
	var pos := _step % 8
	var chord: Array = song.chords[bar]
	# Ukulele strum
	if pos in song.get("strum", [0, 3, 4, 6]):
		for j in chord.size():
			_add_music(midi(chord[j] + 12), 0.5, Wave.PLUCK, 0.06, 7.0, j * 0.012)
	# Bass: root, then the fifth on alternate hits
	var bass: Array = song.get("bass", [0, 4])
	var bi := bass.find(pos)
	if bi >= 0:
		_add_music(midi(chord[0] - 12 + (7 if bi % 2 == 1 else 0)), 0.35, Wave.TRIANGLE, 0.16, 5.0)
	# Melody
	var m: int = song.melody[_step % song.melody.size()]
	if m > 0:
		var wave: int = LEAD_WAVES.get(song.get("lead", "sine"), Wave.SINE)
		_add_music(midi(m), 0.4, wave, 0.09 if wave == Wave.SINE else 0.06, 6.0, 0.0, song.get("vib", 0.004))
	# Soft shaker
	if pos % 2 == 1:
		_add_music(1.0, 0.04, Wave.NOISE, 0.025, 60.0)
	_step += 1


func _add_music(freq: float, dur: float, wave: int, vol: float, decay: float, delay: float = 0.0, vib: float = 0.0) -> void:
	note(freq, dur, wave, vol, decay, 1.0, vib, delay, true)


# ------------------------------------------------------------------ SFX --

func sfx(name: String) -> void:
	match name.to_lower():
		"bubbles", "bubble":
			for i in 14:
				note(randf_range(500, 1100), 0.08, Wave.SINE, 0.18, 10.0, 6.0, 0.0, i * 0.045)
		"pop":
			note(600, 0.09, Wave.SINE, 0.3, 8.0, 12.0)
		"boing":
			note(180, 0.5, Wave.SINE, 0.35, 3.0, 2.2, 0.08)
		"beep":
			note(1320, 0.12, Wave.SQUARE, 0.15)
		"detector":
			for i in 4:
				note(900 + i * 220, 0.08, Wave.SQUARE, 0.13, 0.0, 1.0, 0.0, i * 0.16)
		"detector_crazy":
			for i in 14:
				note(1000 + (i % 3) * 400, 0.05, Wave.SQUARE, 0.13, 0.0, 1.0, 0.0, i * 0.07)
		"clarinet":
			var seq := [62, 64, 61, 67, 66, 62, 70, 59]
			for i in seq.size():
				note(midi(seq[i]), 0.26, Wave.SQUARE, 0.12, 0.5, 1.0 if i % 3 else 1.06, 0.02, i * 0.24)
		"squeak":
			note(1600, 0.25, Wave.SQUARE, 0.12, 2.0, 1.6, 0.05)
		"slam", "door":
			note(1, 0.25, Wave.NOISE, 0.45, 14.0)
			note(70, 0.2, Wave.SINE, 0.5, 12.0, 0.5)
		"sting", "zap":
			note(1400, 0.35, Wave.SQUARE, 0.14, 4.0, 0.15, 0.08)
			note(1, 0.3, Wave.NOISE, 0.2, 8.0)
		"splat", "splash":
			note(1, 0.35, Wave.NOISE, 0.35, 9.0)
			note(240, 0.25, Wave.SINE, 0.3, 8.0, 0.2)
		"sizzle":
			for i in 10:
				note(1, 0.12, Wave.NOISE, 0.08, 12.0, 1.0, 0.0, i * 0.1)
		"ding":
			note(1760, 0.8, Wave.SINE, 0.25, 4.0)
			note(2640, 0.6, Wave.SINE, 0.1, 6.0)
		"cash", "register":
			note(1568, 0.3, Wave.SINE, 0.25, 6.0)
			note(2093, 0.6, Wave.SINE, 0.25, 4.0, 1.0, 0.0, 0.12)
			note(1, 0.15, Wave.NOISE, 0.2, 20.0, 1.0, 0.0, 0.1)
		"fanfare":
			var seq := [60, 64, 67, 72, 67, 72]
			var lens := [0.12, 0.12, 0.12, 0.35, 0.12, 0.7]
			var tt := 0.0
			for i in seq.size():
				note(midi(seq[i]), lens[i] + 0.05, Wave.SQUARE, 0.12, 1.5, 1.0, 0.006, tt)
				note(midi(seq[i] - 12), lens[i] + 0.05, Wave.TRIANGLE, 0.15, 1.5, 1.0, 0.0, tt)
				tt += lens[i]
		"wahwah", "sad_trombone":
			var seq := [58, 57, 56, 55]
			for i in seq.size():
				note(midi(seq[i] - 12), 0.42 if i < 3 else 1.0, Wave.SQUARE, 0.13, 0.6, 1.0, 0.02 if i == 3 else 0.0, i * 0.42)
		"drumroll":
			for i in 24:
				note(1, 0.05, Wave.NOISE, 0.1 + i * 0.006, 30.0, 1.0, 0.0, i * 0.05)
			note(1, 0.4, Wave.NOISE, 0.4, 7.0, 1.0, 0.0, 1.22)
			note(110, 0.4, Wave.SINE, 0.4, 6.0, 0.6, 0.0, 1.22)
		"slide_whistle":
			note(1400, 0.55, Wave.SINE, 0.22, 0.5, 0.25, 0.012)
		"whoosh":
			note(1, 0.4, Wave.NOISE, 0.2, 4.0)
			note(300, 0.4, Wave.SINE, 0.12, 3.0, 3.0)
		"gasp":
			note(500, 0.25, Wave.TRIANGLE, 0.2, 4.0, 2.5)
		"step", "footstep":
			note(140, 0.06, Wave.SINE, 0.25, 30.0, 0.5)
		"chomp":
			for i in 3:
				note(1, 0.07, Wave.NOISE, 0.3, 30.0, 1.0, 0.0, i * 0.16)
				note(160, 0.07, Wave.SQUARE, 0.12, 30.0, 0.6, 0.0, i * 0.16)
		"sparkle":
			for i in 6:
				note(midi(84 + [0, 4, 7, 12, 16, 19][i]), 0.3, Wave.SINE, 0.12, 6.0, 1.0, 0.0, i * 0.06)
		"blast":
			note(220, 0.7, Wave.SQUARE, 0.1, 0.5, 4.0, 0.02)
			note(1, 0.6, Wave.NOISE, 0.4, 4.0, 1.0, 0.0, 0.6)
			note(60, 0.6, Wave.SINE, 0.5, 4.0, 0.5, 0.0, 0.6)
		"sword", "shing":
			note(2400, 0.4, Wave.TRIANGLE, 0.16, 5.0, 1.15)
			note(1, 0.12, Wave.NOISE, 0.18, 25.0)
		"thud", "stomp":
			note(55, 0.4, Wave.SINE, 0.6, 6.0, 0.6)
			note(1, 0.25, Wave.NOISE, 0.3, 12.0)
		"coin":
			note(midi(83), 0.08, Wave.SQUARE, 0.13)
			note(midi(88), 0.4, Wave.SQUARE, 0.13, 3.0, 1.0, 0.0, 0.08)
		"powerup":
			for i in 9:
				note(midi(60 + i * 3), 0.07, Wave.SQUARE, 0.12, 0.0, 1.0, 0.0, i * 0.055)
		"jump_8bit":
			note(300, 0.22, Wave.SQUARE, 0.12, 2.0, 3.0)
		"hiss":
			note(1, 0.5, Wave.NOISE, 0.22, 3.0)
			note(180, 0.4, Wave.SQUARE, 0.06, 3.0, 0.6, 0.0, 0.1)
		"laser":
			note(1800, 0.25, Wave.SQUARE, 0.12, 4.0, 0.25)
		"title":
			sfx("fanfare")
		_:
			push_warning("Unknown SFX: %s" % name)


## Animal-Crossing-style gibberish speech. Returns the duration in seconds.
func babble(text: String, base_freq: float, rate: float = 1.0) -> float:
	var syll := clampi(int(text.length() / 3.2), 2, 80)
	var gap := 0.095 / maxf(rate, 0.3)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(text)
	for i in syll:
		var f := base_freq * pow(2.0, rng.randf_range(-0.25, 0.3))
		if i == syll - 1 and text.ends_with("?"):
			f *= 1.35
		note(f, gap * 0.85, Wave.TRIANGLE, 0.16, 6.0, rng.randf_range(0.8, 1.25), 0.03, i * gap)
		note(f * 2.0, gap * 0.7, Wave.SQUARE, 0.03, 9.0, 1.0, 0.0, i * gap)
	return syll * gap
