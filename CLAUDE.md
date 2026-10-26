# Shlank: notes for Claude

- Work directly on `main` (no branches). Godot 4.7.2, GL Compatibility, single-threaded web export.
- **Adding a show:** give it the same amount as the existing shows: 11 characters, 15 locations,
  its own scene transition, transition sound and badge icon (`data/shows.json`), and five ~5 minute
  episodes (about 75 lines and 12-14 scenes each; check runtimes with
  `tools/snapshot.tscn -- /tmp estimate_files data/episodes/<file>.txt ...`).
  Use the show's real name as the series name and lightly misspelled parody names for characters.
- Characters: `data/characters.json` + a drawing in `scripts/cast/` (most people are `HumanRig` settings).
  Locations: `data/locations.json` + a drawing in `scripts/sets/`. Episodes: `data/episodes/` + `index.json`.
- Kirbie only ever says "Poyo!" and variations.
