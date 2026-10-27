# Shlank: notes for Claude

- Work directly on `main` (no branches). Godot 4.7.2, GL Compatibility, single-threaded web export.
- **Adding a show:** give it the same amount as the existing shows: 16 characters, 25 locations,
  its own scene transition, transition sound and badge icon (`data/shows.json`), and two seasons of
  ten ~5 minute episodes (`@season` 1 and 2, `@number` 1-10 in each; seasons hold ten episodes each;
  about 70 lines and 13-14 scenes each; check runtimes with
  `tools/snapshot.tscn -- /tmp estimate_files data/episodes/<file>.txt ...`).
- **Adding a season:** add new characters freely, and give each new episode at least one new location.
  Season 2 drawings live in `scripts/cast/cast_s2.gd` and `scripts/sets/sets_s2.gd`.
  Use the show's real name as the series name and the characters' real names (no soundalikes). Renamed
  characters keep their old ids/names in `aka` so saved episodes still load.
- Characters: `data/characters.json` + a drawing in `scripts/cast/` (most people are `HumanRig` settings).
  Locations: `data/locations.json` + a drawing in `scripts/sets/`. Episodes: `data/episodes/` + `index.json`.
- Kirby only ever says "Poyo!" and variations.
