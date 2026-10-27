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
