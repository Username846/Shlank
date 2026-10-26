extends Node
## Dev check: every mood/variant sequences cleanly for a full loop.
func _ready() -> void:
	var n := 0
	for m in Synth.MOODS:
		for v in [1, 2, 3]:
			Synth.set_mood(m, v)
			Synth._block_offset = 0
			for i in 64:
				Synth._music_step()
			var song: Dictionary = Synth.SONGS[m][v - 1]
			assert(song.chords.size() == 4 and song.melody.size() == 32, "%s %d" % [m, v])
			n += 1
	Synth.set_mood("off")
	print("MUSIC OK: %d tunes (%d moods x 3)" % [n, Synth.MOODS.size()])
	get_tree().quit()
