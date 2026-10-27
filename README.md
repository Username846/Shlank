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

Eleven shows, each with 16 or more characters (180 in all), 25 or more locations
(276 in all), its own scene transition and badge, and two seasons of ten ~5 minute
episodes (220 in all). Browse them under *Watch Episodes*, *Meet the Cast* and
*Locations*, which each start with a series picker; *Watch Episodes* then asks for
a season.

- **SpongeBob SquarePants**. Season 1: **"The Golden Spatula"**, **"The Jellyfish Jamboree"**, **"Plankton's Perfect Plan"**, **"Test Number Sixty-Seven"**, **"The Last Bus from Glove World"**, **"Squidward's Day Off"**, **"Sandy's Rocket"**, **"Gary, Come Home"**, **"Pearl's Sweet Sixteen"**, **"The Fancy Chum Bucket"**. Season 2: **"The Invisible Boatmobile"**, **"Shady Shoals Talent Night"**, **"Tough Enough"**, **"Employee of the Hut"**, **"Mr. Krabs' First Dollar"**, **"The Best House on the Block"**, **"Lifeguard on Duty"**, **"The Royal Cook-Off"**, **"Quiet in the Library"**, **"Krabs in the Hospital"**.
  SpongeBob, Patrick Star, Squidward, Mr. Krabs, Sandy Cheeks, Plankton, Karen, Mrs. Puff, Pearl, Gary, Larry the Lobster, Mermaid Man, Barnacle Boy, Squilliam Fancyson, Bubble Bass and King Neptune.
- **Hey Arnold!**. Season 1: **"The Locket"**, **"The Big Game"**, **"Grandma's Treasure Map"**, **"The Ghost of Hillwood Alley"**, **"The Beeper Blowout"**, **"Science Partners"**, **"Grandpa's Big Fish"**, **"Rhonda's Fashion Show"**, **"The Neighborhood Garden"**, **"The Secret Poet"**. Season 2: **"Olga Comes Home"**, **"Saving Mighty Pete"**, **"Dinner at Chez Paris"**, **"The Dinoland Field Trip"**, **"A Night at the Hillwood Museum"**, **"Lost on the Subway"**, **"The Spring Dance"**, **"The Long Bus Ride"**, **"Eugene on Ice"**, **"Dinner at the Patakis'"**.
  Arnold, Helga Pataki, Gerald, Grandpa Phil, Phoebe, Grandma Pookie, Harold, Stinky, Sid, Rhonda, Big Bob, Eugene Horowitz, Lila Sawyer, Olga Pataki, Mr. Simmons and Curly.
- **Doug**. Season 1: **"The Beets Tickets"**, **"Quailman and the Science Fair"**, **"The School Play"**, **"Mr. Dink's Robot"**, **"Funnie for President"**, **"Best in Show"**, **"The Quailman Comic"**, **"Save the Honker Burger"**, **"Judy's Art Show"**, **"Picture Day"**. Season 2: **"Skeeter's Surprise"**, **"Dinner at Patti's"**, **"Roger's Cat"**, **"Two Dougs Are Better Than One"**, **"Lost at the Mall"**, **"Dodgeball Day"**, **"Stuck in Bluff Tower"**, **"The Garage Band"**, **"The Bluffington Fair"**, **"Quailman: The Movie"**.
  Doug Funnie, Skeeter, Patti Mayonnaise, Roger Klotz, Porkchop, Judy Funnie, Beebe Bluff, Mr. Dink, Connie Benge, Chalky Studebaker, Mr. Bone, Theda Funnie, Phil Funnie, Al Sleech, Moo Sleech and Ned Cauphee.
- **Rugrats**. Season 1: **"The Great Cookie Quest"**, **"Lost in Reptarland"**, **"Dil's Big Day"**, **"The Monster in the Attic"**, **"The Big Talent Show"**, **"The Supermarket Sweep"**, **"Grandpa's Teeth"**, **"Angelica's Sleepover"**, **"Stu's Big Invention"**, **"The Great Duck Pond Voyage"**. Season 2: **"Chuckie's New Sister"**, **"Dig to China"**, **"Angelica's Big House"**, **"Worm Day"**, **"A Day at the Zoo"**, **"Beach Day"**, **"Up, Up and Away"**, **"Under the Big Top"**, **"The Tooth Fairy"**, **"Reptar on Ice"**.
  Tommy Pickles, Chuckie Finster, Angelica Pickles, Phil DeVille, Lil DeVille, Stu Pickles, Didi Pickles, Grandpa Lou, Spike, Susie Carmichael, Dil Pickles, Betty DeVille, Howard DeVille, Chas Finster, Drew Pickles, Charlotte Pickles, Kira Finster and Kimi Finster.
- **Pokémon**. Season 1: **"The Golden Poké Ball"**, **"Pikachu, I Choose You!"**, **"Splash Battle at Cerulean Gym"**, **"The Great Pokémon Cook-Off"**, **"The Boss Takes a Vacation"**, **"Officer Jenny's Day Off"**, **"Brock's Big Date"**, **"Wobbuffet, Champion"**, **"The Crystal Cave"**, **"The Last Blast Off"**. Season 2: **"Welcome Home, Ash"**, **"Lost in Viridian Forest"**, **"The Pewter Gym Rematch"**, **"The Moon Stone"**, **"All Aboard the S.S. Anne"**, **"The Ghost of Pokémon Tower"**, **"Shopping Spree"**, **"Safari Zone Showdown"**, **"Volcano Trouble on Cinnabar Island"**, **"The Indigo League"**.
  Jessie, James, Meowth, Wobbuffet, Giovanni, Ash Ketchum, Pikachu, Misty, Brock, Nurse Joy, Officer Jenny, Professor Oak, Gary Oak, Delia Ketchum, Psyduck, Togepi and Jigglypuff.
- **Dragon Ball Z**. Season 1: **"What's Your Power Level?"**, **"Goku Gets a License"**, **"Lunch on Snake Way"**, **"The Perfect Talk Show"**, **"Vegeta's Surprise Party"**, **"Gohan's Homework"**, **"The Dragon Ball Hunt"**, **"Krillin's Big Date"**, **"A Warning from the Future"**, **"The World Martial Arts Tournament"**. Season 2: **"The Great Saiyaman"**, **"Videl Learns to Fly"**, **"Mr. Satan's Big Secret"**, **"Inside Babidi's Ship"**, **"Buu Wants Candy"**, **"The Z Sword"**, **"Pilaf's Revenge"**, **"Red Ribbon Leftovers"**, **"King Kai's Joke Contest"**, **"Buu's Big Day"**.
  Goku, Vegeta, Gohan, Piccolo, Krillin, Bulma, Master Roshi, Frieza, Cell, Trunks, Chi-Chi, Majin Buu, Videl, Mr. Satan, Goten, King Kai and Yamcha.
- **Attack on Titan**. Season 1: **"The Last Potato"**, **"Inspection Day"**, **"The Runaway Horse"**, **"Titan School"**, **"Field Trip to the Ocean"**, **"Captain Levi's Tea Party"**, **"Sasha's Hunting Lesson"**, **"Painting the Wall"**, **"Reiner's Secret"**, **"The Scout Games"**. Season 2: **"Krista's Secret"**, **"Connie's Hometown"**, **"Annie's Kicking Lessons"**, **"Hannes on Duty"**, **"A Night at Utgard Castle"**, **"The Crystal Cave"**, **"Market Day in Karanes"**, **"The Royal Tea Party"**, **"Historia's Farm"**, **"Across the Sea"**.
  Eren Jaeger, Mikasa Ackerman, Armin Arlert, Captain Levi, Hange Zoë, Jean Kirstein, Sasha Braus, Connie Springer, Reiner, Commander Erwin, Smiling Titan, Historia Reiss, Ymir, Annie Leonhart, Bertolt Hoover and Hannes.
- **Breaking Bad**. Season 1: **"The Blue Candy"**, **"Pizza on the Roof"**, **"The Mineral Show"**, **"Saul Goes Viral"**, **"Father and Son Science Fair"**, **"Jesse's Band"**, **"Schraderbräu"**, **"Mike Goes Fishing"**, **"Saul's Grand Opening"**, **"The Health Inspector"**. Season 2: **"Gale's Karaoke Night"**, **"Saul's Storage Unit"**, **"Bingo Night at Casa Tranquila"**, **"Vamonos Pest"**, **"Stakeout at the Dog House"**, **"Take Me Out to the Ball Game"**, **"Mike's Leaky Sink"**, **"The Madrigal Taste Test"**, **"Four Corners"**, **"Buried Treasure"**.
  Walter White, Jesse Pinkman, Skyler White, Hank Schrader, Marie Schrader, Flynn, Saul Goodman, Gus Fring, Mike Ehrmantraut, Badger, Skinny Pete, Gale Boetticher, Huell, Steve Gomez, Hector Salamanca and Francesca.
- **Super Mario Brothers** (the Super Mario games). Season 1: **"In Another Castle"**, **"The Rainbow Road Grand Prix"**, **"Luigi's Spooky Rescue"**, **"Yoshi's Egg Hunt"**, **"Bowser's Day Off"**, **"Toad's Big Delivery"**, **"Daisy's Tennis Cup"**, **"Wario's Gold Rush"**, **"The Banana Mystery"**, **"Peach to the Rescue"**. Season 2: **"Waluigi Time"**, **"Rosalina's Lost Luma"**, **"Bowser Jr.'s Big Plan"**, **"Luigi's Mansion"**, **"Vacation in Delfino"**, **"Toadette's Treasure Map"**, **"Moo Moo Kart"**, **"Yoshi's Egg Day"**, **"Coconut Mall Madness"**, **"The Donut Plains Picnic"**.
  Mario, Luigi, Princess Peach, Princess Daisy, Wario, Toad, Bowser, Yoshi, Donkey Kong, Goomba, Koopa Troopa, Waluigi, Rosalina, Bowser Jr., King Boo and Toadette.
- **Metroid** (the Metroid games). Season 1: **"Babysitting"**, **"Who Stole the Gunship?"**, **"Double Trouble"**, **"Kraid's Toothache"**, **"The Chozo Trial"**, **"The Space Pirate Quits"**, **"The Lost Etecoons"**, **"Ridley's Birthday"**, **"Emergency Drill"**, **"Mother Brain Retires"**. Season 2: **"Hey There, Princess"**, **"Phantoon's Quiet Night"**, **"Torizo's Rules"**, **"Crocomire's Fear"**, **"Snow Day on Phendrana"**, **"The Bottle Ship"**, **"Return to SR388"**, **"The SkyTown Delivery"**, **"Dark Samus Takes a Vacation"**, **"Trouble in the Phazon Mines"**.
  Samus Aran, Dark Samus, Ridley, Kraid, Mother Brain, Baby Metroid, Adam Malkovich, Chozo Elder, Space Pirate, Etecoon, Dachora, Anthony Higgs, Phantoon, Crocomire, Draygon and Torizo.
- **Kirby** (the Kirby games). Season 1: **"The Great Cake Heist"**, **"Ribbon's Crystal"**, **"Meta Knight's Sword School"**, **"The Royal Diet"**, **"The Living Paintings"**, **"Waddle Dee's Day Off"**, **"Magolor's Starship"**, **"Marx's Big Wish"**, **"The Ice Cream Festival"**, **"Whispy Can't Sleep"**. Season 2: **"Kirby's Animal Friends"**, **"Gooey Goo"**, **"Showdown on Mt. DeDeDe"**, **"Beach Day on Float Islands"**, **"The Raisin Ruins Riddle"**, **"Iceberg Adventure"**, **"Moonlight Mansion"**, **"Waddle Dee Town"**, **"Mirror, Mirror"**, **"Susie's Takeover"**.
  Kirby, King Dedede, Meta Knight, Waddle Dee, Bandana Dee, Waddle Doo, Magolor, Marx, Adeleine, Ribbon, Whispy Woods, Rick, Kine, Coo, Gooey and Susie.

Kirby only ever says "Poyo!" (and variations), and Samus Aran rarely says
anything at all.

Every character blinks, lip-flaps while talking, walks, hops, holds props, and
has 10 emotions (neutral, happy, sad, angry, surprised, scared, smug, excited,
nervous, shy).

- **Synthesized voices.** Dialogue is spoken with the browser's text-to-speech
  voices, and each character has their own pitch, speed and preferred voices.
  If the browser has no speech voices, it falls back to a synthesized
  "cartoon babble". The music and sound effects are synthesized live too.
- Menus to meet the cast (preview emotions, props and voices), browse
  locations, and change settings (voice mode, subtitles, volume).

The **autoplay**, **volume** and **fullscreen** buttons stay in the top-right
corner on every screen. The volume slider controls music, sound effects and
voices together. With autoplay on (the button turns yellow), the next episode in
the series starts five seconds after one ends (after a season's last episode, the
next season's first); the end screen also has a **Next Episode** button either way.

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

**EDIT / CREATE** on the title screen opens your episode library. Like
*Watch Episodes*, it starts with a series picker and then a season picker; your own
episodes (new and imported ones) are under **Yours**, and leaving the editor brings
you back to the list you came from:

- **+ New Episode**: pick an icon for it (a show badge, or a star, heart,
  film, music note, moon or lightning bolt) and start with a blank first
  scene. Episodes aren't tied to one show: use any characters and locations.
- **Edit**: opens any episode. A built-in episode you save becomes an
  "edited" copy, and **Reset** brings back the original.
- **Copy**: puts that episode's script on the clipboard.
- **Import from clipboard**: paste a script (Ctrl+V into the box, or the
  *Paste from clipboard* button) to add it to your library.

Your episodes are saved in your browser's local storage, so they survive
reloads. They also show up under *Watch Episodes*, in the *Yours* section (an edited
copy of a built-in episode stays with its series).

In the editor:

- **Top bar:** the episode name, **Info** (series, season, episode number, icon,
  description), **Save**, **Test Scene** (plays just the current scene),
  **Test Episode** (plays the whole episode; both bring you back) and
  **Export** (copies the script to the clipboard and shows it).
- **Scenes (left):** add, reorder and delete scenes. **Location** opens a
  window of thumbnails grouped by series. **Music** opens a list of every
  tune with a **Preview** button. **Transition** is the show's default, a
  hard cut, or any style (bubbles, iris, star wipe, heart, slide,
  checkerboard, pinwheel, energy flash, blade slash, pixels, blast door,
  fade).
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
@series SpongeBob SquarePants
@season 1
@icon bubbles
@number 1
@description One-line blurb for the episode list.

MUSIC happy
SCENE pineapple_house cut
TITLE
NARRATOR: Ah, Bikini Bottom.
ENTER spongebob left center
SPONGEBOB (excited): Today's the Krabby Patty Cook-Off!
CLOSE spongebob
SPONGEBOB (scared): It's gone!
WIDE
RUN spongebob offright
```

**Dialogue:** `NAME (emotion): text`. `NAME` is a character id or name
(`SPONGEBOB`, `PATRICK`, `MR_KRABS`, `DOUG`, `TOMMY`, `JESSIE`, `NARRATOR`, ...). The
emotion is optional and stays until it's changed.

**Positions** are pixel x values (0–1280) or the named spots `offleft`,
`farleft`, `left`, `midleft`, `center`, `midright`, `right`, `farright`,
`offright`.

| Command | What it does |
|---|---|
| `SCENE <location> [cut\|style]` | Changes the set and clears the stage. Uses the show's transition, a hard `cut`, or a style: `bubbles`, `iris`, `star`, `heart`, `slide`, `checker`, `pinwheel`, `flash`, `slash`, `pixel`, `door`, `fade` |
| `PLACE <who> <pos> [left\|right] [emotion]` | Puts a character on stage instantly |
| `ENTER <who> <left\|right> <pos> [speed] [emotion]` | Walks on from that side, wearing that expression |
| `EXIT <who> <left\|right> [speed]` | Walks off stage |
| `MOVE <who> <pos> [speed]` / `RUN <who> <pos>` | Walks or runs to a position |
| `FACE <who> <left\|right\|other-character>` | Turns around |
| `EMOTE <who> <emotion>` | Changes expression |
| `HOLD <who> <prop\|none>` | Any of the 200+ props in `scripts/props.gd` (e.g. `golden_spatula`, `book`, `cake`, `sword`, `phone`). The editor and cast viewer group them into 12 categories: Food, Drinks, Kitchen, Tools, Music, Gadgets, Paper & Books, Treasure, Sports & Toys, Adventure, Everyday and Nature |
| `JUMP <who>` | Hop with a boing |
| `CLOSE <who>` / `MEDIUM <who>` / `WIDE` | Camera shots |
| `SHAKE [secs]` | Camera shake |
| `WAIT <secs>` | Pause |
| `SFX <name>` | `bubbles pop boing beep detector detector_crazy clarinet squeak slam sting splat sizzle ding cash fanfare wahwah drumroll whoosh gasp chomp sparkle blast sword thud coin powerup jump_8bit hiss laser` |
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
  `scripts/puppet.gd`, `scripts/cast/cast_extra.gd` or `scripts/cast/cast_more.gd`. Most of the newer
  people are built from `scripts/cast/human_rig.gd`, a configurable human
  (size, skin, hair, clothes, glasses, extras).
- When a character, location, show or built-in episode is renamed, its old
  ids and names go in an `aka` list (in its JSON entry, or its `index.json`
  entry), so episodes people saved earlier still load.
- Locations live in `data/locations.json` (with the show they belong to), and
  each is drawn by a function in `scripts/backdrop.gd`,
  `scripts/sets/sets_extra.gd` or `scripts/sets/sets_more.gd`. SpongeBob SquarePants sets get underwater light rays
  and bubbles; the others don't.
- Each show's scene transition lives in `data/shows.json`: any of the
  `SCENE` styles above (`iris` closes on whoever spoke last; shows without an
  entry get `fade`). Each show also sets the sound that plays with its
  transition, plus the badge on its episode cards (`icon`: `bubbles`, `city`,
  `journal`, `bottle`, `rocket`, `star`, `heart`, `film`, `note`, `moon` or
  `bolt`). A show without an
  icon gets its initials on a badge in its `color`.
- A new episode goes in `data/episodes/` and gets listed in
  `data/episodes/index.json`. Use `@series` to show the series name on the
  episode card and title card, and `@season` (default 1) to put it in a season;
  the pickers show ten episodes per season.

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
