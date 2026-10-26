# Shlank — Cartoon Theater

A Godot 4.7.2 "movie" game: you build characters, locations and scripted
episodes, and the player sits back and watches them play out like a cartoon.
Everything is drawn with code in a 2D Flash-cartoon style (flat colours, bold
ink outlines, cel shading, tweened "puppet" animation), and every line of
dialogue is voiced with a speech synthesizer.

**Play it in your browser:** `https://username846.github.io/Shlank/`
(published automatically by GitHub Actions on every push to `main`; see
*Deploying* below for the one-time setup).

## What's in it

Five shows, 61 locations and 37 characters, with a ~5 minute episode for each
show:

- **Bikini Bottom** (SpongeBob parodies)
  - Characters: SpongeBert, Pat Starfish, Squidwerd, Mr. Crabs, Sandy Acorn,
    Plankton, Karen, Mrs. Puff, Pearl, Gary and Larry the Lobster.
  - Locations: SpongeBert's Pineapple, SpongeBert's Living Room, Pat's Rock,
    Squidwerd's Head House, The Krusty Crab, the Krusty Crab Dining Room and
    Kitchen, Sandy's Treedome, Jellyfish Fields, Goo Lagoon, The Chum Bucket,
    Boating School, Downtown Bikini Bottom, Glove World, Kelp Forest and Rock
    Bottom.
  - Episode: **"The Golden Spatula"**.
- **Hillwood** (Hey Arnold! parodies)
  - Characters: Arnald, Helga Potaki, Gerold, Grandpa Phil, Phoebee, Grandma
    Pookie, Harold, Stinky, Sid, Rhonda and Big Bob.
  - Locations: Sunset Arms, the Boarding House Kitchen, Arnald's Room, P.S.
    118, the Fourth Grade Classroom, the School Cafeteria, Gerold Field, Big
    Bob's Beepers, Slausen's Ice Cream, Green Meats, Hillwood Pier, a Rooftop
    at Dusk, Hillwood Street, Hillwood Park and Hillwood Alley.
  - Episode: **"The Locket"**.
- **Bluffington** (Doug parodies)
  - Characters: Dug Funnie, Skeetor, Patty Mayonaise, Rodger Klotz and
    Porkchop.
  - Locations: The Funnie House, Dug's Room, Bluffington Elementary, the
    School Hallway, The Honker Burger, Lucky Duck Lake, Beebe's Mansion, Mr.
    Dink's Yard, Downtown Bluffington and Bluffington Park.
  - Episode: **"The Beets Tickets"**.
- **Playpen** (Rugrats parodies)
  - Characters: Tommi Pickles, Chuckey Finster, Angelika Pickles, Phill
    DeVille and Lill DeVille.
  - Locations: the Pickles Living Room, Backyard and Kitchen, Tommi's
    Nursery, Stu's Basement, The Playground, Reptarland, Java Lava, the
    Supermarket and Finster House.
  - Episode: **"The Great Cookie Quest"**.
- **Pokemon** (Team Rocket parodies)
  - Characters: Jessee, Jaymes, Meowt, Wobbafett and The Boss.
  - Locations: Forest Path, Team Rokket HQ, the Monster Clinic, the Clinic
    Lobby, Town Square, Crystal Cave, Sunny Beach, Cliff Top, Rokket Camp and
    the Mecha Lab.
  - Episode: **"The Golden Snack Ball"**.

Every character blinks, lip-flaps while talking, walks, hops, holds props, and
has 10 emotions (neutral, happy, sad, angry, surprised, scared, smug, excited,
nervous, shy).

- **Synthesized voices.** Dialogue is spoken with the browser's text-to-speech
  voices, and each character has their own pitch, speed and preferred voices.
  If the browser has no speech voices, it falls back to a synthesized
  "cartoon babble". The music and sound effects are synthesized live too.
- Menus to meet the cast (preview emotions, props and voices), browse
  locations, and change settings (voice mode, subtitles, volume).

The **volume** and **fullscreen** buttons stay in the top-right corner on every
screen. The volume slider controls music, sound effects and voices together.

Controls while watching: **Space** pauses, **→ / Enter / click** skips the
current line, and **Esc** opens the pause menu. **F3** (or adding `?debug` to
the page URL) shows a performance overlay.

### Performance notes

Everything is vector-drawn, and in the browser every re-drawn shape costs a GPU
buffer upload, so the drawing is cached aggressively:

- Location sets are rendered once into a texture (`Backdrop`). Only the moving
  scenery is redrawn, at 15 fps, and bubbles are textured quads.
- Each character renders into its own offscreen texture (`Puppet`), which is
  only refreshed while something in the drawing changes (talking, walking,
  blinking), at most 15 fps. That's Flash-style animation "on twos". The
  smooth bob, hop and squash move the texture every frame.
- Offscreen renders are supersampled 2×, so they skip per-shape
  anti-aliasing.

## Making episodes in the app (Edit / Create)

**EDIT / CREATE** on the title screen opens your episode library:

- **+ New Episode**: pick an icon for it (a show badge, or a star, heart,
  film, music note, moon or lightning bolt) and start with a blank first
  scene. Episodes aren't tied to one show: use any characters and locations.
- **Edit**: opens any episode. A built-in episode you save becomes an
  "edited" copy, and **Reset** brings back the original.
- **Copy**: puts that episode's script on the clipboard.
- **Import from clipboard**: paste a script (Ctrl+V into the box, or the
  *Paste from clipboard* button) to add it to your library.

Your episodes are saved in your browser's local storage, so they survive
reloads. They also show up under *Watch Episodes*.

In the editor:

- **Top bar:** the episode name, **Info** (series, icon, episode number,
  description), **Save**, **Test Scene** (plays just the current scene),
  **Test Episode** (plays the whole episode; both bring you back) and
  **Export** (copies the script to the clipboard and shows it).
- **Scenes (left):** add, reorder and delete scenes. **Location** opens a
  window of thumbnails grouped by series. **Music** opens a list of every
  tune with a **Preview** button. **Transition** is the show's default, a
  hard cut, or any style (bubbles, iris, star wipe, heart, slide,
  checkerboard, pinwheel, fade).
- **Stage (middle):** shows the scene at the playhead's moment. **Drag a
  character** to make them walk there at that moment. While an entrance or
  walk is selected, a see-through **ghost** shows where the character will
  end up; drag the ghost to change it.
- **Beat settings (right):** **+ Add Beat** inserts dialogue, narration,
  entrances and exits, walks, emotions, props, jumps, camera shots, shakes,
  pauses, sound effects, music changes and title/text/end cards. Selecting a
  beat lets you change who, what, where and how fast, or move it earlier or
  later. **Character** (and **Put on stage...** when no beat is selected)
  opens a window of character portraits grouped by series.
- **Timeline (bottom):** colored blocks for everything that takes time and
  dots for instant changes. Click a beat to edit it, click or drag the strip
  (or the scrub bar) to move through the scene, and press **>** to preview the
  movement.

## Writing episodes by hand

Episodes are plain-text screenplays in `data/episodes/`. Each one is listed in
`data/episodes/index.json`. Example:

```
@title The Golden Spatula
@series Bikini Bottom
@icon bubbles
@number 1
@description One-line blurb for the episode list.

MUSIC happy
SCENE pineapple_house cut
TITLE
NARRATOR: Ah, Bikini Bottom.
ENTER spongebert left center
SPONGEBERT (excited): Today's the Krusty Crab Patty Cook-Off!
CLOSE spongebert
SPONGEBERT (scared): It's gone!
WIDE
RUN spongebert offright
```

**Dialogue:** `NAME (emotion): text`. `NAME` is a character id or name
(`SPONGEBERT`, `PAT`, `MR_CRABS`, `DUG`, `TOMMI`, `JESSEE`, `NARRATOR`, ...). The
emotion is optional and stays until it's changed.

**Positions** are pixel x values (0–1280) or the named spots `offleft`,
`farleft`, `left`, `midleft`, `center`, `midright`, `right`, `farright`,
`offright`.

| Command | What it does |
|---|---|
| `SCENE <location> [cut\|style]` | Changes the set and clears the stage. Uses the show's transition, a hard `cut`, or a style: `bubbles`, `iris`, `star`, `heart`, `slide`, `checker`, `pinwheel`, `fade` |
| `PLACE <who> <pos> [left\|right] [emotion]` | Puts a character on stage instantly |
| `ENTER <who> <left\|right> <pos> [speed] [emotion]` | Walks on from that side, wearing that expression |
| `EXIT <who> <left\|right> [speed]` | Walks off stage |
| `MOVE <who> <pos> [speed]` / `RUN <who> <pos>` | Walks or runs to a position |
| `FACE <who> <left\|right\|other-character>` | Turns around |
| `EMOTE <who> <emotion>` | Changes expression |
| `HOLD <who> <prop\|none>` | Props: `golden_spatula`, `spatula`, `patty`, `net`, `clarinet`, `detector`, `money`, `locket`, `ice_cream`, `fishing_rod`, `beeper` |
| `JUMP <who>` | Hop with a boing |
| `CLOSE <who>` / `MEDIUM <who>` / `WIDE` | Camera shots |
| `SHAKE [secs]` | Camera shake |
| `WAIT <secs>` | Pause |
| `SFX <name>` | `bubbles pop boing beep detector detector_crazy clarinet squeak slam sting splat sizzle ding cash fanfare wahwah drumroll whoosh gasp chomp sparkle` |
| `MUSIC <mood> [1-3]` | Background music: `happy`, `jazz`, `tense`, `sad`, `sneaky`, `spooky`, `action`, `romantic` (each has variants 1-3), or `off` |
| `CARD <text>` | Full-screen title card read by the narrator ("Ten minutes later...") |
| `TITLE` | Episode title card |
| `END [text]` | Closing card |

Adding `&` to the end of `ENTER`, `EXIT`, `MOVE` or `RUN` lets the next
command start straight away, so several characters can walk at once.
Lines starting with `#` are comments.

### Adding characters and locations

- Characters live in `data/characters.json`: name, show, home location (the
  backdrop in the cast viewer), colour, bio, catchphrase
  and voice (`pitch`, `rate`, babble frequency, and a `prefer` list of
  speech-voice name keywords). Each `style` is drawn by a function in
  `scripts/puppet.gd` or `scripts/cast/cast_extra.gd`. Most of the newer
  people are built from `scripts/cast/human_rig.gd`, a configurable human
  (size, skin, hair, clothes, glasses, extras).
- Locations live in `data/locations.json` (with the show they belong to), and
  each is drawn by a function in `scripts/backdrop.gd` or
  `scripts/sets/sets_extra.gd`. Bikini Bottom sets get underwater light rays
  and bubbles; the others don't.
- Each show's scene transition lives in `data/shows.json`: any of the
  `SCENE` styles above (`iris` closes on whoever spoke last; shows without an
  entry get `fade`). Each show also sets the sound that plays with its
  transition, plus the badge on its episode cards (`icon`: `bubbles`, `city`,
  `journal`, `bottle`, `rokket`, `star`, `heart`, `film`, `note`, `moon` or
  `bolt`). A show without an
  icon gets its initials on a badge in its `color`.
- A new episode goes in `data/episodes/` and gets listed in
  `data/episodes/index.json`. Use `@series` to show the series name on the
  episode card and title card.

## Project layout

```
project.godot            Godot 4.7.2 project (GL Compatibility renderer, for the web)
scenes/main.tscn         Entry scene
scripts/main.gd          Menus: episodes, cast, locations, settings
scripts/episode_player.gd  Runs an episode: staging, camera, voices, subtitles
scripts/episode_script.gd  Parser for the screenplay format
scripts/puppet.gd        Vector-drawn animated characters
scripts/cast/            More character drawings and the configurable human rig
scripts/backdrop.gd      Vector-drawn animated locations
scripts/sets/            More location drawings
scripts/art.gd           Flash-style drawing helpers (outlines, cel shading)
scripts/game.gd          Autoload: data, settings, text-to-speech voices
scripts/synth.gd         Autoload: synthesized music, SFX and babble voice
scripts/ui/              Theme, per-show scene transitions, title cards, icon buttons
scripts/editor/          The in-app episode editor, its data model and the episode library
data/                    Characters, locations, episodes
tools/snapshot.gd        Dev tool that renders screens and episodes to PNGs
```

## Running locally

Open the folder in Godot 4.7.2 and press Play. To build the web version:

```
godot --headless --export-release "Web" build/web/index.html
```

The export uses the single-threaded web template, so it runs on plain static
hosting like GitHub Pages without special headers.

## Deploying

`.github/workflows/deploy.yml` downloads Godot 4.7.2, exports the web build
and publishes it to GitHub Pages on every push to `main`. One-time setup: in
the repository go to **Settings → Pages** and set **Source** to
**GitHub Actions**.

## Credits

Fonts: [Luckiest Guy](https://fonts.google.com/specimen/Luckiest+Guy) and
[Fredoka](https://fonts.google.com/specimen/Fredoka), both under the SIL Open
Font License. Characters and locations are affectionate parodies made for
testing.
