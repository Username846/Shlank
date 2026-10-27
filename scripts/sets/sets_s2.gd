class_name SetsS2
extends RefCounted
## Season 2 locations (ten per show). SetsMore falls through to these for ids it
## doesn't draw. Uses the shared helpers in SetsMore, SetsExtra and Backdrop.

const W := Backdrop.W
const H := Backdrop.H
const PAD := Backdrop.PAD
const INK := Art.INK


static func draw_set(b: Backdrop, id: String) -> bool:
	match id:
		# SpongeBob SquarePants
		"mermalair": _mermalair(b)
		"shady_shoals": _shady_shoals(b)
		"salty_spitoon": _salty_spitoon(b)
		"weenie_hut": _weenie_hut(b)
		"shell_city": _shell_city(b)
		"barg_n_mart": _barg_n_mart(b)
		"mussel_beach": _mussel_beach(b)
		"poseidome": _poseidome(b)
		"bb_library": _bb_library(b)
		"bb_hospital": _bb_hospital(b)
		# Hey Arnold!
		"helga_room": _helga_room(b)
		"pataki_kitchen": _pataki_kitchen(b)
		"mighty_pete": _mighty_pete(b)
		"chez_paris": _chez_paris(b)
		"dinoland": _dinoland(b)
		"hillwood_museum": _hillwood_museum(b)
		"hillwood_subway": _hillwood_subway(b)
		"ps118_gym": _ps118_gym(b)
		"school_bus": _school_bus(b)
		"hillwood_rink": _hillwood_rink(b)
		# Doug
		"valentine_house": _valentine_house(b)
		"patti_house": _patti_house(b)
		"roger_trailer": _roger_trailer(b)
		"sleech_lab": _sleech_lab(b)
		"bluffington_mall": _bluffington_mall(b)
		"bluffington_gym": _bluffington_gym(b)
		"bluff_tower": _bluff_tower(b)
		"funnie_garage": _funnie_garage(b)
		"bluffington_fair": _bluffington_fair(b)
		"bluffington_cinema": _bluffington_cinema(b)
		# Rugrats
		"the_playpen": _the_playpen(b)
		"sandbox": _sandbox(b)
		"drew_house": _drew_house(b)
		"deville_house": _deville_house(b)
		"the_zoo": _the_zoo(b)
		"beach_day": _beach_day(b)
		"the_airport": _the_airport(b)
		"the_circus": _the_circus(b)
		"dentist_office": _dentist_office(b)
		"reptar_arena": _reptar_arena(b)
		_: return false
	return true


## Moving bits for Season 2 locations.
static func draw_fx(b: Backdrop, id: String) -> void:
	var ci := b.ci
	var t := b._t
	match id:
		"mermalair":
			for i in 6:
				var on := fmod(t * 2.0 + i * 0.7, 2.0) > 1.0
				Art.dot(ci, Vector2(400 + i * 90, 380), 9, Color("6fdc6a") if on else Color("e6452f"))
		"mussel_beach", "shady_shoals", "salty_spitoon", "weenie_hut", "shell_city", "poseidome":
			b._seaweed(70, 620, 110)
			b._seaweed(1220, 625, 130, Color("4cb04f"))
		"ps118_gym":
			for i in 10:
				var a := t * 1.5 + i * TAU / 10.0
				Art.dot(ci, Vector2(640 + cos(a) * 420, 380 + sin(a) * 120), 6, Color(1, 1, 1, 0.5))
		"hillwood_rink":
			for i in 30:
				var x := fmod(i * 97.0 + t * 15.0, W + 200) - 100
				var y := fmod(i * 53.0 + t * 60.0, H + 100) - 50
				Art.dot(ci, Vector2(x, y), 3, Color(1, 1, 1, 0.8))
		"dinoland":
			var a := t * 0.5
			for i in 6:
				var c := Vector2(1080, 260) + Vector2(cos(a + i * TAU / 6.0), sin(a + i * TAU / 6.0)) * 130
				Art.shape(ci, Art.rrect(Rect2(c - Vector2(18, 12), Vector2(36, 26)), 6), [Color("e6452f"), Color("f2c14e"), Color("4a78d0")][i % 3], 2.5)
		"sleech_lab":
			for i in 4:
				var k := fmod(t * 0.9 + i * 0.25, 1.0)
				Art.dot(ci, Vector2(250 + i * 40, 380 - k * 80), 6 * (1.0 - k) + 2, Color(0.6, 1.0, 0.5, 1.0 - k))
		"bluffington_fair":
			var a := t * 0.4
			for i in 8:
				var c := Vector2(1040, 250) + Vector2(cos(a + i * TAU / 8.0), sin(a + i * TAU / 8.0)) * 150
				Art.shape(ci, Art.rrect(Rect2(c - Vector2(16, 12), Vector2(32, 24)), 6), [Color("e6452f"), Color("5aa84a"), Color("f2c14e")][i % 3], 2.5)
		"beach_day":
			for i in 3:
				var y := 470.0 + i * 26.0 + sin(t * 1.6 + i) * 6.0
				Art.stroke(ci, Art.curve(Vector2(-PAD, y), Vector2(640, y - 10), Vector2(W + PAD, y), 16), 3.0, Color(1, 1, 1, 0.7))
			var gx := fmod(t * 60.0, W + 300) - 150
			Art.stroke(ci, PackedVector2Array([Vector2(gx - 22, 120), Vector2(gx, 132), Vector2(gx + 22, 120)]), 4.0)
		"the_airport":
			var px := fmod(t * 90.0, W + 600) - 300
			Art.shape(ci, Art.rrect(Rect2(px - 120, 180, 240, 34), 17), Color("f4f4f2"), 3.0)
			Art.shape(ci, PackedVector2Array([Vector2(px - 20, 196), Vector2(px + 30, 196), Vector2(px - 40, 250)]), Color("d0d4dc"), 3.0)
			Art.shape(ci, PackedVector2Array([Vector2(px - 120, 196), Vector2(px - 90, 196), Vector2(px - 130, 150)]), Color("e6452f"), 3.0)
		"the_circus":
			var sx := 640.0 + sin(t * 1.4) * 160.0
			Art.stroke(ci, PackedVector2Array([Vector2(640, 60), Vector2(sx, 230)]), 2.0)
			Art.shape(ci, Art.rrect(Rect2(sx - 40, 228, 80, 10), 3), Color("f2c14e"), 2.5)
		"reptar_arena":
			for i in 24:
				var k := fmod(i * 0.37 + t * 0.2, 1.0)
				Art.dot(ci, Vector2(fmod(i * 131.0, W), 40 + k * 500), 3, Color(0.8, 0.95, 1.0, 0.7 * (1.0 - k)))
		_: pass


# ------------------------------------------------------------ helpers --

static func _shelves(b: Backdrop, r: Rect2, wood: Color, items: Array, seed: int) -> void:
	Art.shape(b.ci, SetsExtra._rect(r), wood, 4.0, 0.1)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var rows := int(r.size.y / 70.0)
	for j in rows:
		var y := r.position.y + (j + 1) * r.size.y / rows
		Art.stroke(b.ci, PackedVector2Array([Vector2(r.position.x, y), Vector2(r.end.x, y)]), 4.0, wood.darkened(0.3))
		var x := r.position.x + 8
		while x < r.end.x - 20:
			var w := rng.randf_range(12, 26)
			var h := rng.randf_range(34, 54)
			var col: Color = items[rng.randi() % items.size()]
			Art.shape(b.ci, SetsExtra._rect(Rect2(x, y - h, w, h)), col, 2.0)
			x += w + 3


static func _columns(b: Backdrop, xs: Array, top_y: float, bottom_y: float, col: Color) -> void:
	for x in xs:
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 26, top_y, 52, bottom_y - top_y)), col, 4.0, 0.1)
		for k in 3:
			Art.stroke(b.ci, PackedVector2Array([Vector2(x - 12 + k * 12, top_y + 20), Vector2(x - 12 + k * 12, bottom_y - 10)]), 2.0,
				col.darkened(0.2))
		Art.shape(b.ci, Art.rrect(Rect2(x - 38, top_y - 18, 76, 20), 4), col, 3.5)
		Art.shape(b.ci, Art.rrect(Rect2(x - 36, bottom_y - 4, 72, 16), 4), col, 3.5)


# --------------------------------------------------- SpongeBob SquarePants --

static func _mermalair(b: Backdrop) -> void:
	SetsExtra._room(b, Color("1d3a6a"), Color("2a5590"), 560, Color("4a5a78"), "tile")
	# Giant computer
	Art.shape(b.ci, Art.rrect(Rect2(320, 140, 640, 290), 18), Color("8a96a3"), 5.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(360, 170, 560, 170), 10), Color("1f4f3a"), 4.0)
	for i in 5:
		Art.stroke(b.ci, PackedVector2Array([Vector2(380, 200 + i * 28), Vector2(880 - i * 40, 200 + i * 28)]), 3.0, Color("6fdc6a"))
	b._sign(Rect2(470, 60, 340, 64), "MERMALAIR", Color("f2852a"), Color.WHITE, 40)
	# Pipes and an empty spot where the Invisible Boatmobile is parked
	for x in [120, 1160]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, -PAD), Vector2(x, 560)]), 34, Color("6b7a8a"))
	Art.stroke(b.ci, Art.rrect(Rect2(980, 470, 220, 80), 30), 3.0, Color(1, 1, 1, 0.35))
	b._sign(Rect2(990, 420, 200, 36), "BOATMOBILE", Color("2a5590"), Color.WHITE, 20)


static func _shady_shoals(b: Backdrop) -> void:
	b._sea_sky(Color("4a8fd8"), Color("bfe8f2"))
	b._sand(580, Color("e8d9a8"))
	Art.shape(b.ci, Art.rrect(Rect2(240, 260, 800, 320), 20), Color("f2d9a8"), 5.0, 0.12)
	Art.shape(b.ci, PackedVector2Array([Vector2(210, 268), Vector2(640, 150), Vector2(1070, 268)]), Color("8fbf6a"), 5.0, 0.15)
	b._sign(Rect2(400, 200, 480, 56), "SHADY SHOALS", Color("6a4a8a"), Color.WHITE, 34)
	b._door(Rect2(590, 430, 100, 150), Color("8a5a36"))
	for x in [300, 460, 820, 980]:
		b._window(Rect2(x, 310, 90, 80), Color("f4f2ec"), Color("9ccbe8"))
	# Rocking chairs on the porch
	for x in [360, 900]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 40, 470, 80, 70), 8), Color("c48a4f"), 3.5)
		Art.stroke(b.ci, Art.arc_pts(Vector2(x, 548), 60, 18, 0, PI, 12), 5.0, Color("8a5a36"))


static func _salty_spitoon(b: Backdrop) -> void:
	b._sea_sky(Color("2a5a90"), Color("8fb8d0"), false)
	b._sand(585, Color("c8b890"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(200, 230, 880, 355)), Color("7a5a3a"), 5.0, 0.15)
	for i in 12:
		Art.stroke(b.ci, PackedVector2Array([Vector2(200 + i * 73, 230), Vector2(200 + i * 73, 585)]), 3.0, Color("5a3f28"))
	b._sign(Rect2(330, 150, 620, 70), "THE SALTY SPITOON", Color("3a2416"), Color("f2c14e"), 42)
	b._door(Rect2(570, 420, 140, 165), Color("4a3020"), false)
	b._sign(Rect2(540, 370, 200, 38), "TOUGH GUYS ONLY", Color("3a2416"), Color("f2c14e"), 20)
	# Anchor and a rope line
	for x in [400, 880]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 420), Vector2(x, 560)]), 10, Color("6b6b75"))
		Art.stroke(b.ci, Art.arc_pts(Vector2(x, 540), 34, 26, 0, PI, 10), 8.0, Color("6b6b75"))


static func _weenie_hut(b: Backdrop) -> void:
	b._sea_sky(Color("5fb0e8"), Color("d8f0f8"))
	b._sand(580, Color("f1dc9b"))
	Art.shape(b.ci, Art.rrect(Rect2(330, 300, 620, 280), 30), Color("f7c6d6"), 5.0, 0.12)
	Art.shape(b.ci, PackedVector2Array([Vector2(300, 310), Vector2(640, 210), Vector2(980, 310)]), Color("8fd0f6"), 5.0, 0.15)
	# Giant hot dog on the roof
	Art.blob(b.ci, Vector2(640, 170), 150, 34, Color("e6a24a"), 4.0)
	Art.blob(b.ci, Vector2(640, 158), 170, 18, Color("c8502a"), 3.5)
	b._sign(Rect2(420, 330, 440, 60), "WEENIE HUT JR'S", Color("e6452f"), Color.WHITE, 36)
	b._door(Rect2(590, 440, 100, 140), Color("8fd0f6"))
	for x in [400, 790]:
		b._window(Rect2(x, 420, 100, 80), Color.WHITE, Color("fbe6f2"))


static func _shell_city(b: Backdrop) -> void:
	b._sea_sky(Color("3a6fb0"), Color("d8c8e8"), false)
	b._sand(585, Color("e8d4b8"))
	var cols := [Color("f2a6b8"), Color("f2d9a8"), Color("c8a8e6"), Color("f6c87a")]
	for i in 7:
		var c := Vector2(60 + i * 200, 470 - (i % 2) * 70)
		var s := 1.0 + (i % 3) * 0.25
		Art.shape(b.ci, PackedVector2Array([c + Vector2(-90, 110) * s, c + Vector2(0, -150) * s, c + Vector2(90, 110) * s]),
			cols[i % cols.size()], 4.5, 0.15)
		for k in 4:
			Art.stroke(b.ci, PackedVector2Array([c + Vector2(-70 + k * 14, 100 - k * 60) * s, c + Vector2(70 - k * 14, 90 - k * 60) * s]), 3.0,
				cols[i % cols.size()].darkened(0.25))
	b._sign(Rect2(440, 120, 400, 70), "SHELL CITY", Color("6a4a8a"), Color("f2c14e"), 44)
	b._sign(Rect2(960, 470, 220, 50), "SOLD!", Color("e6452f"), Color.WHITE, 30)


static func _barg_n_mart(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f4f2ec"), Color("dfe6ea"), 560, Color("c8d0d8"), "tile")
	b._sign(Rect2(420, 40, 440, 70), "BARG'N-MART", Color("e6452f"), Color("f2c14e"), 44)
	var goods := [Color("e6452f"), Color("f2c14e"), Color("4a78d0"), Color("6fbf6a"), Color("f28cb8"), Color("f4f4f2")]
	for i in 4:
		_shelves(b, Rect2(-40 + i * 340, 150, 280, 400), Color("8fa0b0"), goods, 11 + i)
	b._sign(Rect2(1010, 130, 180, 46), "BARGAINS!", Color("f2c14e"), Color("e6452f"), 26)


static func _mussel_beach(b: Backdrop) -> void:
	b._sea_sky(Color("3f9fe8"), Color("d8f4fb"))
	b._sand(560, Color("f6e2a8"))
	# Lifeguard tower
	for x in [880, 1000]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 600), Vector2(940 + (x - 940) * 0.6, 330)]), 12, Color("f4f4f2"))
	Art.shape(b.ci, Art.rrect(Rect2(870, 260, 140, 80), 8), Color("e6452f"), 4.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(870, 312), "LIFEGUARD", 20, Color.WHITE, 4, HORIZONTAL_ALIGNMENT_CENTER, 140)
	# Weight bench and a barbell
	Art.shape(b.ci, Art.rrect(Rect2(200, 500, 220, 26), 8), Color("4a78d0"), 3.5)
	Art.limb(b.ci, PackedVector2Array([Vector2(160, 470), Vector2(460, 470)]), 8, Color("6b6b75"))
	for x in [170, 450]:
		Art.blob(b.ci, Vector2(x, 470), 18, 40, Color("2b2b33"), 3.0)
	b._sign(Rect2(480, 140, 320, 64), "MUSSEL BEACH", Color("f2c14e"), Color("e6452f"), 36)
	# Beach umbrella
	Art.limb(b.ci, PackedVector2Array([Vector2(640, 600), Vector2(640, 380)]), 6, Color("8a5a36"))
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 390), 110, 60, PI, TAU, 16), Color("f28cb8"), 4.0, 0.12)


static func _poseidome(b: Backdrop) -> void:
	b._sea_sky(Color("2a6fc0"), Color("b8e2f2"), false)
	b._sand(590, Color("e8dcc0"))
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 600), 640, 420, PI, TAU, 40), Color("e8e2d4"), 5.0, 0.1)
	_columns(b, [180, 380, 900, 1100], 250, 590, Color("f4f2ec"))
	b._sign(Rect2(420, 160, 440, 70), "THE POSEIDOME", Color("2a5590"), Color("f2c14e"), 40)
	# Royal box with a gold throne
	Art.shape(b.ci, Art.rrect(Rect2(540, 300, 200, 150), 12), Color("6a4a8a"), 4.0)
	Art.shape(b.ci, PackedVector2Array([Vector2(590, 450), Vector2(590, 330), Vector2(615, 350), Vector2(640, 320), Vector2(665, 350),
		Vector2(690, 330), Vector2(690, 450)]), Color("f2c14e"), 3.5, 0.12)


static func _bb_library(b: Backdrop) -> void:
	SetsExtra._room(b, Color("c8a878"), Color("a8865a"), 560, Color("8a5a36"))
	var books := [Color("e6452f"), Color("2f4f9a"), Color("3f8f3a"), Color("f2c14e"), Color("7a3fa0"), Color("c8642a")]
	for i in 4:
		_shelves(b, Rect2(-60 + i * 360, 120, 300, 430), Color("6b4428"), books, 21 + i)
	b._sign(Rect2(440, 40, 400, 60), "LIBRARY", Color("2f4f9a"), Color.WHITE, 38)
	b._sign(Rect2(520, 470, 240, 40), "QUIET PLEASE", Color("f4f2ec"), Color("3a2416"), 22)


static func _bb_hospital(b: Backdrop) -> void:
	SetsExtra._room(b, Color("e8f4f2"), Color("cfe6e2"), 560, Color("b8d0d8"), "tile")
	b._porthole(Vector2(640, 180), 70)
	# Red cross sign
	Art.shape(b.ci, Art.rrect(Rect2(140, 100, 120, 120), 10), Color.WHITE, 4.0)
	Art.shape(b.ci, SetsExtra._rect(Rect2(184, 116, 32, 88)), Color("e6452f"), 2.5)
	Art.shape(b.ci, SetsExtra._rect(Rect2(156, 144, 88, 32)), Color("e6452f"), 2.5)
	# Beds with a privacy curtain
	for x in [300, 980]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 120, 440, 240, 60), 10), Color.WHITE, 4.0)
		Art.shape(b.ci, Art.rrect(Rect2(x - 120, 410, 70, 40), 10), Color("dfe6ea"), 3.0)
		Art.limb(b.ci, PackedVector2Array([Vector2(x - 110, 500), Vector2(x - 110, 560)]), 8, Color("8a96a3"))
		Art.limb(b.ci, PackedVector2Array([Vector2(x + 110, 500), Vector2(x + 110, 560)]), 8, Color("8a96a3"))
	Art.shape(b.ci, Art.rrect(Rect2(1110, 120, 140, 440), 6), Color("8fd0c8"), 4.0)
	for i in 5:
		Art.stroke(b.ci, PackedVector2Array([Vector2(1120 + i * 28, 130), Vector2(1120 + i * 28, 550)]), 2.0, Color("6ab0a8"))
	b._sign(Rect2(470, 300, 340, 56), "HOSPITAL", Color("e6452f"), Color.WHITE, 34)


# ------------------------------------------------------------ Hey Arnold! --

static func _helga_room(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f7c6d6"), Color("f2a6c0"), 560, Color("c48a4f"))
	b._window(Rect2(500, 120, 200, 170), Color.WHITE, Color("9ccbe8"))
	# Bed with a pink cover, and a closet door with a big padlock
	Art.shape(b.ci, Art.rrect(Rect2(90, 430, 330, 110), 12), Color("f28cb8"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(90, 400, 90, 50), 12), Color.WHITE, 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(900, 160, 230, 400), 8), Color("c48a4f"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(990, 330, 50, 44), 8), Color("f2c14e"), 3.0)
	Art.stroke(b.ci, Art.arc_pts(Vector2(1015, 332), 16, 18, PI, TAU, 10), 5.0, Color("8a96a3"))
	b._sign(Rect2(860, 100, 300, 44), "KEEP OUT! THIS MEANS YOU!", Color.WHITE, Color("e6452f"), 18)
	# Desk with a stack of pink notebooks
	SetsExtra._table(b, 620, 440, 220, Color("c48a4f"))
	for k in 4:
		Art.shape(b.ci, Art.rrect(Rect2(570, 410 - k * 12, 90, 12), 3), Color("f28cb8").darkened(k * 0.06), 2.0)


static func _pataki_kitchen(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f2e6c8"), Color("e8d6a8"), 550, Color("9a8070"), "tile")
	b._window(Rect2(540, 120, 200, 140), Color.WHITE, Color("9ccbe8"))
	Art.shape(b.ci, Art.rrect(Rect2(980, 190, 170, 360), 16), Color("f4f2ec"), 4.0, 0.12)
	Art.stroke(b.ci, PackedVector2Array([Vector2(1000, 320), Vector2(1130, 320)]), 3.0)
	# Table with a beeper-shaped napkin holder, and a wall of Olga's trophies
	SetsExtra._table(b, 640, 430, 360, Color("c48a4f"))
	Art.shape(b.ci, Art.rrect(Rect2(610, 396, 60, 34), 6), Color("2b2b33"), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(120, 120, 300, 30), 4), Color("8a5a36"), 3.0)
	for k in 5:
		var x := 150 + k * 56
		Art.shape(b.ci, PackedVector2Array([Vector2(x - 14, 120), Vector2(x - 18, 80), Vector2(x + 18, 80), Vector2(x + 14, 120)]),
			Color("f2c14e"), 2.5)
	b._sign(Rect2(120, 170, 300, 40), "OLGA'S AWARDS", Color("f28cb8"), Color.WHITE, 22)


static func _mighty_pete(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	b._skyline(470, Color("a7bfd3"), 41)
	SetsExtra._grass(b, 540)
	# The giant tree with its treehouse
	Art.limb(b.ci, PackedVector2Array([Vector2(640, 600), Vector2(630, 300)]), 120, Color("8a5a2b"))
	for p in [Vector2(640, 150), Vector2(500, 210), Vector2(780, 210), Vector2(560, 110), Vector2(730, 110), Vector2(420, 280), Vector2(860, 280)]:
		Art.blob(b.ci, p, 120, 80, Color("4f9a3a"), 4.0, 0.12)
	Art.shape(b.ci, SetsExtra._rect(Rect2(540, 270, 200, 110)), Color("c48a4f"), 4.0, 0.15)
	Art.shape(b.ci, PackedVector2Array([Vector2(520, 274), Vector2(640, 210), Vector2(760, 274)]), Color("a24d38"), 4.0)
	b._window(Rect2(600, 300, 70, 50), Color("8a5a36"), Color("2b3a4a"))
	# Rope ladder
	for side in [-1, 1]:
		Art.stroke(b.ci, PackedVector2Array([Vector2(700 + side * 16, 380), Vector2(700 + side * 16, 580)]), 3.0, Color("c8a86a"))
	for k in 8:
		Art.stroke(b.ci, PackedVector2Array([Vector2(684, 400 + k * 24), Vector2(716, 400 + k * 24)]), 3.0, Color("c8a86a"))


static func _chez_paris(b: Backdrop) -> void:
	SetsExtra._room(b, Color("6a1f2f"), Color("8a2f3f"), 560, Color("2b1a1a"), "carpet")
	b._sign(Rect2(470, 50, 340, 70), "CHEZ PARIS", Color("2b1a1a"), Color("f2c14e"), 44)
	# Chandelier and two candlelit tables
	Art.stroke(b.ci, PackedVector2Array([Vector2(640, -PAD), Vector2(640, 150)]), 3.0, Color("f2c14e"))
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 150), 90, 40, 0, PI, 14), Color("f2c14e"), 3.5)
	for k in 5:
		Art.dot(b.ci, Vector2(560 + k * 40, 186), 6, Color("fff1b8"))
	for x in [300, 980]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 140, 430, 280, 30), 6), Color.WHITE, 4.0)
		Art.shape(b.ci, PackedVector2Array([Vector2(x - 130, 460), Vector2(x + 130, 460), Vector2(x + 110, 560), Vector2(x - 110, 560)]),
			Color.WHITE, 4.0)
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 430), Vector2(x, 380)]), 8, Color("f4f2ec"))
		Art.dot(b.ci, Vector2(x, 372), 7, Color("f2a65a"))
	for x in [140, 1140]:
		b._window(Rect2(x - 60, 160, 120, 200), Color("f2c14e"), Color("2b3a4a"))


static func _dinoland(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	SetsExtra._grass(b, 560, Color("8fd06a"))
	# Big wheel frame (the cars turn in the moving layer)
	b.ci.draw_arc(Vector2(1080, 260), 130, 0, TAU, 40, INK, 9.0)
	b.ci.draw_arc(Vector2(1080, 260), 130, 0, TAU, 40, Color("e6452f"), 5.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(1000, 580), Vector2(1080, 260), Vector2(1160, 580)]), 12, Color("8a96a3"))
	# Roller coaster hill
	Art.stroke(b.ci, Art.curve(Vector2(-PAD, 460), Vector2(250, -60), Vector2(560, 470), 24), 10.0, Color("4a78d0"))
	for i in 9:
		var x := 40.0 + i * 55.0
		Art.stroke(b.ci, PackedVector2Array([Vector2(x, 560), Vector2(x, 200 + absf(x - 250) * 0.9)]), 3.0, Color("8a96a3"))
	# Entrance arch with a dinosaur head
	Art.shape(b.ci, Art.rrect(Rect2(500, 330, 340, 70), 16), Color("6fbf6a"), 4.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(500, 380), "DINOLAND", 40, Color.WHITE, 7, HORIZONTAL_ALIGNMENT_CENTER, 340)
	Art.blob(b.ci, Vector2(670, 280), 70, 46, Color("6fbf6a"), 4.0, 0.12)
	Art.dot(b.ci, Vector2(700, 268), 8, INK)
	for x in [530, 810]:
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 15, 400, 30, 170)), Color("6fbf6a"), 4.0)


static func _hillwood_museum(b: Backdrop) -> void:
	SetsExtra._room(b, Color("e8e2d4"), Color("d4ccb8"), 560, Color("b8ab90"), "tile")
	_columns(b, [120, 1160], 130, 560, Color("f4f2ec"))
	b._sign(Rect2(420, 40, 440, 60), "HILLWOOD MUSEUM", Color("8a5a36"), Color.WHITE, 32)
	# A big dinosaur skeleton
	var bone := Color("f4f0e0")
	Art.limb(b.ci, Art.curve(Vector2(300, 330), Vector2(640, 250), Vector2(980, 360), 20), 14, bone)
	for i in 10:
		var x := 360.0 + i * 60.0
		Art.stroke(b.ci, Art.curve(Vector2(x, 300 - sin(i * 0.3) * 30), Vector2(x + 14, 360), Vector2(x, 400), 8), 5.0, bone)
	Art.blob(b.ci, Vector2(260, 320), 60, 34, bone, 3.5)
	Art.dot(b.ci, Vector2(240, 310), 7, INK)
	for x in [480, 800]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 380), Vector2(x - 10, 540)]), 14, bone)
	Art.shape(b.ci, Art.rrect(Rect2(380, 540, 520, 22), 4), Color("8a5a36"), 3.0)


static func _hillwood_subway(b: Backdrop) -> void:
	SetsExtra._room(b, Color("e8e2c8"), Color("cfc8a8"), 560, Color("7a7a80"), "tile")
	for j in 9:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, 40 + j * 56), Vector2(W + PAD, 40 + j * 56)]), 1.5, Color("b8b090"))
	# A train with its doors open
	Art.shape(b.ci, Art.rrect(Rect2(-60, 220, 1400, 300), 20), Color("b8c0c8"), 5.0, 0.12)
	Art.stroke(b.ci, PackedVector2Array([Vector2(-60, 290), Vector2(1340, 290)]), 8.0, Color("e6452f"))
	for i in 5:
		b._window(Rect2(40 + i * 270, 310, 130, 90), Color("8a96a3"), Color("2b3a4a"), false)
	b._sign(Rect2(470, 120, 340, 56), "HILLWOOD LINE", Color("2f4f9a"), Color.WHITE, 30)
	Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, 548), Vector2(W + PAD, 548)]), 6.0, Color("f2c14e"))


static func _ps118_gym(b: Backdrop) -> void:
	SetsExtra._room(b, Color("3a3f6a"), Color("5a5f8a"), 520, Color("d8a868"))
	for i in 8:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 200, 520), Vector2(-PAD + i * 200 - 60, H + PAD)]), 2.0, Color("b8884a"))
	# Bleachers, hoops and a disco ball
	for k in 3:
		Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 380 + k * 46, 380 - k * 40, 46)), Color("8a96a3"), 3.0)
		Art.shape(b.ci, SetsExtra._rect(Rect2(980 + k * 40, 380 + k * 46, 400, 46)), Color("8a96a3"), 3.0)
	for x in [220, 1060]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 60, 160, 120, 80), 4), Color.WHITE, 3.5)
		b.ci.draw_arc(Vector2(x, 260), 26, 0, PI, 10, Color("e6702f"), 5.0)
	Art.stroke(b.ci, PackedVector2Array([Vector2(640, -PAD), Vector2(640, 110)]), 3.0)
	Art.blob(b.ci, Vector2(640, 150), 40, 40, Color("c8d0d8"), 3.5)
	for k in 6:
		Art.stroke(b.ci, PackedVector2Array([Vector2(604 + k * 14, 116), Vector2(604 + k * 14, 186)]), 1.5, Color("8a96a3"))
	b._sign(Rect2(440, 230, 400, 60), "SPRING DANCE", Color("f28cb8"), Color.WHITE, 34)


static func _school_bus(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f2c14e"), Color("e6a830"), 560, Color("5a5f68"))
	# Windows along the top with the city going by
	for i in 5:
		b._window(Rect2(30 + i * 260, 100, 190, 140), Color("e6a830"), Color("9ccbe8"), false)
		Art.shape(b.ci, SetsExtra._rect(Rect2(60 + i * 260, 180, 40, 60)), Color("a7bfd3"), 2.0)
	# Rows of green seats
	for i in 5:
		var x := 40.0 + i * 260.0
		Art.shape(b.ci, Art.rrect(Rect2(x, 330, 200, 150), 18), Color("3f8f4a"), 4.0, 0.15)
		Art.shape(b.ci, Art.rrect(Rect2(x - 10, 470, 220, 40), 10), Color("2f6f3a"), 3.5)
	b._sign(Rect2(500, 260, 280, 46), "NO STANDING", Color("e6452f"), Color.WHITE, 26)


static func _hillwood_rink(b: Backdrop) -> void:
	b._city_sky(Color("8aa8d0"), Color("e8f0f8"))
	b._skyline(450, Color("a7bfd3"), 77, Color(1, 1, 1, 0.4))
	# Ice with skate scratches, and boards around the rink
	Art.shape(b.ci, PackedVector2Array([Vector2(-PAD, 520), Vector2(W + PAD, 520), Vector2(W + PAD, H + PAD), Vector2(-PAD, H + PAD)]),
		Color("dff2fb"), 4.0)
	for i in 8:
		Art.stroke(b.ci, Art.curve(Vector2(100 + i * 150, 600), Vector2(160 + i * 150, 560), Vector2(240 + i * 150, 620), 8), 2.0,
			Color("b8d8e8"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 470, W + PAD * 2, 50)), Color("f4f4f2"), 4.0)
	Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, 500), Vector2(W + PAD, 500)]), 6.0, Color("e6452f"))
	# Cocoa stand
	Art.shape(b.ci, Art.rrect(Rect2(960, 320, 220, 150), 8), Color("a24d38"), 4.0, 0.12)
	b._sign(Rect2(950, 280, 240, 46), "HOT COCOA", Color("6b4428"), Color.WHITE, 26)
	SetsExtra._tree(b, 120, 470, 0.7, Color("e8f4f8"))


# ------------------------------------------------------------------ Doug --

static func _valentine_house(b: Backdrop) -> void:
	SetsExtra._room(b, Color("a8d8f0"), Color("88c0e0"), 560, Color("8a5a36"))
	b._window(Rect2(540, 110, 200, 160), Color.WHITE, Color("cfe9f7"))
	# Model planes hanging from the ceiling and a shelf of comics
	for p in [Vector2(250, 120), Vector2(1000, 150)]:
		Art.stroke(b.ci, PackedVector2Array([Vector2(p.x, -PAD), p]), 2.0)
		Art.shape(b.ci, PackedVector2Array([p + Vector2(-50, 0), p + Vector2(50, -6), p + Vector2(50, 6)]), Color("e6452f"), 3.0)
		Art.shape(b.ci, PackedVector2Array([p + Vector2(-6, -30), p + Vector2(10, 0), p + Vector2(-6, 30)]), Color("e6452f").darkened(0.15), 3.0)
	_shelves(b, Rect2(880, 260, 300, 290), Color("c48a4f"), [Color("e6452f"), Color("f2c14e"), Color("4a78d0")], 61)
	Art.shape(b.ci, Art.rrect(Rect2(110, 420, 330, 120), 12), Color("5aa84a"), 4.0, 0.12)
	b._sign(Rect2(470, 330, 340, 50), "SKEETER'S ROOM", Color("f2a65a"), Color.WHITE, 30)


static func _patti_house(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	SetsExtra._grass(b, 560)
	SetsExtra._house(b, Rect2(360, 260, 560, 300), Color("f2d9a8"), Color("5a8fd8"))
	# Basketball hoop over the garage door and a ramp to the front door
	Art.shape(b.ci, Art.rrect(Rect2(960, 240, 110, 70), 4), Color.WHITE, 3.5)
	b.ci.draw_arc(Vector2(1015, 330), 26, 0, PI, 10, Color("e6702f"), 5.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(1015, 310), Vector2(1015, 600)]), 8, Color("8a96a3"))
	Art.shape(b.ci, PackedVector2Array([Vector2(520, 560), Vector2(600, 520), Vector2(680, 520), Vector2(760, 560)]), Color("b8b0a0"), 3.5)
	for x in [160, 260]:
		SetsExtra._bush(b, Vector2(x, 560), 0.9, Color("f28cb8"))


static func _roger_trailer(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	SetsExtra._grass(b, 560, Color("a8b85a"))
	Art.shape(b.ci, Art.rrect(Rect2(260, 300, 760, 240), 40), Color("dfe6ea"), 5.0, 0.12)
	Art.stroke(b.ci, PackedVector2Array([Vector2(270, 380), Vector2(1010, 380)]), 8.0, Color("3f8f4a"))
	for x in [340, 820]:
		b._window(Rect2(x, 400, 120, 80), Color("8a96a3"), Color("9ccbe8"))
	b._door(Rect2(600, 400, 80, 140), Color("8a96a3"), false)
	for x in [380, 900]:
		Art.blob(b.ci, Vector2(x, 548), 40, 40, Color("2b2b33"), 4.0)
	# The lawn flamingo
	Art.limb(b.ci, PackedVector2Array([Vector2(1120, 600), Vector2(1120, 520)]), 4, Color("f28cb8"))
	Art.blob(b.ci, Vector2(1120, 500), 30, 20, Color("f28cb8"), 3.0)
	Art.limb(b.ci, Art.curve(Vector2(1140, 490), Vector2(1160, 450), Vector2(1145, 430), 6), 6, Color("f28cb8"))


static func _sleech_lab(b: Backdrop) -> void:
	SetsMore._panels(b, Color("6a6a8a"), Color("6fdc6a"), 550)
	# Lab bench with bubbling beakers and a big red button
	Art.shape(b.ci, Art.rrect(Rect2(150, 400, 420, 40), 6), Color("8a96a3"), 4.0)
	for i in 4:
		var x := 210.0 + i * 100.0
		Art.shape(b.ci, PackedVector2Array([Vector2(x - 14, 340), Vector2(x + 14, 340), Vector2(x + 30, 400), Vector2(x - 30, 400)]),
			[Color("6fdc6a"), Color("f28cb8"), Color("6fb3e8"), Color("f2c14e")][i], 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(820, 260, 300, 290), 16), Color("4a4a6a"), 4.0, 0.12)
	Art.blob(b.ci, Vector2(970, 360), 50, 40, Color("e6452f"), 4.0, 0.15)
	b._sign(Rect2(830, 470, 280, 40), "DO NOT PRESS", Color("f2c14e"), Color("e6452f"), 24)
	b._sign(Rect2(440, 60, 400, 56), "SLEECH LABORATORIES", Color("2b2f4a"), Color("6fdc6a"), 28)


static func _bluffington_mall(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f2ead2"), Color("dfd4b4"), 560, Color("c8c0b0"), "tile")
	# Two floors of shops, a fountain and an escalator
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 260, W + PAD * 2, 24)), Color("8a96a3"), 4.0)
	var shops := [["SHOES", Color("e6452f")], ["BOOKS", Color("4a78d0")], ["TOYS", Color("f2c14e")], ["PETS", Color("5aa84a")]]
	for i in 4:
		var x := 20.0 + i * 320.0
		Art.shape(b.ci, SetsExtra._rect(Rect2(x, 60, 280, 200)), Color("f4f2ec"), 3.5)
		b._sign(Rect2(x + 40, 76, 200, 40), shops[i][0], shops[i][1], Color.WHITE, 24)
		b._window(Rect2(x + 40, 130, 200, 110), Color("8a96a3"), Color("cfe9f7"), false)
	Art.limb(b.ci, PackedVector2Array([Vector2(860, 560), Vector2(1100, 284)]), 50, Color("8a96a3"))
	Art.shape(b.ci, Art.arc_pts(Vector2(420, 560), 160, 50, PI, TAU, 16), Color("6fb3e8"), 4.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(420, 520), Vector2(420, 440)]), 12, Color("f4f2ec"))


static func _bluffington_gym(b: Backdrop) -> void:
	SetsExtra._room(b, Color("e8dcc0"), Color("d4c4a0"), 520, Color("d8a868"))
	for i in 8:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 200, 520), Vector2(-PAD + i * 200 - 60, H + PAD)]), 2.0, Color("b8884a"))
	Art.stroke(b.ci, PackedVector2Array([Vector2(640, 520), Vector2(640, H + PAD)]), 4.0, Color("e6452f"))
	# Climbing rope, banner and a rack of dodgeballs
	Art.stroke(b.ci, Art.curve(Vector2(200, -PAD), Vector2(214, 200), Vector2(200, 420), 10), 8.0, Color("c8a86a"))
	b._sign(Rect2(440, 100, 400, 60), "GO BLUFFINGTON!", Color("5aa84a"), Color.WHITE, 34)
	Art.shape(b.ci, Art.rrect(Rect2(920, 400, 220, 120), 8), Color("8a96a3"), 4.0)
	for k in 6:
		Art.blob(b.ci, Vector2(950 + (k % 3) * 70, 430 + (k / 3) * 50), 26, 24, Color("e6452f"), 3.0)


static func _bluff_tower(b: Backdrop) -> void:
	SetsExtra._room(b, Color("2a3a5a"), Color("4a5a7a"), 560, Color("6a4a3a"), "carpet")
	# Wall of windows looking down on the town far below
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 60, W + PAD * 2, 380)), Color("8fc8f0"), 4.0)
	b._skyline(440, Color("6a8ab0"), 21, Color(1, 1, 1, 0.3))
	for i in 9:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 180, 60), Vector2(-PAD + i * 180, 440)]), 6.0, Color("2b2b33"))
	Art.shape(b.ci, Art.rrect(Rect2(420, 420, 440, 40), 6), Color("6b4428"), 4.0)
	Art.shape(b.ci, PackedVector2Array([Vector2(440, 460), Vector2(840, 460), Vector2(820, 560), Vector2(460, 560)]), Color("8a5a36"), 4.0)
	b._sign(Rect2(500, 470, 280, 44), "MR. BLUFF", Color("f2c14e"), Color("2b2b33"), 26)


static func _funnie_garage(b: Backdrop) -> void:
	SetsExtra._room(b, Color("c8c0b0"), Color("b0a898"), 560, Color("8a8a8a"), "tile")
	# Workbench with a pegboard of tools, the family car and a pile of boxes
	Art.shape(b.ci, SetsExtra._rect(Rect2(90, 140, 360, 200)), Color("c8a06a"), 4.0)
	for k in 12:
		Art.dot(b.ci, Vector2(110 + (k % 6) * 60, 170 + (k / 6) * 60), 4, Color("6b4428"))
	Art.limb(b.ci, PackedVector2Array([Vector2(140, 190), Vector2(150, 260)]), 8, Color("e6452f"))
	Art.limb(b.ci, PackedVector2Array([Vector2(260, 180), Vector2(250, 280)]), 6, Color("8a96a3"))
	SetsExtra._table(b, 270, 380, 360, Color("8a5a36"))
	Art.shape(b.ci, Art.smooth(PackedVector2Array([Vector2(640, 540), Vector2(660, 430), Vector2(760, 380), Vector2(1000, 380),
		Vector2(1120, 440), Vector2(1140, 540)]), 4), Color("5aa84a"), 4.5, 0.12)
	for x in [720, 1060]:
		Art.blob(b.ci, Vector2(x, 548), 38, 38, Color("2b2b33"), 4.0)
	b._window(Rect2(820, 400, 160, 60), Color("5aa84a"), Color("cfe9f7"), false)


static func _bluffington_fair(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	SetsExtra._grass(b, 560, Color("8fd06a"))
	# Ferris wheel (cars turn in the moving layer), the pie tent and a pig pen
	b.ci.draw_arc(Vector2(1040, 250), 150, 0, TAU, 40, INK, 9.0)
	b.ci.draw_arc(Vector2(1040, 250), 150, 0, TAU, 40, Color("f4f2ec"), 5.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(960, 590), Vector2(1040, 250), Vector2(1120, 590)]), 12, Color("8a96a3"))
	Art.shape(b.ci, PackedVector2Array([Vector2(160, 360), Vector2(380, 220), Vector2(600, 360)]), Color("e6452f"), 4.0, 0.12)
	for i in 6:
		Art.stroke(b.ci, PackedVector2Array([Vector2(380, 220), Vector2(160 + i * 88, 360)]), 3.0, Color.WHITE)
	Art.shape(b.ci, SetsExtra._rect(Rect2(180, 360, 400, 200)), Color("f4f2ec"), 4.0)
	b._sign(Rect2(230, 380, 300, 50), "PIE CONTEST", Color("f2c14e"), Color("e6452f"), 30)
	SetsExtra._fence(b, 500, 590, Color("c8a06a"))


static func _bluffington_cinema(b: Backdrop) -> void:
	SetsExtra._room(b, Color("4a1a2a"), Color("6a2a3a"), 560, Color("3a1a1a"), "carpet")
	# Screen, curtains and rows of red velvet seats
	Art.shape(b.ci, Art.rrect(Rect2(260, 60, 760, 330), 8), Color("f4f2ec"), 4.0)
	Art.shape(b.ci, PackedVector2Array([Vector2(-PAD, -PAD), Vector2(300, -PAD), Vector2(230, 420), Vector2(-PAD, 420)]), Color("b3202f"), 4.0, 0.12)
	Art.shape(b.ci, PackedVector2Array([Vector2(980, -PAD), Vector2(W + PAD, -PAD), Vector2(W + PAD, 420), Vector2(1050, 420)]), Color("b3202f"), 4.0, 0.12)
	for j in 2:
		for i in 9:
			var x := 60.0 + i * 150.0 + j * 70
			Art.shape(b.ci, Art.rrect(Rect2(x, 440 + j * 70, 110, 70), 16), Color("b3202f"), 3.5, 0.12)
	b._sign(Rect2(440, 200, 400, 60), "NOW SHOWING", Color("2b2b33"), Color("f2c14e"), 34)


# ------------------------------------------------------------- Rugrats --

static func _the_playpen(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f6d9a6"), Color("e8c48a"), 520, Color("9fb87a"), "carpet")
	b._window(Rect2(900, 110, 220, 170), Color.WHITE, Color("bfe0f2"))
	# The playpen fills the room: netting behind, blocks and a ball inside
	b.ci.draw_rect(Rect2(40, 220, 1200, 300), Color(1, 1, 1, 0.25))
	for i in 41:
		Art.stroke(b.ci, PackedVector2Array([Vector2(40 + i * 30, 220), Vector2(40 + i * 30, 520)]), 1.5, Color("8a96a3"))
	Art.shape(b.ci, Art.rrect(Rect2(30, 206, 1220, 20), 8), Color("4a78d0"), 3.5)
	var cols := [Color("e6452f"), Color("f2c14e"), Color("4a78d0"), Color("5aa84a")]
	for i in 4:
		var x: float = 150.0 + i * 64.0
		Art.shape(b.ci, Art.rrect(Rect2(x, 470 - (i % 2) * 50, 56, 50), 6), cols[i], 3.0, 0.1)
		Art.text(b.ci, b.sign_font, Vector2(x, 508 - (i % 2) * 50), ["A", "B", "C", "D"][i], 28, Color.WHITE, 4, HORIZONTAL_ALIGNMENT_CENTER, 56)
	Art.blob(b.ci, Vector2(1060, 480), 40, 40, Color("e6452f"), 4.0, 0.12)
	Art.stroke(b.ci, Art.arc_pts(Vector2(1060, 480), 40, 12, 0, PI, 10), 4.0, Color.WHITE)


static func _sandbox(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	SetsExtra._grass(b, 470)
	SetsExtra._fence(b, 360, 480, Color("e9e2cf"))
	# A big sandbox right up front, with a bucket, a shovel and a sand castle
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 500, W + PAD * 2, H)), Color("c48a4f"), 5.0)
	b._sand(530, Color("f1dc9b"), 10.0)
	Art.shape(b.ci, PackedVector2Array([Vector2(170, 560), Vector2(250, 560), Vector2(240, 490), Vector2(180, 490)]), Color("e6452f"), 3.5, 0.12)
	Art.stroke(b.ci, Art.curve(Vector2(180, 490), Vector2(210, 450), Vector2(240, 490), 8), 3.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(1080, 560), Vector2(1140, 440)]), 8, Color("4a78d0"))
	Art.shape(b.ci, Art.rrect(Rect2(1046, 540, 60, 40), 12), Color("4a78d0"), 3.0)
	for i in 3:
		var x: float = 860.0 + i * 50.0
		Art.shape(b.ci, SetsExtra._rect(Rect2(x, 480 - (i % 2) * 30, 44, 70 + (i % 2) * 30)), Color("e8cf8a"), 3.0)
	SetsExtra._tree(b, 560, 470, 0.9)


static func _drew_house(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f4ecf6"), Color("e2d4ea"), 545, Color("c8b0d8"), "carpet")
	# A fancy living room: white couch, a glass table, a chandelier and a portrait of Angelica
	Art.stroke(b.ci, PackedVector2Array([Vector2(640, -PAD), Vector2(640, 80)]), 3.0)
	for i in 5:
		var x: float = 560.0 + i * 40.0
		Art.blob(b.ci, Vector2(x, 100 - absf(i - 2) * 8), 10, 16, Color("f2e6a0"), 2.5)
	Art.shape(b.ci, Art.rrect(Rect2(540, 80, 200, 16), 6), Color("f2c14e"), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(140, 160, 240, 200), 6), Color("f2c14e"), 5.0)
	Art.shape(b.ci, Art.rrect(Rect2(160, 180, 200, 160), 4), Color("c8b0e6"), 2.5)
	Art.blob(b.ci, Vector2(260, 250), 44, 50, Puppet.SKIN, 3.0)
	for sx in [-1, 1]:
		Art.blob(b.ci, Vector2(260 + sx * 56, 230), 16, 24, Color("f4d24e"), 3.0)
		Art.dot(b.ci, Vector2(260 + sx * 14, 246), 4, INK)
	Art.shape(b.ci, Art.rrect(Rect2(780, 380, 400, 165), 30), Color("f8f6f2"), 4.0, 0.1)
	Art.shape(b.ci, Art.rrect(Rect2(480, 470, 200, 14), 4), Color(0.7, 0.85, 0.95, 0.7), 3.0)
	b._sign(Rect2(470, 180, 340, 50), "PRINCESS ONLY", Color("f28cb8"), Color.WHITE, 26)


static func _deville_house(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	SetsExtra._grass(b, 520, Color("8fbf5a"))
	SetsExtra._house(b, Rect2(720, 200, 520, 320), Color("c8e0b0"), Color("9b5fd0"))
	SetsExtra._fence(b, 400, 520, Color("f2f2ee"))
	# A big muddy puddle full of worms
	Art.blob(b.ci, Vector2(340, 600), 260, 50, Color("8a5a36"), 4.0, 0.15)
	for i in 5:
		var x: float = 180.0 + i * 70.0
		Art.stroke(b.ci, Art.curve(Vector2(x, 600), Vector2(x + 14, 584 + (i % 2) * 6), Vector2(x + 28, 600), 8), 5.0, Color("f28cb8"))
	b._sign(Rect2(60, 380, 260, 50), "WORM CROSSING", Color("f2c14e"), INK, 24)


static func _the_zoo(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	SetsExtra._grass(b, 520, Color("a8c86a"))
	# A giraffe behind a fence, a monkey cage and the zoo gate
	var g := Color("f2c14e")
	Art.limb(b.ci, PackedVector2Array([Vector2(300, 420), Vector2(330, 200)]), 30, g)
	Art.blob(b.ci, Vector2(340, 190), 36, 22, g, 4.0)
	Art.blob(b.ci, Vector2(290, 440), 80, 50, g, 4.0, 0.12)
	for d in [Vector2(270, 430), Vector2(320, 450), Vector2(312, 300), Vector2(326, 240)]:
		Art.dot(b.ci, d, 9, Color("c8742a"))
	Art.dot(b.ci, Vector2(352, 184), 5, INK)
	for x in [240, 330]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 470), Vector2(x, 520)]), 12, g)
	SetsExtra._fence(b, 440, 530, Color("c48a4f"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(780, 240, 380, 280)), Color("8a96a3").lightened(0.5), 4.0)
	for i in 13:
		Art.stroke(b.ci, PackedVector2Array([Vector2(790 + i * 30, 240), Vector2(790 + i * 30, 520)]), 4.0, Color("6a6a7a"))
	Art.blob(b.ci, Vector2(960, 420), 34, 30, Color("8a5a36"), 3.5)
	Art.blob(b.ci, Vector2(960, 380), 24, 22, Color("8a5a36"), 3.5)
	Art.blob(b.ci, Vector2(960, 386), 14, 12, Color("e8c8a0"), 2.5)
	b._sign(Rect2(470, 80, 340, 60), "THE ZOO", Color("5aa84a"), Color.WHITE, 38)


static func _beach_day(b: Backdrop) -> void:
	SetsMore._sky(b, Color("5fb8f0"), Color("cdeefa"))
	Art.dot(b.ci, Vector2(1120, 110), 60, Color("f7e27a"))
	SetsExtra._water(b, 380, 520, Color("3fa0d8"))
	b._sand(520, Color("f4e2a6"), 12.0)
	# Beach umbrella, towel and a lifeguard chair
	Art.limb(b.ci, PackedVector2Array([Vector2(300, 600), Vector2(330, 380)]), 7, Color("f4f4f2"))
	Art.shape(b.ci, Art.arc_pts(Vector2(330, 390), 160, 70, PI, TAU, 18), Color("e6452f"), 4.0)
	for i in 3:
		var a: float = PI + (i + 1) * PI / 4.0
		Art.stroke(b.ci, PackedVector2Array([Vector2(330, 390), Vector2(330 + cos(a) * 160, 390 + sin(a) * 70)]), 3.0, Color.WHITE)
	Art.shape(b.ci, Art.rrect(Rect2(420, 600, 200, 50), 6), Color("f2c14e"), 3.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(980, 610), Vector2(1020, 420)]), 8, Color.WHITE)
	Art.limb(b.ci, PackedVector2Array([Vector2(1120, 610), Vector2(1080, 420)]), 8, Color.WHITE)
	Art.shape(b.ci, Art.rrect(Rect2(1000, 400, 100, 26), 4), Color("e6452f"), 3.0)


static func _the_airport(b: Backdrop) -> void:
	SetsExtra._room(b, Color("dfe6ee"), Color("c8d2de"), 560, Color("b8c0c8"), "tile")
	# Giant windows onto the runway (planes fly past in the moving layer)
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 60, W + PAD * 2, 330)), Color("9fd0f2"), 4.0)
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 330, W + PAD * 2, 60)), Color("8a8a8a"), 0.0)
	for i in 8:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 200, 60), Vector2(-PAD + i * 200, 390)]), 6.0, Color("6a6a7a"))
	b._sign(Rect2(80, 410, 280, 50), "GATE 9", Color("2b3a6a"), Color("f2c14e"), 30)
	# Luggage carousel and a pile of suitcases
	Art.shape(b.ci, Art.rrect(Rect2(700, 470, 480, 70), 30), Color("4a4d55"), 4.0)
	var cols := [Color("e6452f"), Color("4a78d0"), Color("f2c14e"), Color("5aa84a")]
	for i in 4:
		var x: float = 740.0 + i * 110.0
		Art.shape(b.ci, Art.rrect(Rect2(x, 420 + (i % 2) * 10, 90, 60), 8), cols[i], 3.0, 0.1)
		Art.stroke(b.ci, Art.arc_pts(Vector2(x + 45, 420 + (i % 2) * 10), 16, 12, PI, TAU, 8), 3.0)


static func _the_circus(b: Backdrop) -> void:
	# Inside the big top: red and white stripes, a ring and the trapeze
	Art.gradient_rect(b.ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), Color("4a1a2a"), Color("8a2a3a"))
	b._sky_bottom = Color("8a2a3a")
	for i in 12:
		var x0: float = -PAD + i * 130.0
		Art.shape(b.ci, PackedVector2Array([Vector2(640, -PAD), Vector2(x0, 520), Vector2(x0 + 65, 520)]),
			Color("e6452f") if i % 2 == 0 else Color("f4f2ec"), 0.0)
	SetsExtra._fill_band(b, 520, H + PAD, Color("d8b07a"))
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 600), 520, 70, 0, TAU, 40), Color("e8c890"), 6.0)
	Art.stroke(b.ci, Art.arc_pts(Vector2(640, 600), 520, 70, 0, TAU, 40), 10.0, Color("e6452f"))
	Art.shape(b.ci, Art.rrect(Rect2(60, 340, 140, 180), 10), Color("f28cb8"), 4.0)
	Art.blob(b.ci, Vector2(130, 320), 50, 40, Color("f7c6d6"), 3.5)
	b._sign(Rect2(50, 470, 160, 40), "COTTON CANDY", Color("f4f4f2"), Color("e6452f"), 18)
	for sx in [-1, 1]:
		Art.dot(b.ci, Vector2(640 + sx * 300, 120), 30, Color(1, 1, 0.8, 0.5))


static func _dentist_office(b: Backdrop) -> void:
	SetsExtra._room(b, Color("dff2f0"), Color("c4e4e0"), 550, Color("e8e8e0"), "tile")
	# The big chair, the bright light and a fish tank
	Art.shape(b.ci, Art.smooth(PackedVector2Array([Vector2(700, 520), Vector2(700, 440), Vector2(820, 430), Vector2(900, 300),
		Vector2(950, 310), Vector2(900, 470), Vector2(940, 520)]), 4), Color("4ab8a8"), 4.5, 0.12)
	Art.limb(b.ci, PackedVector2Array([Vector2(820, 520), Vector2(820, 560)]), 18, Color("8a96a3"))
	Art.limb(b.ci, PackedVector2Array([Vector2(1100, -PAD), Vector2(1100, 160), Vector2(960, 200)]), 8, Color("8a96a3"))
	Art.blob(b.ci, Vector2(950, 210), 40, 26, Color("f4f4f2"), 3.5)
	Art.dot(b.ci, Vector2(950, 214), 16, Color("fff4a0"))
	Art.shape(b.ci, Art.rrect(Rect2(110, 300, 320, 200), 8), Color("5ab0e0"), 5.0, 0.1)
	Art.shape(b.ci, SetsExtra._rect(Rect2(116, 306, 308, 30)), Color("bfe6f6"), 0.0)
	Art.shape(b.ci, Art.rrect(Rect2(100, 500, 340, 50), 4), Color("8a5a36"), 4.0)
	for d in [Vector2(200, 400), Vector2(320, 440)]:
		Art.blob(b.ci, d, 22, 14, Color("f2852a"), 3.0)
		Art.shape(b.ci, PackedVector2Array([d + Vector2(18, 0), d + Vector2(36, -12), d + Vector2(36, 12)]), Color("f2852a"), 2.5)
	b._sign(Rect2(480, 90, 320, 56), "SMILE!", Color.WHITE, Color("4ab8a8"), 36)


static func _reptar_arena(b: Backdrop) -> void:
	Art.gradient_rect(b.ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), Color("1a2a4a"), Color("3a5a8a"))
	b._sky_bottom = Color("3a5a8a")
	# Seats full of fans, a frozen rink and a giant ice Reptar
	for j in 4:
		for i in 26:
			Art.dot(b.ci, Vector2(-20 + i * 52 + (j % 2) * 26, 80 + j * 50), 14, Color.from_hsv(fmod(i * 0.13 + j * 0.3, 1.0), 0.5, 0.9))
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 300, W + PAD * 2, 30)), Color("e6452f"), 4.0)
	SetsExtra._fill_band(b, 500, H + PAD, Color("e4f4fc"))
	Art.stroke(b.ci, Art.arc_pts(Vector2(640, 600), 220, 50, 0, TAU, 30), 4.0, Color("6fb3e8"))
	var g := Color("6fbf6a")
	Art.shape(b.ci, Art.smooth(PackedVector2Array([Vector2(560, 500), Vector2(550, 380), Vector2(590, 300), Vector2(690, 280),
		Vector2(740, 320), Vector2(720, 400), Vector2(730, 500)]), 5), g, 5.0, 0.15)
	for i in 4:
		Art.shape(b.ci, PackedVector2Array([Vector2(570 + i * 6, 330 + i * 40), Vector2(536 + i * 4, 346 + i * 40), Vector2(566 + i * 6, 364 + i * 40)]), Color("9b5fd0"), 3.0)
	Art.blob(b.ci, Vector2(690, 310), 10, 10, Color.WHITE, 3.0)
	Art.dot(b.ci, Vector2(693, 310), 4, INK)
	b._sign(Rect2(420, 340, 440, 56), "REPTAR ON ICE!", Color("2b3a6a"), Color("6dff8a"), 34)

