class_name SetsExtra
extends RefCounted
## Drawings for the larger set list. Backdrop._draw_set() / _draw_fx() fall
## through to these for locations they don't draw themselves. `b` is the
## Backdrop (its helpers draw into b.ci); W/H/PAD are the stage constants.

const W := Backdrop.W
const H := Backdrop.H
const PAD := Backdrop.PAD
const INK := Art.INK


static func draw_set(b: Backdrop, id: String) -> bool:
	match id:
		# Bikini Bottom
		"bb_downtown": _bb_downtown(b)
		"glove_world": _glove_world(b)
		"kelp_forest": _kelp_forest(b)
		"rock_bottom": _rock_bottom(b)
		"krusty_dining": _krusty_dining(b)
		"sponge_living_room": _sponge_living_room(b)
		# Hillwood
		"hillwood_street": _hillwood_street(b)
		"hillwood_park": _hillwood_park(b)
		"cafeteria": _cafeteria(b)
		"boarding_kitchen": _boarding_kitchen(b)
		"alley": _alley(b)
		# Bluffington
		"funnie_house": _funnie_house(b)
		"dug_room": _dug_room(b)
		"bluffington_school": _bluffington_school(b)
		"school_hallway": _school_hallway(b)
		"honker_burger": _honker_burger(b)
		"lucky_duck_lake": _lucky_duck_lake(b)
		"beebe_mansion": _beebe_mansion(b)
		"dink_yard": _dink_yard(b)
		"bluffington_downtown": _bluffington_downtown(b)
		"bluffington_park": _bluffington_park(b)
		# Playpen
		"pickles_living_room": _pickles_living_room(b)
		"pickles_backyard": _pickles_backyard(b)
		"pickles_kitchen": _pickles_kitchen(b)
		"nursery": _nursery(b)
		"stu_basement": _stu_basement(b)
		"playground": _playground(b)
		"reptarland": _reptarland(b)
		"java_lava": _java_lava(b)
		"supermarket": _supermarket(b)
		"finster_house": _finster_house(b)
		# Team Rokket
		"forest_path": _forest_path(b)
		"rokket_hq": _rokket_hq(b)
		"monster_clinic": _monster_clinic(b)
		"clinic_lobby": _clinic_lobby(b)
		"town_square": _town_square(b)
		"crystal_cave": _crystal_cave(b)
		"sunny_beach": _sunny_beach(b)
		"cliff_top": _cliff_top(b)
		"rokket_camp": _rokket_camp(b)
		"mecha_lab": _mecha_lab(b)
		_: return false
	return true


# ------------------------------------------------------------ helpers --

static func _rect(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])


static func _fill_band(b: Backdrop, y0: float, y1: float, col: Color, outline: bool = true) -> void:
	Art.fill(b.ci, _rect(Rect2(-PAD, y0, W + PAD * 2, y1 - y0)), col)
	if outline:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, y0), Vector2(W + PAD, y0)]), 4.0)


static func _grass(b: Backdrop, top_y: float = 560.0, col: Color = Color("7cc95a")) -> void:
	var pts := PackedVector2Array()
	for i in 25:
		var x := lerpf(-PAD, W + PAD, i / 24.0)
		pts.append(Vector2(x, top_y + sin(x * 0.01 + 1.0) * 8.0))
	var edge := pts.duplicate()
	pts.append(Vector2(W + PAD, H + PAD))
	pts.append(Vector2(-PAD, H + PAD))
	Art.fill(b.ci, pts, col)
	Art.stroke(b.ci, edge, 4.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(b.location)
	for i in 40:
		var p := Vector2(rng.randf_range(-PAD, W + PAD), rng.randf_range(top_y + 20, H))
		Art.stroke(b.ci, PackedVector2Array([p, p + Vector2(-3, -9), p + Vector2(3, -2), p + Vector2(6, -10)]), 2.0, col.darkened(0.2))


static func _tree(b: Backdrop, x: float, base_y: float, s: float = 1.0, leaf: Color = Color("53a83e")) -> void:
	Art.limb(b.ci, PackedVector2Array([Vector2(x, base_y), Vector2(x, base_y - 170 * s)]), 34 * s, Color("8a5a2b"))
	for p in [Vector2(0, -230), Vector2(-60, -190), Vector2(60, -190), Vector2(-30, -270), Vector2(35, -260)]:
		Art.blob(b.ci, Vector2(x, base_y) + p * s, 62 * s, 50 * s, leaf, 4.0, 0.12)


static func _bush(b: Backdrop, c: Vector2, s: float = 1.0, col: Color = Color("4f9a3a")) -> void:
	for p in [Vector2(-30, 0), Vector2(30, 0), Vector2(0, -18)]:
		Art.blob(b.ci, c + p * s, 40 * s, 30 * s, col, 3.5, 0.12)


static func _house(b: Backdrop, r: Rect2, wall: Color, roof: Color, door: Color = Color("8a5a36")) -> void:
	Art.shape(b.ci, _rect(r), wall, 5.0, 0.1)
	Art.shape(b.ci, PackedVector2Array([r.position + Vector2(-30, 4), Vector2(r.get_center().x, r.position.y - r.size.x * 0.32),
		Vector2(r.end.x + 30, r.position.y + 4)]), roof, 5.0, 0.15)
	var dw := r.size.x * 0.16
	b._door(Rect2(r.get_center().x - dw / 2, r.end.y - r.size.y * 0.5, dw, r.size.y * 0.5), door, false)
	for sx in [-1, 1]:
		b._window(Rect2(r.get_center().x + sx * r.size.x * 0.3 - 40, r.position.y + r.size.y * 0.25, 80, 70), Color.WHITE, Color("bfe0f2"))


static func _fence(b: Backdrop, y0: float, y1: float, col: Color = Color("f2f2ee")) -> void:
	var x := -PAD
	while x < W + PAD:
		Art.shape(b.ci, PackedVector2Array([Vector2(x, y1), Vector2(x, y0 + 10), Vector2(x + 12, y0), Vector2(x + 24, y0 + 10),
			Vector2(x + 24, y1)]), col, 3.0)
		x += 34
	for y in [y0 + 24, y1 - 20]:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, y), Vector2(W + PAD, y)]), 6.0, col.darkened(0.15))


## A plain room: wall gradient down to a floor line.
static func _room(b: Backdrop, wall_top: Color, wall_bottom: Color, floor_y: float, floor_col: Color, floor_kind: String = "wood") -> void:
	Art.gradient_rect(b.ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), wall_top, wall_bottom)
	b._sky_bottom = wall_bottom
	match floor_kind:
		"wood": b._wood_floor(floor_y, floor_col)
		"tile":
			_fill_band(b, floor_y, H + PAD, floor_col)
			for i in 30:
				Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 60, floor_y), Vector2(-PAD + i * 60 - 40, H + PAD)]), 2.0, floor_col.darkened(0.15))
			for j in 4:
				Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, floor_y + 30 + j * 40), Vector2(W + PAD, floor_y + 30 + j * 40)]), 2.0, floor_col.darkened(0.15))
		"carpet":
			_fill_band(b, floor_y, H + PAD, floor_col)


static func _table(b: Backdrop, x: float, top_y: float, w: float, col: Color = Color("c48a4f")) -> void:
	Art.shape(b.ci, Art.rrect(Rect2(x - w / 2, top_y, w, 18), 4), col, 3.5)
	for sx in [-1, 1]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x + sx * (w / 2 - 14), top_y + 18), Vector2(x + sx * (w / 2 - 14), top_y + 90)]), 9, col.darkened(0.2))


static func _mountains(b: Backdrop, base_y: float, col: Color, seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var x := -PAD - 100
	while x < W + PAD:
		var w := rng.randf_range(260, 420)
		var h := rng.randf_range(140, 260)
		Art.shape(b.ci, PackedVector2Array([Vector2(x, base_y), Vector2(x + w / 2, base_y - h), Vector2(x + w, base_y)]), col, 4.0)
		Art.shape(b.ci, PackedVector2Array([Vector2(x + w / 2 - w * 0.12, base_y - h * 0.76), Vector2(x + w / 2, base_y - h),
			Vector2(x + w / 2 + w * 0.12, base_y - h * 0.76)]), Color.WHITE, 3.0)
		x += w * 0.7


static func _water(b: Backdrop, top_y: float, bottom_y: float, col: Color) -> void:
	Art.fill(b.ci, _rect(Rect2(-PAD, top_y, W + PAD * 2, bottom_y - top_y)), col)
	Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, top_y), Vector2(W + PAD, top_y)]), 3.0)


static func _label(b: Backdrop, r: Rect2, text: String, bg: Color, fg: Color, size: int = 30) -> void:
	b._sign_plate(r, text, bg, fg, size)


static func _day_sky(b: Backdrop) -> void:
	b._city_sky(Color("6ab4ec"), Color("d8f0fb"))


# --------------------------------------------------------- Bikini Bottom --

static func _bb_downtown(b: Backdrop) -> void:
	b._sea_sky()
	var cols := [Color("8a96a3"), Color("c48a4f"), Color("6fb3e8"), Color("e6452f"), Color("9d6ae0")]
	for i in 6:
		var x := -40.0 + i * 230.0
		var h := 200.0 + (i % 3) * 70.0
		var r := Rect2(x, 560 - h, 170, h)
		if i % 2 == 0:
			Art.shape(b.ci, Art.rrect(r, 60), cols[i % cols.size()], 4.0, 0.15)
		else:
			Art.shape(b.ci, Art.rrect(r, 14), cols[i % cols.size()], 4.0, 0.15)
		for k in 2:
			b._porthole(r.position + Vector2(50 + k * 70, 60), 18)
	b._sand(570, Color("e8d9a8"))
	# Bus stop
	Art.limb(b.ci, PackedVector2Array([Vector2(1080, 620), Vector2(1080, 430)]), 8, Color("6d6d6d"))
	b._sign(Rect2(1030, 380, 100, 54), "BUS", Color("f2c14e"), Color.WHITE, 26)


static func _glove_world(b: Backdrop) -> void:
	b._sea_sky(Color("3a8ed8"), Color("a6e2f2"))
	b._sand(580)
	# Ferris wheel frame (the spokes turn in the moving layer)
	Art.limb(b.ci, PackedVector2Array([Vector2(960, 590), Vector2(1040, 300), Vector2(1120, 590)]), 12, Color("e6452f"))
	# Entrance arch with a giant glove
	for x in [380, 900]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 30, 260, 60, 330), 10), Color("f2c14e"), 4.0, 0.15)
	Art.shape(b.ci, Art.rrect(Rect2(330, 220, 620, 70), 18), Color("e6452f"), 5.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(330, 274), "GLOVE WORLD!", 50, Color.WHITE, 8, HORIZONTAL_ALIGNMENT_CENTER, 620)
	var gc := Vector2(640, 140)
	Art.blob(b.ci, gc, 70, 60, Color.WHITE, 5.0, 0.1)
	for i in 4:
		Art.limb(b.ci, PackedVector2Array([gc + Vector2(-45 + i * 30, -30), gc + Vector2(-50 + i * 32, -110)]), 26, Color.WHITE)
	Art.limb(b.ci, PackedVector2Array([gc + Vector2(60, 0), gc + Vector2(120, -40)]), 26, Color.WHITE)
	for x in [200, 1150]:
		Art.blob(b.ci, Vector2(x, 330), 40, 40, Color("f28cb8"), 3.5)
		Art.stroke(b.ci, PackedVector2Array([Vector2(x, 370), Vector2(x, 560)]), 2.0)


static func _kelp_forest(b: Backdrop) -> void:
	b._sea_sky(Color("1f6a8f"), Color("6fbfa6"), false)
	b._sand(590, Color("d9c890"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for i in 12:
		var x := -40 + i * 120 + rng.randf_range(-30, 30)
		var pts := PackedVector2Array()
		for k in 9:
			pts.append(Vector2(x + sin(k * 0.9 + i) * 18.0, 600 - k * 75.0))
		Art.limb(b.ci, pts, 26.0, Color("3f7a3a").lerp(Color("2f5f30"), (i % 3) / 3.0), 3.0)


static func _rock_bottom(b: Backdrop) -> void:
	Art.gradient_rect(b.ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), Color("06111f"), Color("1d2f4a"))
	b._sky_bottom = Color("1d2f4a")
	for p in [Vector2(200, 120), Vector2(700, 80), Vector2(1100, 160), Vector2(450, 220), Vector2(950, 260)]:
		Art.dot(b.ci, p, 4, Color("6dffd6"))
	for x in [100, 380, 900, 1180]:
		Art.shape(b.ci, PackedVector2Array([Vector2(x - 90, 580), Vector2(x - 20, 300), Vector2(x + 50, 330), Vector2(x + 100, 580)]), Color("2f3a4f"), 4.0)
	b._sand(580, Color("4a4f5f"))
	Art.limb(b.ci, PackedVector2Array([Vector2(640, 620), Vector2(640, 420)]), 8, Color("8a96a3"))
	b._sign(Rect2(560, 360, 160, 60), "BUS STOP", Color("3d8fe0"), Color.WHITE, 24)


static func _krusty_dining(b: Backdrop) -> void:
	_room(b, Color("c48a4f"), Color("9b6a3e"), 545, Color("8a5a36"))
	for i in 8:
		var x := -PAD + i * 190.0
		Art.stroke(b.ci, PackedVector2Array([Vector2(x, -PAD), Vector2(x, 545)]), 3.0, Color("7a4a2a"))
	# Ship's wheel and portholes
	var wc := Vector2(640, 200)
	b.ci.draw_arc(wc, 70, 0, TAU, 32, INK, 18.0)
	b.ci.draw_arc(wc, 70, 0, TAU, 32, Color("8a5a2b"), 12.0)
	for i in 8:
		var a := TAU * i / 8.0
		Art.limb(b.ci, PackedVector2Array([wc, wc + Vector2(cos(a), sin(a)) * 100]), 9, Color("8a5a2b"))
	Art.blob(b.ci, wc, 18, 18, Color("e8c040"), 3.0)
	for x in [200, 1080]:
		b._porthole(Vector2(x, 210), 50)
	# Barrel tables
	for x in [260, 1020]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 70, 420, 140, 130), 26), Color("b07a45"), 4.0, 0.15)
		for y in [450, 520]:
			Art.stroke(b.ci, PackedVector2Array([Vector2(x - 68, y), Vector2(x + 68, y)]), 4.0, Color("6b4b33"))


static func _sponge_living_room(b: Backdrop) -> void:
	_room(b, Color("f3b35a"), Color("e09a3e"), 550, Color("6aa7d8"), "carpet")
	for i in 14:
		var x := -PAD + i * 110.0
		Art.stroke(b.ci, Art.curve(Vector2(x, -PAD), Vector2(x + 30, 260), Vector2(x, 550), 10), 3.0, Color("c97f2a"))
	b._porthole(Vector2(300, 220), 70, Color("8a96a3"), Color("6fb3e8"))
	# TV and tiki chair
	Art.shape(b.ci, Art.rrect(Rect2(820, 360, 200, 150), 14), Color("8a5a36"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(840, 378, 160, 110), 8), Color("2c5b6e"), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(140, 400, 120, 150), 16), Color("7a5230"), 4.0, 0.15)
	Art.text(b.ci, b.sign_font, Vector2(140, 470), "TIKI", 30, Color("f2c14e"), 5, HORIZONTAL_ALIGNMENT_CENTER, 120)
	# Gary's bowl
	Art.shape(b.ci, Art.arc_pts(Vector2(560, 600), 40, 22, 0, PI, 12), Color("e6452f"), 3.5)
	Art.text(b.ci, b.sign_font, Vector2(520, 618), "GARY", 16, Color.WHITE, 3, HORIZONTAL_ALIGNMENT_CENTER, 80)


# -------------------------------------------------------------- Hillwood --

static func _hillwood_street(b: Backdrop) -> void:
	b._city_sky()
	for i in 4:
		var x := -40.0 + i * 340.0
		var col: Color = [Color("a24d38"), Color("8f6f5a"), Color("b8573e"), Color("9a8070")][i]
		b._brick_wall(Rect2(x, 120, 320, 460), col)
		for k in 2:
			b._window(Rect2(x + 50 + k * 140, 180, 80, 100))
		b._door(Rect2(x + 120, 400, 80, 120), Color("3f7a4a"), true)
		for s in 3:
			Art.shape(b.ci, Art.rrect(Rect2(x + 100 - s * 12, 520 + s * 20, 120 + s * 24, 20), 2), Color("c4bfb5"), 3.0)
	b._sidewalk(580)
	b._lamp_post(1180, 640)


static func _hillwood_park(b: Backdrop) -> void:
	_day_sky(b)
	b._skyline(420, Color("a7bfd3"), 99)
	_grass(b, 520)
	_water(b, 545, 590, Color("6fb3e8"))
	_tree(b, 180, 560, 1.0)
	_tree(b, 1100, 560, 0.9, Color("4f9a3a"))
	# Bench
	Art.shape(b.ci, Art.rrect(Rect2(560, 480, 200, 16), 3), Color("8a5a36"), 3.5)
	Art.shape(b.ci, Art.rrect(Rect2(560, 446, 200, 14), 3), Color("8a5a36"), 3.5)
	for x in [575, 745]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 496), Vector2(x, 540)]), 6, Color("3e4a3f"))


static func _cafeteria(b: Backdrop) -> void:
	_room(b, Color("f3ead2"), Color("e3d6b4"), 545, Color("c9c4ba"), "tile")
	Art.shape(b.ci, Art.rrect(Rect2(200, 260, 880, 150), 8), Color("aab3bd"), 5.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(180, 400, 920, 30), 4), Color("cfd3d8"), 4.0)
	for i in 4:
		var x := 290.0 + i * 220.0
		Art.blob(b.ci, Vector2(x, 330), 70, 30, Color("8a96a3"), 3.0)
		Art.blob(b.ci, Vector2(x, 322), 54, 18, Color("8a5a36") if i % 2 == 0 else Color("e5c04a"), 2.0)
	Art.shape(b.ci, Art.rrect(Rect2(460, 120, 360, 60), 8), Color("3f8f4a"), 4.0)
	Art.text(b.ci, b.sign_font, Vector2(460, 162), "TODAY: MEATLOAF", 30, Color.WHITE, 5, HORIZONTAL_ALIGNMENT_CENTER, 360)


static func _boarding_kitchen(b: Backdrop) -> void:
	_room(b, Color("e8e2a8"), Color("d6cc86"), 545, Color("b0573e"), "tile")
	b._window(Rect2(520, 120, 240, 160), Color.WHITE, Color("9ccbe8"))
	# Stove, fridge, counters
	Art.shape(b.ci, Art.rrect(Rect2(120, 330, 200, 215), 8), Color("f2f2ee"), 4.0, 0.1)
	for k in 2:
		Art.blob(b.ci, Vector2(170 + k * 100, 345), 30, 8, Color("3a3d42"), 2.5)
	Art.shape(b.ci, Art.rrect(Rect2(980, 200, 170, 345), 18), Color("bfe3fb"), 4.0, 0.12)
	Art.stroke(b.ci, PackedVector2Array([Vector2(1000, 330), Vector2(1130, 330)]), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(400, 380, 480, 165), 6), Color("c48a4f"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(390, 370, 500, 20), 4), Color("e9e2cf"), 3.0)


static func _alley(b: Backdrop) -> void:
	b._city_sky(Color("8aa4bf"), Color("cdd8e3"), false)
	b._brick_wall(Rect2(-PAD, -PAD, 470, 680), Color("8e4a3a"))
	b._brick_wall(Rect2(890, -PAD, 470, 680), Color("7a5a4a"))
	for side in [0, 1]:
		var x0 := 120.0 if side == 0 else 960.0
		for y in [180, 340]:
			Art.stroke(b.ci, PackedVector2Array([Vector2(x0, y), Vector2(x0 + 220, y)]), 6.0, Color("3a3d42"))
			for k in 5:
				Art.stroke(b.ci, PackedVector2Array([Vector2(x0 + k * 55, y), Vector2(x0 + k * 55, y - 60)]), 3.0, Color("3a3d42"))
	_fill_band(b, 580, H + PAD, Color("6b6f78"))
	Art.shape(b.ci, Art.rrect(Rect2(520, 470, 240, 120), 8), Color("3f7a4a"), 4.0, 0.15)
	Art.shape(b.ci, Art.rrect(Rect2(510, 456, 260, 22), 4), Color("2f5f3a"), 4.0)


# ----------------------------------------------------------- Bluffington --

static func _funnie_house(b: Backdrop) -> void:
	_day_sky(b)
	_grass(b, 560)
	_house(b, Rect2(380, 260, 520, 300), Color("f2e3b4"), Color("4a78d0"))
	_fence(b, 520, 600)
	_tree(b, 140, 560, 0.9)
	Art.shape(b.ci, Art.rrect(Rect2(1060, 430, 60, 40), 10), Color("e6452f"), 3.5)
	Art.limb(b.ci, PackedVector2Array([Vector2(1090, 470), Vector2(1090, 560)]), 6, Color("8a5a36"))


static func _dug_room(b: Backdrop) -> void:
	_room(b, Color("a9cdf0"), Color("8ab4e0"), 545, Color("c48a4f"))
	b._window(Rect2(500, 110, 260, 190), Color.WHITE, Color("cbe9fb"))
	_table(b, 1030, 420, 240, Color("8a5a36"))
	Art.shape(b.ci, Art.rrect(Rect2(990, 392, 80, 28), 3), Color("e6452f"), 3.0)
	Art.text(b.ci, b.sign_font, Vector2(990, 414), "JOURNAL", 13, Color.WHITE, 0, HORIZONTAL_ALIGNMENT_CENTER, 80)
	# Bed
	Art.shape(b.ci, Art.rrect(Rect2(80, 420, 300, 125), 14), Color("5aa84a"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(90, 400, 90, 40), 14), Color.WHITE, 3.5)
	# Poster
	Art.shape(b.ci, Art.rrect(Rect2(260, 140, 140, 180), 4), Color("f6df4c"), 4.0)
	Art.text(b.ci, b.sign_font, Vector2(260, 220), "THE", 26, Color("e6452f"), 4, HORIZONTAL_ALIGNMENT_CENTER, 140)
	Art.text(b.ci, b.sign_font, Vector2(260, 260), "BEETS", 34, Color("e6452f"), 4, HORIZONTAL_ALIGNMENT_CENTER, 140)


static func _bluffington_school(b: Backdrop) -> void:
	_day_sky(b)
	_grass(b, 580)
	b._brick_wall(Rect2(160, 160, 960, 420), Color("c98a5a"))
	Art.shape(b.ci, Art.rrect(Rect2(140, 140, 1000, 30), 4), Color("f2f2ee"), 4.0)
	for i in 6:
		if i == 2 or i == 3:
			continue
		b._window(Rect2(210 + i * 155, 220, 100, 110))
	_label(b, Rect2(440, 200, 400, 50), "BLUFFINGTON ELEMENTARY", Color("4f9a3a"), Color.WHITE, 24)
	b._door(Rect2(560, 400, 160, 180), Color("e6452f"), false)
	Art.limb(b.ci, PackedVector2Array([Vector2(1200, 600), Vector2(1200, 220)]), 6, Color("cfd3d8"))


static func _school_hallway(b: Backdrop) -> void:
	_room(b, Color("f2ebd5"), Color("e6dcbc"), 545, Color("c9c4ba"), "tile")
	for i in 14:
		var x := -40.0 + i * 98.0
		Art.shape(b.ci, Art.rrect(Rect2(x, 210, 88, 335), 4), Color("4a78d0") if i % 2 == 0 else Color("3d6fc0"), 3.5)
		Art.stroke(b.ci, PackedVector2Array([Vector2(x + 20, 240), Vector2(x + 68, 240)]), 3.0, Color("2b4a8a"))
		Art.dot(b.ci, Vector2(x + 72, 380), 4, Color("cfd3d8"))
	Art.shape(b.ci, Art.rrect(Rect2(520, 80, 240, 90), 6), Color("f6df4c"), 4.0)
	Art.text(b.ci, b.sign_font, Vector2(520, 136), "GO BEAVERS!", 30, Color("e6452f"), 4, HORIZONTAL_ALIGNMENT_CENTER, 240)


static func _honker_burger(b: Backdrop) -> void:
	_room(b, Color("fbe3c0"), Color("f2c99a"), 545, Color("e6452f"), "tile")
	Art.shape(b.ci, Art.rrect(Rect2(120, 360, 1040, 185), 8), Color("e6452f"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(100, 344, 1080, 26), 4), Color("f2f2ee"), 4.0)
	for x in [260, 520, 780, 1040]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 548), Vector2(x, 500)]), 8, Color("aab3bd"))
		Art.shape(b.ci, Art.rrect(Rect2(x - 30, 480, 60, 22), 10), Color("f2c14e"), 3.5)
	Art.shape(b.ci, Art.rrect(Rect2(380, 80, 520, 130), 20), Color("f2c14e"), 5.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(380, 160), "HONKER BURGER", 54, Color("e6452f"), 8, HORIZONTAL_ALIGNMENT_CENTER, 520)


static func _lucky_duck_lake(b: Backdrop) -> void:
	_day_sky(b)
	_mountains(b, 420, Color("8fbfa0"), 3)
	_grass(b, 400, Color("8cd06a"))
	_water(b, 440, 560, Color("5a9fd8"))
	_fill_band(b, 560, H + PAD, Color("c9a06a"))
	# Dock
	Art.shape(b.ci, _rect(Rect2(820, 500, 380, 30)), Color("a77a4c"), 3.5)
	for x in [840, 980, 1120]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 530), Vector2(x, 570)]), 10, Color("7a5230"))
	_tree(b, 140, 560, 0.85)


static func _beebe_mansion(b: Backdrop) -> void:
	_day_sky(b)
	_grass(b, 560, Color("8cd06a"))
	Art.shape(b.ci, _rect(Rect2(260, 140, 760, 420)), Color("f2f2ee"), 5.0, 0.08)
	Art.shape(b.ci, PackedVector2Array([Vector2(230, 150), Vector2(640, 40), Vector2(1050, 150)]), Color("9b5fd0"), 5.0, 0.15)
	for x in [340, 500, 780, 940]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 16, 220, 32, 340), 6), Color("e9e2cf"), 3.5)
	b._door(Rect2(590, 380, 100, 180), Color("8a5a36"), true)
	# Fountain basin (water in the moving layer)
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 600), 150, 40, 0, PI, 16), Color("cfd3d8"), 4.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(640, 600), Vector2(640, 520)]), 16, Color("cfd3d8"))


static func _dink_yard(b: Backdrop) -> void:
	_day_sky(b)
	_grass(b, 560)
	_house(b, Rect2(700, 240, 460, 320), Color("e6c9a8"), Color("8a5a36"))
	_fence(b, 500, 580, Color("cfd3d8"))
	# Expensive gadgets
	Art.shape(b.ci, Art.rrect(Rect2(160, 420, 160, 120), 12), Color("aab3bd"), 4.0, 0.15)
	for k in 3:
		Art.dot(b.ci, Vector2(190 + k * 40, 450), 9, [Color("e6452f"), Color("f2c14e"), Color("6dff8a")][k])
	Art.stroke(b.ci, Art.curve(Vector2(240, 420), Vector2(270, 360), Vector2(320, 340), 8), 4.0)
	Art.blob(b.ci, Vector2(325, 336), 14, 14, Color("f28cb8"), 3.0)


static func _bluffington_downtown(b: Backdrop) -> void:
	_day_sky(b)
	var shops := [["MOVIES", Color("e6452f")], ["RECORDS", Color("4a78d0")], ["SWIRLY'S", Color("f28cb8")], ["BOOKS", Color("4f9a3a")]]
	for i in 4:
		var x := 20.0 + i * 320.0
		Art.shape(b.ci, _rect(Rect2(x, 180, 300, 400)), Color("e9e2cf").darkened(i * 0.05), 4.0, 0.1)
		Art.shape(b.ci, Art.rrect(Rect2(x + 10, 200, 280, 60), 8), shops[i][1], 4.0)
		Art.text(b.ci, b.sign_font, Vector2(x + 10, 244), shops[i][0], 32, Color.WHITE, 6, HORIZONTAL_ALIGNMENT_CENTER, 280)
		b._window(Rect2(x + 30, 300, 240, 150), Color("6b6f78"), Color("bfe0f2"), false)
	b._sidewalk(580)


static func _bluffington_park(b: Backdrop) -> void:
	_day_sky(b)
	_grass(b, 540, Color("8cd06a"))
	_tree(b, 160, 560, 1.0)
	_tree(b, 1140, 560, 1.0)
	# Bandstand
	Art.shape(b.ci, _rect(Rect2(420, 470, 440, 70)), Color("f2f2ee"), 4.0)
	for x in [440, 560, 720, 840]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 470), Vector2(x, 300)]), 12, Color("f2f2ee"))
	Art.shape(b.ci, PackedVector2Array([Vector2(390, 310), Vector2(640, 190), Vector2(890, 310)]), Color("e6452f"), 5.0, 0.15)


# --------------------------------------------------------------- Playpen --

static func _pickles_living_room(b: Backdrop) -> void:
	_room(b, Color("f6d9a6"), Color("e8c48a"), 545, Color("9fb87a"), "carpet")
	b._window(Rect2(160, 120, 220, 180), Color.WHITE, Color("bfe0f2"))
	# Couch and TV
	Art.shape(b.ci, Art.rrect(Rect2(820, 380, 360, 165), 24), Color("c97f2a"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(500, 360, 200, 150), 10), Color("6b4428"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(520, 378, 160, 110), 8), Color("3a7a5a"), 3.0)
	Art.text(b.ci, b.sign_font, Vector2(520, 445), "REPTAR!", 24, Color("6dff8a"), 3, HORIZONTAL_ALIGNMENT_CENTER, 160)
	# Playpen netting
	b.ci.draw_rect(Rect2(60, 420, 340, 125), Color(1, 1, 1, 0.35))
	for i in 12:
		Art.stroke(b.ci, PackedVector2Array([Vector2(60 + i * 30, 420), Vector2(60 + i * 30, 545)]), 2.0, Color("8a96a3"))
	Art.shape(b.ci, Art.rrect(Rect2(52, 410, 356, 16), 6), Color("4a78d0"), 3.5)


static func _pickles_backyard(b: Backdrop) -> void:
	_day_sky(b)
	_grass(b, 520)
	_fence(b, 420, 540, Color("e9e2cf"))
	_house(b, Rect2(-60, 200, 380, 320), Color("f6d9a6"), Color("8a5a36"))
	# Sandbox
	Art.shape(b.ci, Art.rrect(Rect2(820, 560, 300, 70), 8), Color("c48a4f"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(834, 568, 272, 40), 6), Color("f1dc9b"), 0.0)
	_bush(b, Vector2(600, 540), 0.8)


static func _pickles_kitchen(b: Backdrop) -> void:
	_room(b, Color("fbf1c8"), Color("f0e09c"), 545, Color("e9e2cf"), "tile")
	# Very high counter with the cookie jar on top
	Art.shape(b.ci, Art.rrect(Rect2(160, 300, 960, 245), 6), Color("6fb3e8"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(140, 284, 1000, 24), 4), Color("f2f2ee"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(820, 200, 90, 90), 20), Color("f2c14e"), 4.0, 0.15)
	Art.text(b.ci, b.sign_font, Vector2(820, 252), "COOKIES", 15, Color("8a5a36"), 3, HORIZONTAL_ALIGNMENT_CENTER, 90)
	b._window(Rect2(380, 90, 260, 160), Color.WHITE, Color("cbe9fb"))


static func _nursery(b: Backdrop) -> void:
	_room(b, Color("c9e6f9"), Color("a7d4f2"), 545, Color("f2d9a8"), "carpet")
	for i in 14:
		Art.dot(b.ci, Vector2(-40 + i * 100, 140 + (i % 2) * 120), 10, Color(1, 1, 1, 0.6))
	# Crib
	Art.shape(b.ci, Art.rrect(Rect2(780, 300, 380, 245), 8), Color(1, 1, 1, 0.3), 0.0)
	for i in 13:
		Art.limb(b.ci, PackedVector2Array([Vector2(790 + i * 30, 310), Vector2(790 + i * 30, 540)]), 6, Color("f2f2ee"))
	Art.shape(b.ci, Art.rrect(Rect2(770, 290, 400, 20), 6), Color("f2f2ee"), 3.5)
	# Toy chest
	Art.shape(b.ci, Art.rrect(Rect2(140, 420, 200, 125), 10), Color("e6452f"), 4.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(140, 492), "TOYS", 30, Color("f2c14e"), 5, HORIZONTAL_ALIGNMENT_CENTER, 200)


static func _stu_basement(b: Backdrop) -> void:
	_room(b, Color("6b6f78"), Color("50545c"), 545, Color("8a8a8a"), "carpet")
	# Stairs and workbench with a half-built toy robot
	for i in 7:
		Art.shape(b.ci, _rect(Rect2(40 + i * 40, 545 - (i + 1) * 40, 300 - i * 40, 40)), Color("8a5a36"), 3.0)
	_table(b, 900, 420, 420, Color("8a5a36"))
	Art.shape(b.ci, Art.rrect(Rect2(840, 300, 120, 120), 12), Color("aab3bd"), 4.0, 0.15)
	for sx in [-1, 1]:
		Art.dot(b.ci, Vector2(900 + sx * 24, 340), 10, Color("f2c14e"))
	Art.blob(b.ci, Vector2(1000, 270), 10, 10, Color("e6452f"), 3.0)
	Art.dot(b.ci, Vector2(640, 60), 18, Color(1, 1, 0.8, 0.9))


static func _playground(b: Backdrop) -> void:
	_day_sky(b)
	_grass(b, 540)
	# Slide
	Art.limb(b.ci, PackedVector2Array([Vector2(260, 560), Vector2(260, 300)]), 10, Color("e6452f"))
	Art.limb(b.ci, PackedVector2Array([Vector2(340, 560), Vector2(340, 300)]), 10, Color("e6452f"))
	Art.shape(b.ci, PackedVector2Array([Vector2(340, 300), Vector2(380, 300), Vector2(560, 560), Vector2(500, 560)]), Color("f2c14e"), 4.0)
	# Swings
	Art.limb(b.ci, PackedVector2Array([Vector2(780, 560), Vector2(860, 260), Vector2(1100, 260), Vector2(1180, 560)]), 10, Color("4a78d0"))
	for x in [920, 1040]:
		Art.stroke(b.ci, PackedVector2Array([Vector2(x - 20, 262), Vector2(x - 20, 470)]), 2.5)
		Art.stroke(b.ci, PackedVector2Array([Vector2(x + 20, 262), Vector2(x + 20, 470)]), 2.5)
		Art.shape(b.ci, Art.rrect(Rect2(x - 28, 468, 56, 10), 3), Color("f2c14e"), 3.0)


static func _reptarland(b: Backdrop) -> void:
	_day_sky(b)
	_fill_band(b, 560, H + PAD, Color("c9c4ba"))
	# Giant Reptar statue
	var g := Color("6fbf6a")
	Art.shape(b.ci, Art.smooth(PackedVector2Array([Vector2(520, 560), Vector2(500, 300), Vector2(560, 160), Vector2(700, 120),
		Vector2(780, 180), Vector2(760, 300), Vector2(780, 560)]), 6), g, 5.0, 0.15)
	for i in 5:
		Art.shape(b.ci, PackedVector2Array([Vector2(540 + i * 10, 200 + i * 60), Vector2(500 + i * 6, 220 + i * 60), Vector2(530 + i * 10, 240 + i * 60)]), Color("9b5fd0"), 3.0)
	Art.blob(b.ci, Vector2(690, 170), 12, 12, Color.WHITE, 3.0)
	Art.dot(b.ci, Vector2(694, 170), 5, INK)
	Art.shape(b.ci, Art.rrect(Rect2(140, 100, 300, 90), 20), Color("9b5fd0"), 5.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(140, 162), "REPTARLAND", 42, Color("6dff8a"), 8, HORIZONTAL_ALIGNMENT_CENTER, 300)


static func _java_lava(b: Backdrop) -> void:
	_room(b, Color("7a4a2a"), Color("5a3820"), 545, Color("3a2416"))
	# Volcano sign and the counter
	Art.shape(b.ci, PackedVector2Array([Vector2(480, 260), Vector2(640, 80), Vector2(800, 260)]), Color("8a5a36"), 5.0, 0.15)
	Art.shape(b.ci, PackedVector2Array([Vector2(600, 125), Vector2(640, 80), Vector2(680, 125)]), Color("e6452f"), 3.0)
	Art.text(b.ci, b.sign_font, Vector2(440, 310), "JAVA LAVA", 44, Color("f2a65a"), 8, HORIZONTAL_ALIGNMENT_CENTER, 400)
	Art.shape(b.ci, Art.rrect(Rect2(200, 380, 880, 165), 6), Color("8a5a36"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(180, 364, 920, 22), 4), Color("c48a4f"), 4.0)
	for x in [320, 520, 760, 960]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 16, 330, 32, 34), 6), Color.WHITE, 3.0)


static func _supermarket(b: Backdrop) -> void:
	_room(b, Color("f2f2ee"), Color("dfe6ea"), 545, Color("e9e2cf"), "tile")
	for row in 3:
		var y := 200.0 + row * 110.0
		Art.shape(b.ci, Art.rrect(Rect2(60, y, 1160, 14), 3), Color("aab3bd"), 3.0)
		for i in 22:
			var c: Color = [Color("e6452f"), Color("f2c14e"), Color("4a78d0"), Color("6fbf6a"), Color("f28cb8")][(i + row) % 5]
			Art.shape(b.ci, Art.rrect(Rect2(70 + i * 52, y - 70, 42, 70), 4), c, 2.5)
	Art.shape(b.ci, Art.rrect(Rect2(500, 40, 280, 60), 8), Color("4a78d0"), 4.0)
	Art.text(b.ci, b.sign_font, Vector2(500, 84), "CEREAL", 34, Color.WHITE, 5, HORIZONTAL_ALIGNMENT_CENTER, 280)


static func _finster_house(b: Backdrop) -> void:
	_day_sky(b)
	_grass(b, 560)
	_house(b, Rect2(360, 260, 560, 300), Color("bfe0f2"), Color("6b6f78"))
	_bush(b, Vector2(260, 540))
	_bush(b, Vector2(1020, 540))


# ----------------------------------------------------------- Team Rokket --

static func _forest_path(b: Backdrop) -> void:
	_day_sky(b)
	for i in 6:
		_tree(b, -60 + i * 260, 520, 0.85 + (i % 2) * 0.2, Color("3f8f3a").lerp(Color("2f6f2a"), (i % 3) / 3.0))
	_grass(b, 540, Color("7cc95a"))
	_fill_band(b, 575, 650, Color("c9a06a"), false)
	# A not-at-all suspicious pile of leaves (the pitfall)
	Art.shape(b.ci, Art.ellipse(Vector2(820, 610), 90, 18), Color("8a5a2b"), 3.0)
	for i in 6:
		Art.blob(b.ci, Vector2(760 + i * 24, 606), 12, 6, Color("4f9a3a"), 2.0, 0.0, i * 0.5)


static func _rokket_hq(b: Backdrop) -> void:
	_room(b, Color("3a2a3e"), Color("2a1e2c"), 545, Color("5a2a2a"), "carpet")
	b._window(Rect2(380, 70, 520, 260), Color("6b4428"), Color("e6a46a"), true)
	Art.shape(b.ci, Art.rrect(Rect2(420, 400, 440, 145), 8), Color("6b4428"), 4.0, 0.15)
	Art.shape(b.ci, Art.rrect(Rect2(400, 384, 480, 22), 4), Color("8a5a36"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(80, 160, 140, 140), 70), Color("f4f4f2"), 5.0)
	Art.text(b.ci, b.sign_font, Vector2(80, 268), "R", 110, Color("e6452f"), 8, HORIZONTAL_ALIGNMENT_CENTER, 140)


static func _monster_clinic(b: Backdrop) -> void:
	_day_sky(b)
	b._sidewalk(585)
	Art.shape(b.ci, _rect(Rect2(260, 220, 760, 365)), Color("f6eef0"), 5.0, 0.08)
	Art.shape(b.ci, Art.rrect(Rect2(230, 160, 820, 80), 30), Color("e6452f"), 5.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(230, 216), "MONSTER CLINIC", 46, Color.WHITE, 8, HORIZONTAL_ALIGNMENT_CENTER, 820)
	b._door(Rect2(560, 400, 160, 185), Color("bfe0f2"), false)
	Art.stroke(b.ci, PackedVector2Array([Vector2(640, 402), Vector2(640, 584)]), 4.0)
	for x in [330, 870]:
		b._window(Rect2(x, 300, 100, 90))


static func _clinic_lobby(b: Backdrop) -> void:
	_room(b, Color("fbe6ea"), Color("f2ccd4"), 545, Color("f2f2ee"), "tile")
	Art.shape(b.ci, Art.rrect(Rect2(380, 360, 520, 185), 30), Color("e6452f"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(360, 344, 560, 24), 6), Color("f2f2ee"), 4.0)
	# Healing machine with six round slots
	Art.shape(b.ci, Art.rrect(Rect2(980, 280, 200, 140), 16), Color("aab3bd"), 4.0, 0.15)
	for i in 6:
		Art.blob(b.ci, Vector2(1020 + (i % 3) * 60, 320 + (i / 3) * 50), 16, 16, Color("f4f4f2"), 3.0)
		Art.stroke(b.ci, PackedVector2Array([Vector2(1004 + (i % 3) * 60, 320 + (i / 3) * 50), Vector2(1036 + (i % 3) * 60, 320 + (i / 3) * 50)]), 3.0, Color("e6452f"))


static func _town_square(b: Backdrop) -> void:
	_day_sky(b)
	for i in 5:
		var x := -40.0 + i * 280.0
		_house(b, Rect2(x, 300, 220, 220), [Color("f2e3b4"), Color("bfe0f2"), Color("f7c6d6"), Color("d6eec8"), Color("f2d9a8")][i], [Color("e6452f"), Color("4a78d0"), Color("9b5fd0"), Color("4f9a3a"), Color("c97f2a")][i])
	_fill_band(b, 540, H + PAD, Color("d9cdb4"))
	for i in 30:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 50, 540), Vector2(-PAD + i * 50 - 30, H + PAD)]), 1.5, Color("b8a77e"))
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 610), 160, 40, 0, PI, 16), Color("cfd3d8"), 4.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(640, 610), Vector2(640, 520)]), 16, Color("cfd3d8"))


static func _crystal_cave(b: Backdrop) -> void:
	Art.gradient_rect(b.ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), Color("1d1433"), Color("3b2a5a"))
	b._sky_bottom = Color("3b2a5a")
	var rng := RandomNumberGenerator.new()
	rng.seed = 13
	for i in 12:
		var x := rng.randf_range(0, W)
		var h := rng.randf_range(60, 160)
		Art.shape(b.ci, PackedVector2Array([Vector2(x - 20, -PAD), Vector2(x + 20, -PAD), Vector2(x, h)]), Color("4a3a6a"), 3.0)
	_fill_band(b, 560, H + PAD, Color("4a3a6a"))
	for c in [Vector2(220, 560), Vector2(470, 570), Vector2(980, 560), Vector2(1150, 575)]:
		for k in 3:
			var off := (k - 1) * 22.0
			Art.shape(b.ci, PackedVector2Array([c + Vector2(off - 14, 0), c + Vector2(off, -80 - k * 20), c + Vector2(off + 14, 0)]),
				[Color("8fe3f2"), Color("c56bd8"), Color("6dffd6")][k], 3.0)


static func _sunny_beach(b: Backdrop) -> void:
	_day_sky(b)
	_water(b, 360, 520, Color("3d8fe0"))
	Art.blob(b.ci, Vector2(1080, 150), 60, 60, Color("ffe08a"), 0.0)
	b._sand(520, Color("f4e2a8"), 8.0)
	# Palm tree
	Art.limb(b.ci, Art.curve(Vector2(180, 600), Vector2(150, 420), Vector2(220, 260), 10), 26, Color("a77a4c"))
	for i in 5:
		var a := -PI * 0.9 + i * 0.45
		var tip := Vector2(220, 260) + Vector2(cos(a), sin(a) + 0.6) * 130
		Art.limb(b.ci, Art.curve(Vector2(220, 260), Vector2(220, 260).lerp(tip, 0.5) + Vector2(0, -30), tip, 8), 18, Color("4f9a3a"))
	# Suspicious submarine shaped like a cat
	Art.shape(b.ci, Art.rrect(Rect2(820, 440, 260, 70), 34), Color("f3e3b4"), 4.0)
	Art.blob(b.ci, Vector2(1060, 440), 40, 34, Color("f3e3b4"), 4.0)


static func _cliff_top(b: Backdrop) -> void:
	b._city_sky(Color("5a9fe0"), Color("f2d9a8"), true)
	_mountains(b, 520, Color("9fb4c8"), 21)
	Art.shape(b.ci, Art.smooth(PackedVector2Array([Vector2(-PAD, 540), Vector2(600, 520), Vector2(1100, 540), Vector2(1200, 640),
		Vector2(1240, H + PAD), Vector2(-PAD, H + PAD)]), 4), Color("8a6a4a"), 5.0, 0.12)
	# The cat-faced hot air balloon, parked
	var bc := Vector2(1060, 200)
	Art.blob(b.ci, bc, 110, 120, Color("f3e3b4"), 5.0, 0.12)
	for sx in [-1, 1]:
		Art.shape(b.ci, PackedVector2Array([bc + Vector2(sx * 40, -100), bc + Vector2(sx * 90, -160), bc + Vector2(sx * 100, -80)]), Color("f3e3b4"), 4.0)
	Art.blob(b.ci, bc + Vector2(0, -60), 16, 12, Color("f2c14e"), 3.0)
	for sx in [-1, 1]:
		Art.stroke(b.ci, PackedVector2Array([bc + Vector2(sx * 60, 100), bc + Vector2(sx * 30, 230)]), 2.5)
	Art.shape(b.ci, Art.rrect(Rect2(bc + Vector2(-40, 230), Vector2(80, 60)), 8), Color("a77a4c"), 4.0)


static func _rokket_camp(b: Backdrop) -> void:
	b._city_sky(Color("2a3a6e"), Color("6a5a8e"), false)
	_tree(b, 120, 540, 1.0, Color("2f5f30"))
	_tree(b, 1180, 540, 0.9, Color("2f5f30"))
	_grass(b, 540, Color("4f8a3a"))
	# Tent
	Art.shape(b.ci, PackedVector2Array([Vector2(760, 560), Vector2(920, 340), Vector2(1080, 560)]), Color("e6452f"), 5.0, 0.15)
	Art.shape(b.ci, PackedVector2Array([Vector2(890, 560), Vector2(920, 440), Vector2(950, 560)]), Color("2b2b33"), 3.0)
	Art.text(b.ci, b.sign_font, Vector2(820, 520), "R", 40, Color.WHITE, 5, HORIZONTAL_ALIGNMENT_CENTER, 60)
	# Fire pit (flames in the moving layer)
	for i in 6:
		var a := TAU * i / 6.0
		Art.blob(b.ci, Vector2(420, 600) + Vector2(cos(a) * 50, sin(a) * 14), 14, 9, Color("8a8a8a"), 2.5)


static func _mecha_lab(b: Backdrop) -> void:
	_room(b, Color("4a4f5c"), Color("373b45"), 545, Color("5f646b"), "tile")
	# Giant robot under construction (cat-shaped, naturally)
	var rc := Vector2(860, 300)
	Art.shape(b.ci, Art.rrect(Rect2(rc + Vector2(-140, -40), Vector2(280, 260)), 30), Color("aab3bd"), 5.0, 0.15)
	Art.blob(b.ci, rc + Vector2(0, -110), 110, 80, Color("cfd3d8"), 5.0, 0.12)
	for sx in [-1, 1]:
		Art.shape(b.ci, PackedVector2Array([rc + Vector2(sx * 50, -170), rc + Vector2(sx * 100, -240), rc + Vector2(sx * 110, -150)]), Color("cfd3d8"), 4.0)
		Art.blob(b.ci, rc + Vector2(sx * 40, -110), 22, 22, Color("f2c14e"), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(rc + Vector2(-60, 60), Vector2(120, 80)), 10), Color("f4f4f2"), 3.0)
	Art.text(b.ci, b.sign_font, rc + Vector2(-60, 120), "R", 56, Color("e6452f"), 5, HORIZONTAL_ALIGNMENT_CENTER, 120)
	# Scaffolding
	for x in [640, 1080]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 545), Vector2(x, 140)]), 8, Color("f2c14e"))
	Art.stroke(b.ci, PackedVector2Array([Vector2(640, 200), Vector2(1080, 200)]), 6.0, Color("f2c14e"))
	_table(b, 240, 440, 280, Color("6b4428"))


# ------------------------------------------------------------ moving bits --

static func draw_fx(b: Backdrop, id: String) -> void:
	var ci := b.ci
	var t := b._t
	match id:
		"bb_downtown", "rock_bottom":
			b._seaweed(60, 620, 110)
		"glove_world":
			var c := Vector2(1040, 300)
			ci.draw_arc(c, 150, 0, TAU, 32, INK, 10.0)
			ci.draw_arc(c, 150, 0, TAU, 32, Color("f2c14e"), 5.0)
			for i in 8:
				var a := t * 0.4 + TAU * i / 8.0
				var p := c + Vector2(cos(a), sin(a)) * 150
				ci.draw_line(c, p, Color("f2c14e"), 4.0)
				Art.blob(ci, p + Vector2(0, 14), 14, 12, [Color("e6452f"), Color("3d8fe0"), Color("6fbf6a"), Color("f28cb8")][i % 4], 2.5)
			b._seaweed(80, 620, 120)
		"kelp_forest":
			for i in 3:
				b._seaweed(200 + i * 400, 630, 160, Color("3f7a3a"))
		"krusty_dining", "sponge_living_room":
			pass
		"lucky_duck_lake":
			for i in 4:
				var y := 460.0 + i * 25.0
				ci.draw_line(Vector2(60 + sin(t + i) * 30 + i * 180, y), Vector2(160 + sin(t + i) * 30 + i * 180, y), Color(1, 1, 1, 0.5), 2.0)
			# A duck bobbing along
			var dk := Vector2(500 + sin(t * 0.3) * 200, 470 + sin(t * 2.0) * 3)
			Art.blob(ci, dk, 20, 12, Color.WHITE, 2.5)
			Art.blob(ci, dk + Vector2(16, -14), 9, 9, Color.WHITE, 2.5)
			Art.shape(ci, PackedVector2Array([dk + Vector2(24, -15), dk + Vector2(34, -12), dk + Vector2(24, -10)]), Color("f2a65a"), 1.5)
		"beebe_mansion", "town_square":
			var base := Vector2(640, 515 if id == "beebe_mansion" else 515)
			for k in 7:
				var a := -PI / 2 + (k - 3) * 0.32
				var pts := PackedVector2Array()
				for s in 8:
					var f := s / 7.0
					pts.append(base + Vector2(cos(a) * f * 120, sin(a) * 90 * f + f * f * 110 + sin(t * 6.0 + k) * 2.0))
				ci.draw_polyline(pts, Color(0.75, 0.9, 1.0, 0.8), 3.0)
		"nursery":
			# Spinning mobile over the crib
			var c := Vector2(970, 120)
			ci.draw_line(c + Vector2(0, -60), c, INK, 2.0)
			for i in 4:
				var a := t * 0.8 + TAU * i / 4.0
				var p := c + Vector2(cos(a) * 70, sin(a) * 14 + 40)
				ci.draw_line(c, p, INK, 1.5)
				Art.blob(ci, p + Vector2(0, 14), 12, 12, [Color("f2c14e"), Color("e6452f"), Color("6fbf6a"), Color("9b5fd0")][i], 2.5)
		"java_lava":
			for k in 4:
				var x := 320.0 + k * 210.0
				var pts := PackedVector2Array()
				for s in 6:
					var f := s / 5.0
					pts.append(Vector2(x + sin(t * 3.0 + f * 5.0 + k) * 5.0, 326 - f * 40))
				ci.draw_polyline(pts, Color(1, 1, 1, 0.45), 2.5)
		"crystal_cave":
			for i in 8:
				var p := Vector2(150 + i * 140, 470 + (i % 3) * 30)
				var tw := 0.3 + 0.7 * absf(sin(t * 2.0 + i))
				ci.draw_circle(p, 3.0 + tw * 3.0, Color(1, 1, 1, tw))
		"sunny_beach":
			for i in 4:
				var y := 380.0 + i * 34.0
				var w := PackedVector2Array()
				for k in 12:
					w.append(Vector2(-PAD + k * 130.0 + sin(t + i) * 20.0, y + sin(t * 2.0 + k + i) * 3.0))
				ci.draw_polyline(w, Color(1, 1, 1, 0.4), 2.0)
		"rokket_camp":
			var c := Vector2(420, 596)
			for k in 3:
				var h := 50.0 + sin(t * 9.0 + k) * 10.0 - k * 10.0
				var flame := PackedVector2Array([c + Vector2(-26 + k * 8, 0), c + Vector2(0, -h), c + Vector2(26 - k * 8, 0)])
				ci.draw_colored_polygon(flame, [Color("e6452f"), Color("f2a65a"), Color("ffe08a")][k])
		"cliff_top", "forest_path", "funnie_house", "bluffington_park", "pickles_backyard", "playground", "finster_house", "hillwood_park":
			for i in 2:
				b._cloud(Vector2(fmod(t * (8 + i * 4) + i * 600, W + 300) - 150, 70 + i * 50), 0.8)
