class_name SetsMore
extends RefCounted
## Locations for Dragonball Z, Attack on Titan, Breaking Bad, Super Mario
## Brothers, Metroid and Kirby. SetsExtra falls through to these for ids it
## doesn't draw. `b` is the Backdrop (its helpers draw into b.ci).

const W := Backdrop.W
const H := Backdrop.H
const PAD := Backdrop.PAD
const INK := Art.INK


static func draw_set(b: Backdrop, id: String) -> bool:
	match id:
		# Dragonball Z
		"kamee_house": _kamee_house(b)
		"capsool_corp": _capsool_corp(b)
		"the_lookout": _the_lookout(b)
		"planet_nameck": _planet_nameck(b)
		"rocky_wasteland": _rocky_wasteland(b)
		"world_tournament": _world_tournament(b)
		"gravity_room": _gravity_room(b)
		"gokku_house": _gokku_house(b)
		"time_chamber": _time_chamber(b)
		"snake_way": _snake_way(b)
		"kie_planet": _kie_planet(b)
		"cel_ring": _cel_ring(b)
		"freeza_ship": _freeza_ship(b)
		"west_city": _west_city(b)
		"korin_tower": _korin_tower(b)
		# Attack on Titan
		"wall_top": _wall_top(b)
		"shiganshina": _shiganshina(b)
		"training_grounds": _training_grounds(b)
		"scout_hq": _scout_hq(b)
		"giant_forest": _giant_forest(b)
		"mess_hall": _mess_hall(b)
		"rooftops": _rooftops(b)
		"wall_gate": _wall_gate(b)
		"titan_plains": _titan_plains(b)
		"stables": _stables(b)
		"old_castle": _old_castle(b)
		"underground_city": _underground_city(b)
		"the_ocean": _the_ocean(b)
		"jaeger_basement": _jaeger_basement(b)
		"trost_district": _trost_district(b)
		# Breaking Bad
		"whyte_house": _whyte_house(b)
		"whyte_backyard": _whyte_backyard(b)
		"rv_desert": _rv_desert(b)
		"car_wash": _car_wash(b)
		"pollitos": _pollitos(b)
		"superlab": _superlab(b)
		"chem_class": _chem_class(b)
		"saul_office": _saul_office(b)
		"dea_office": _dea_office(b)
		"pinkman_house": _pinkman_house(b)
		"schraeder_house": _schraeder_house(b)
		"desert_road": _desert_road(b)
		"crossroads_motel": _crossroads_motel(b)
		"junkyard": _junkyard(b)
		"laundry": _laundry(b)
		# Super Mario Brothers
		"mushroom_kingdom": _mushroom_kingdom(b)
		"peech_castle": _peech_castle(b)
		"peech_throne": _peech_throne(b)
		"pipe_land": _pipe_land(b)
		"underground_bricks": _underground_bricks(b)
		"bowzer_castle": _bowzer_castle(b)
		"sky_land": _sky_land(b)
		"desert_land": _desert_land(b)
		"ice_land": _ice_land(b)
		"water_land": _water_land(b)
		"toad_house": _toad_house(b)
		"boo_mansion": _boo_mansion(b)
		"kong_jungle": _kong_jungle(b)
		"goal_flagpole": _goal_flagpole(b)
		"rainbow_road": _rainbow_road(b)
		# Metroid
		"landing_site": _landing_site(b)
		"crateria": _crateria(b)
		"brinstar": _brinstar(b)
		"norfair": _norfair(b)
		"maridia": _maridia(b)
		"tourian": _tourian(b)
		"wrecked_ship": _wrecked_ship(b)
		"chozo_ruins": _chozo_ruins(b)
		"save_room": _save_room(b)
		"elevator_shaft": _elevator_shaft(b)
		"ceres_station": _ceres_station(b)
		"ridlee_lair": _ridlee_lair(b)
		"krayd_lair": _krayd_lair(b)
		"item_room": _item_room(b)
		"map_station": _map_station(b)
		# Kirby
		"green_greens": _green_greens(b)
		"whispee_forest": _whispee_forest(b)
		"dedeedee_castle": _dedeedee_castle(b)
		"dedeedee_throne": _dedeedee_throne(b)
		"kirbie_house": _kirbie_house(b)
		"butter_building": _butter_building(b)
		"cloudy_park": _cloudy_park(b)
		"fountain_of_dreams": _fountain_of_dreams(b)
		"ice_cream_island": _ice_cream_island(b)
		"orange_ocean": _orange_ocean(b)
		"halberd_deck": _halberd_deck(b)
		"rainbow_resort": _rainbow_resort(b)
		"vegetable_valley": _vegetable_valley(b)
		"grape_garden": _grape_garden(b)
		"yogurt_yard": _yogurt_yard(b)
		_: return false
	return true


# ------------------------------------------------------------ helpers --

static func _sky(b: Backdrop, top: Color, bottom: Color) -> void:
	Art.gradient_rect(b.ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), top, bottom)
	b._sky_bottom = bottom


static func _band(b: Backdrop, y: float, col: Color) -> void:
	SetsExtra._fill_band(b, y, H + PAD, col)


static func _text(b: Backdrop, r: Rect2, s: String, size: int, fg: Color, bg: Color, round_r: float = 14.0) -> void:
	Art.shape(b.ci, Art.rrect(r, round_r), bg, 4.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(r.position.x, r.position.y + r.size.y * 0.5 + size * 0.36), s, size, fg, 6,
		HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


static func _rolling(b: Backdrop, base_y: float, col: Color, seed: int, amp: float = 60.0) -> void:
	var pts := PackedVector2Array()
	for i in 33:
		var x := lerpf(-PAD, W + PAD, i / 32.0)
		pts.append(Vector2(x, base_y - absf(sin(x * 0.006 + seed)) * amp))
	var edge := pts.duplicate()
	pts.append(Vector2(W + PAD, H + PAD))
	pts.append(Vector2(-PAD, H + PAD))
	Art.fill(b.ci, pts, col)
	Art.stroke(b.ci, edge, 4.0)


static func _stars(b: Backdrop, n: int, seed: int, col: Color = Color(1, 1, 1, 0.8), max_y: float = 420.0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for i in n:
		Art.dot(b.ci, Vector2(rng.randf_range(-PAD, W + PAD), rng.randf_range(-PAD, max_y)), rng.randf_range(1.5, 3.5), col)


static func _rock(b: Backdrop, x: float, base_y: float, w: float, h: float, col: Color) -> void:
	Art.shape(b.ci, PackedVector2Array([Vector2(x - w / 2, base_y), Vector2(x - w * 0.42, base_y - h), Vector2(x + w * 0.4, base_y - h * 0.94),
		Vector2(x + w / 2, base_y)]), col, 4.0, 0.15)
	Art.stroke(b.ci, PackedVector2Array([Vector2(x - w * 0.46, base_y - h * 0.5), Vector2(x + w * 0.45, base_y - h * 0.46)]), 2.5, col.darkened(0.25))


## A rough cave: ragged ceiling and floor in `rock`, over a gradient.
static func _cave(b: Backdrop, top: Color, bottom: Color, rock: Color, seed: int, floor_y: float = 560.0) -> void:
	_sky(b, top, bottom)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var ceil := PackedVector2Array([Vector2(-PAD, -PAD)])
	for i in 18:
		ceil.append(Vector2(lerpf(-PAD, W + PAD, i / 17.0), rng.randf_range(40, 130)))
	ceil.append(Vector2(W + PAD, -PAD))
	Art.shape(b.ci, ceil, rock, 4.0, 0.12)
	var fl := PackedVector2Array()
	for i in 18:
		fl.append(Vector2(lerpf(-PAD, W + PAD, i / 17.0), floor_y + rng.randf_range(-14, 14)))
	var edge := fl.duplicate()
	fl.append(Vector2(W + PAD, H + PAD))
	fl.append(Vector2(-PAD, H + PAD))
	Art.fill(b.ci, fl, rock)
	Art.stroke(b.ci, edge, 4.0)


## Sci-fi wall panels with seams and lit strips.
static func _panels(b: Backdrop, wall: Color, light: Color, floor_y: float = 545.0) -> void:
	_sky(b, wall.lightened(0.08), wall.darkened(0.15))
	for i in 9:
		var x := -40.0 + i * 160.0
		Art.shape(b.ci, Art.rrect(Rect2(x, 60, 150, floor_y - 90), 10), wall, 3.0, 0.1)
		Art.shape(b.ci, Art.rrect(Rect2(x + 60, 90, 30, 10), 4), light, 2.0)
	_band(b, floor_y, wall.darkened(0.35))
	for i in 20:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 80, floor_y), Vector2(-PAD + i * 80 - 50, H + PAD)]), 2.0, wall.darkened(0.5))


static func _euro_house(b: Backdrop, r: Rect2, wall: Color, roof: Color) -> void:
	Art.shape(b.ci, SetsExtra._rect(r), wall, 4.5, 0.1)
	# Timber frame
	for k in 3:
		var x := r.position.x + r.size.x * (k + 0.5) / 3.0
		Art.stroke(b.ci, PackedVector2Array([Vector2(x, r.position.y), Vector2(x, r.end.y)]), 5.0, Color("6b4428"))
	Art.stroke(b.ci, PackedVector2Array([Vector2(r.position.x, r.position.y + r.size.y * 0.45), Vector2(r.end.x, r.position.y + r.size.y * 0.45)]),
		5.0, Color("6b4428"))
	Art.shape(b.ci, PackedVector2Array([r.position + Vector2(-20, 4), Vector2(r.get_center().x, r.position.y - r.size.x * 0.5),
		Vector2(r.end.x + 20, r.position.y + 4)]), roof, 4.5, 0.15)
	b._window(Rect2(r.position.x + r.size.x * 0.12, r.position.y + r.size.y * 0.12, r.size.x * 0.22, r.size.y * 0.22), Color("e9e2cf"), Color("2b3a4a"))


static func _cobbles(b: Backdrop, y: float, col: Color = Color("b8ab90")) -> void:
	_band(b, y, col)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for j in 4:
		for i in 26:
			var p := Vector2(-PAD + i * 56 + (j % 2) * 28 + rng.randf_range(-6, 6), y + 22 + j * 38)
			Art.blob(b.ci, p, 22, 12, col.darkened(rng.randf_range(0.05, 0.15)), 2.0)


static func _the_wall(b: Backdrop, top_y: float, bottom_y: float) -> void:
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, top_y, W + PAD * 2, bottom_y - top_y)), Color("c9bea6"), 4.5, 0.1)
	for j in int((bottom_y - top_y) / 40.0):
		var y := top_y + 40 + j * 40
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, y), Vector2(W + PAD, y)]), 2.0, Color("a89c84"))
		for i in 16:
			var x := -PAD + i * 100 + (j % 2) * 50
			Art.stroke(b.ci, PackedVector2Array([Vector2(x, y - 40), Vector2(x, y)]), 2.0, Color("a89c84"))


static func _desert(b: Backdrop, horizon: float = 430.0) -> void:
	_sky(b, Color("5aa8e6"), Color("f6dcae"))
	for m in [[Vector2(-40, horizon), 300, 130], [Vector2(420, horizon), 220, 90], [Vector2(980, horizon), 360, 150]]:
		var c: Vector2 = m[0]
		var w: float = m[1]
		var h: float = m[2]
		Art.shape(b.ci, PackedVector2Array([c, c + Vector2(w * 0.15, -h), c + Vector2(w * 0.85, -h), c + Vector2(w, 0)]), Color("c97f4a"), 4.0, 0.15)
		Art.stroke(b.ci, PackedVector2Array([c + Vector2(w * 0.1, -h * 0.6), c + Vector2(w * 0.9, -h * 0.6)]), 2.5, Color("a8603a"))
	_band(b, horizon, Color("e8c48a"))


static func _cactus(b: Backdrop, x: float, base_y: float, s: float = 1.0) -> void:
	var g := Color("5a9a4a")
	Art.limb(b.ci, PackedVector2Array([Vector2(x, base_y), Vector2(x, base_y - 120 * s)]), 26 * s, g)
	Art.limb(b.ci, PackedVector2Array([Vector2(x, base_y - 50 * s), Vector2(x - 36 * s, base_y - 56 * s), Vector2(x - 36 * s, base_y - 90 * s)]), 16 * s, g)
	Art.limb(b.ci, PackedVector2Array([Vector2(x, base_y - 70 * s), Vector2(x + 34 * s, base_y - 74 * s), Vector2(x + 34 * s, base_y - 106 * s)]), 16 * s, g)


static func _qblock(b: Backdrop, c: Vector2, s: float = 56.0) -> void:
	Art.shape(b.ci, Art.rrect(Rect2(c - Vector2(s, s) / 2, Vector2(s, s)), 6), Color("f2b03e"), 4.0, 0.15)
	for d in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		Art.dot(b.ci, c + d * s * 0.36, 3, INK)
	Art.text(b.ci, b.sign_font, c + Vector2(-s / 2, s * 0.26), "?", int(s * 0.7), Color.WHITE, 5, HORIZONTAL_ALIGNMENT_CENTER, s)


static func _bricks(b: Backdrop, r: Rect2, col: Color = Color("c8642a")) -> void:
	Art.shape(b.ci, SetsExtra._rect(r), col, 4.0)
	var rows := int(r.size.y / 28.0)
	for j in rows:
		var y := r.position.y + (j + 1) * r.size.y / rows
		if j < rows - 1:
			Art.stroke(b.ci, PackedVector2Array([Vector2(r.position.x, y), Vector2(r.end.x, y)]), 2.5)
		var x := r.position.x + (28.0 if j % 2 else 0.0)
		while x < r.end.x:
			if x > r.position.x:
				Art.stroke(b.ci, PackedVector2Array([Vector2(x, y - r.size.y / rows), Vector2(x, y)]), 2.5)
			x += 56.0


static func _pipe(b: Backdrop, x: float, top_y: float, w: float = 110.0, bottom_y: float = 600.0) -> void:
	var g := Color("3fae4a")
	Art.shape(b.ci, SetsExtra._rect(Rect2(x - w * 0.42, top_y + 40, w * 0.84, bottom_y - top_y - 40)), g, 4.0, 0.18)
	Art.shape(b.ci, Art.rrect(Rect2(x - w / 2, top_y, w, 44), 4), g, 4.0, 0.18)
	Art.stroke(b.ci, PackedVector2Array([Vector2(x - w * 0.3, top_y + 50), Vector2(x - w * 0.3, bottom_y - 4)]), 6.0, Color(1, 1, 1, 0.35))


static func _mario_ground(b: Backdrop, y: float = 560.0) -> void:
	_band(b, y, Color("c8642a"))
	for j in 3:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, y + 30 + j * 32), Vector2(W + PAD, y + 30 + j * 32)]), 2.5)
		for i in 26:
			var x := -PAD + i * 64 + (j % 2) * 32
			Art.stroke(b.ci, PackedVector2Array([Vector2(x, y + j * 32), Vector2(x, y + 30 + j * 32)]), 2.5)


static func _hill_eyes(b: Backdrop, c: Vector2, rx: float, ry: float, col: Color) -> void:
	Art.shape(b.ci, Art.arc_pts(c, rx, ry, PI, TAU, 24), col, 4.0, 0.12)
	for sx in [-1, 1]:
		Art.blob(b.ci, c + Vector2(sx * rx * 0.18, -ry * 0.6), 6, 16, INK, 0.0)


static func _kirby_sky(b: Backdrop, top: Color = Color("7ec8f6"), bottom: Color = Color("fbe6f2")) -> void:
	_sky(b, top, bottom)
	for p in [Vector2(160, 110), Vector2(1040, 80), Vector2(640, 60)]:
		Art.shape(b.ci, Art.star(p, 14), Color(1, 1, 0.8, 0.8), 0.0)


static func _kirby_tree(b: Backdrop, x: float, base_y: float, s: float = 1.0, leaf: Color = Color("6fcf6a")) -> void:
	Art.limb(b.ci, PackedVector2Array([Vector2(x, base_y), Vector2(x, base_y - 110 * s)]), 24 * s, Color("c8803a"))
	Art.blob(b.ci, Vector2(x, base_y - 150 * s), 70 * s, 60 * s, leaf, 4.0, 0.12)
	for sx in [-1, 1]:
		Art.blob(b.ci, Vector2(x + sx * 12 * s, base_y - 156 * s), 4, 9, INK, 0.0)


static func _stone_floor(b: Backdrop, y: float, col: Color) -> void:
	_band(b, y, col)
	for i in 12:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 130, y), Vector2(-PAD + i * 130 - 90, H + PAD)]), 2.5, col.darkened(0.2))
	Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, y + 60), Vector2(W + PAD, y + 60)]), 2.5, col.darkened(0.2))


# ----------------------------------------------------- Dragonball Z --

static func _kamee_house(b: Backdrop) -> void:
	_sky(b, Color("4aa8f0"), Color("bfe8fb"))
	SetsExtra._water(b, 380, H + PAD, Color("3a8fd8"))
	Art.shape(b.ci, Art.smooth(PackedVector2Array([Vector2(160, 600), Vector2(300, 470), Vector2(980, 470), Vector2(1120, 600)]), 4),
		Color("f2dc9a"), 4.0, 0.1)
	SetsExtra._tree(b, 260, 520, 0.7, Color("5aa84a"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(500, 300, 320, 200)), Color("f7a6c8"), 4.5, 0.1)
	Art.shape(b.ci, PackedVector2Array([Vector2(470, 306), Vector2(660, 200), Vector2(850, 306)]), Color("e6452f"), 4.5, 0.15)
	b._door(Rect2(630, 400, 60, 100), Color("8a5a36"), false)
	b._window(Rect2(530, 340, 70, 60))
	b._window(Rect2(720, 340, 70, 60))
	Art.text(b.ci, b.sign_font, Vector2(500, 290), "KAMEE HOUSE", 30, Color.WHITE, 6, HORIZONTAL_ALIGNMENT_CENTER, 320)


static func _capsool_corp(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	b._sidewalk(570)
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 570), 420, 380, PI, TAU, 40) + PackedVector2Array([Vector2(1060, 570), Vector2(220, 570)]),
		Color("f4f2ec"), 5.0, 0.12)
	for i in 6:
		b._window(Rect2(330 + i * 110, 380, 70, 60), Color("dfe6ea"), Color("6fb3e8"))
	Art.shape(b.ci, Art.rrect(Rect2(480, 230, 320, 70), 16), Color("4a78d0"), 4.0)
	Art.text(b.ci, b.sign_font, Vector2(480, 278), "CAPSOOL CORP", 38, Color.WHITE, 6, HORIZONTAL_ALIGNMENT_CENTER, 320)


static func _the_lookout(b: Backdrop) -> void:
	_sky(b, Color("3a8ff0"), Color("dff4fb"))
	for i in 5:
		b._cloud(Vector2(i * 300 - 40, 640 + (i % 2) * 30), 2.2)
	Art.shape(b.ci, Art.rrect(Rect2(-PAD, 520, W + PAD * 2, 50), 6), Color("f4f2ec"), 4.0)
	for i in 14:
		Art.shape(b.ci, Art.rrect(Rect2(-60 + i * 100, 540, 60, 22), 4), Color("e9e2cf"), 2.5)
	# Palace with onion domes
	Art.shape(b.ci, SetsExtra._rect(Rect2(440, 260, 400, 260)), Color("f4f2ec"), 4.5, 0.1)
	b._door(Rect2(600, 380, 80, 140), Color("8a5a36"))
	for x in [440, 640, 840]:
		Art.shape(b.ci, Art.smooth(PackedVector2Array([Vector2(x - 60, 270), Vector2(x - 50, 200), Vector2(x, 150), Vector2(x + 50, 200),
			Vector2(x + 60, 270)]), 4), Color("f2c14e"), 4.0, 0.12)
	for x in [200, 1080]:
		SetsExtra._tree(b, x, 520, 0.6, Color("5aa84a"))


static func _planet_nameck(b: Backdrop) -> void:
	_sky(b, Color("4fbf7a"), Color("b8f0c0"))
	Art.blob(b.ci, Vector2(1000, 120), 50, 50, Color("f4f2ec"), 3.0)
	Art.blob(b.ci, Vector2(300, 80), 30, 30, Color("e8f6c8"), 3.0)
	SetsExtra._water(b, 430, 520, Color("3a9ad8"))
	_band(b, 520, Color("4a8fd8").lerp(Color("6fbf6a"), 0.3))
	for p in [Vector2(180, 430), Vector2(560, 440), Vector2(900, 430)]:
		Art.shape(b.ci, PackedVector2Array([p + Vector2(-70, 0), p + Vector2(-50, -150), p + Vector2(50, -160), p + Vector2(70, 0)]), Color("a07a4a"), 4.0, 0.15)
		Art.limb(b.ci, PackedVector2Array([p + Vector2(0, -150), p + Vector2(0, -200)]), 8, Color("8a5a36"))
		Art.blob(b.ci, p + Vector2(0, -220), 34, 30, Color("5aa84a"), 3.5)
	# A round Namekian house
	Art.shape(b.ci, Art.arc_pts(Vector2(1120, 560), 110, 120, PI, TAU, 24) + PackedVector2Array([Vector2(1230, 560), Vector2(1010, 560)]),
		Color("f4f2ec"), 4.0, 0.12)
	for k in 3:
		Art.blob(b.ci, Vector2(1060 + k * 60, 490 - (k % 2) * 20), 14, 12, Color("2b3a4a"), 3.0)
	b._door(Rect2(1090, 500, 60, 60), Color("8a5a36"))


static func _rocky_wasteland(b: Backdrop) -> void:
	_sky(b, Color("6ab4ec"), Color("f2e3c4"))
	_band(b, 520, Color("d9b07a"))
	_rock(b, 140, 520, 220, 240, Color("c48a5a"))
	_rock(b, 520, 520, 160, 140, Color("b87a4a"))
	_rock(b, 1080, 520, 260, 300, Color("c48a5a"))
	# A crater
	Art.shape(b.ci, Art.ellipse(Vector2(760, 600), 160, 30, 30), Color("b88a5a"), 3.5)
	Art.shape(b.ci, Art.ellipse(Vector2(760, 604), 120, 18, 30), Color("9a6a40"), 2.5)


static func _world_tournament(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	# Temple and stands behind the ring
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 300, W + PAD * 2, 200)), Color("e8d0a0"), 4.0)
	for i in 10:
		Art.dot(b.ci, Vector2(60 + i * 128, 340), 14, [Color("e6452f"), Color("4a78d0"), Color("f2c14e")][i % 3])
		Art.dot(b.ci, Vector2(120 + i * 128, 380), 14, [Color("6fbf6a"), Color("f28cb8"), Color("9b5fd0")][i % 3])
	Art.shape(b.ci, PackedVector2Array([Vector2(420, 300), Vector2(640, 160), Vector2(860, 300)]), Color("e6452f"), 4.5, 0.15)
	Art.shape(b.ci, Art.rrect(Rect2(520, 200, 240, 40), 6), Color("f2c14e"), 3.0)
	Art.text(b.ci, b.sign_font, Vector2(520, 230), "TOURNAMENT", 24, Color("e6452f"), 4, HORIZONTAL_ALIGNMENT_CENTER, 240)
	# Stone ring
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 500, W + PAD * 2, 60)), Color("dcd6c8"), 4.0)
	_stone_floor(b, 560, Color("c8c2b4"))


static func _gravity_room(b: Backdrop) -> void:
	Art.gradient_rect(b.ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), Color("e6eef2"), Color("b8c8d0"))
	b._sky_bottom = Color("b8c8d0")
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 560), 760, 560, PI, TAU, 40), Color("dfe6ea"), 5.0)
	_band(b, 560, Color("8a96a3"))
	# The gravity machine in the middle
	Art.shape(b.ci, Art.rrect(Rect2(560, 300, 160, 260), 20), Color("6b6f78"), 4.0, 0.15)
	Art.shape(b.ci, Art.rrect(Rect2(580, 330, 120, 60), 8), Color("17331f"), 3.0)
	Art.text(b.ci, b.sign_font, Vector2(580, 372), "100G", 30, Color("6dff8a"), 0, HORIZONTAL_ALIGNMENT_CENTER, 120)
	for x in [160, 1120]:
		b._porthole(Vector2(x, 300), 50)


static func _gokku_house(b: Backdrop) -> void:
	_sky(b, Color("6ab4ec"), Color("d8f0fb"))
	SetsExtra._mountains(b, 460, Color("8fbfa0"), 31)
	SetsExtra._grass(b, 540, Color("7cc95a"))
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 540), 200, 190, PI, TAU, 30) + PackedVector2Array([Vector2(840, 540), Vector2(440, 540)]),
		Color("f4f2ec"), 4.5, 0.12)
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 380), 70, 50, PI, TAU, 16), Color("e6452f"), 3.5)
	b._door(Rect2(600, 430, 80, 110), Color("8a5a36"))
	b._window(Rect2(480, 420, 70, 60))
	SetsExtra._tree(b, 180, 560, 0.75)
	SetsExtra._tree(b, 1110, 560, 0.65)


static func _time_chamber(b: Backdrop) -> void:
	_sky(b, Color("fbfbf6"), Color("eef0ea"))
	_band(b, 560, Color("f4f2ec"))
	for i in 6:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 300, 560), Vector2(-PAD + i * 300 - 200, H + PAD)]), 2.0, Color("dcdcd2"))
	# The little building you arrive in
	Art.shape(b.ci, SetsExtra._rect(Rect2(80, 340, 300, 220)), Color("f4f2ec"), 4.0, 0.1)
	Art.shape(b.ci, Art.arc_pts(Vector2(230, 340), 150, 70, PI, TAU, 20), Color("f2c14e"), 4.0)
	b._door(Rect2(200, 440, 60, 120), Color("dfe6ea"))
	Art.text(b.ci, b.sign_font, Vector2(500, 200), "1 DAY = 1 YEAR", 40, Color("c8c8c0"), 0, HORIZONTAL_ALIGNMENT_CENTER, 600)


static func _snake_way(b: Backdrop) -> void:
	_sky(b, Color("f2b03e"), Color("fbe6a8"))
	for i in 6:
		b._cloud(Vector2(i * 260, 600 + (i % 2) * 40), 2.4, Color(1, 0.95, 0.75, 0.95))
	var road := PackedVector2Array()
	for i in 21:
		var x := lerpf(-PAD, W + PAD, i / 20.0)
		road.append(Vector2(x, 520 + sin(x * 0.01) * 30))
	var top := road.duplicate()
	var body := road.duplicate()
	for i in range(road.size() - 1, -1, -1):
		body.append(road[i] + Vector2(0, 60))
	Art.shape(b.ci, body, Color("c8a83a"), 4.0, 0.12)
	for i in 20:
		Art.stroke(b.ci, PackedVector2Array([top[i] + Vector2(0, 10), top[i] + Vector2(30, 50)]), 2.5, Color("a88a2a"))
	# The snake's head at the start
	Art.blob(b.ci, Vector2(60, 480), 70, 50, Color("c8a83a"), 4.0, 0.12)
	Art.dot(b.ci, Vector2(90, 460), 8, INK)


static func _kie_planet(b: Backdrop) -> void:
	_sky(b, Color("f2c14e"), Color("fbe6a8"))
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 1300), 1000, 780, PI, TAU, 60), Color("7cc95a"), 5.0, 0.12)
	SetsExtra._tree(b, 1060, 560, 0.7)
	# Little round house and the car
	Art.shape(b.ci, Art.arc_pts(Vector2(300, 550), 120, 120, PI, TAU, 24) + PackedVector2Array([Vector2(420, 550), Vector2(180, 550)]),
		Color("f4f2ec"), 4.0, 0.1)
	b._door(Rect2(270, 470, 60, 80), Color("8a5a36"))
	Art.shape(b.ci, Art.rrect(Rect2(700, 470, 160, 60), 20), Color("e6452f"), 4.0, 0.15)
	for x in [730, 830]:
		Art.blob(b.ci, Vector2(x, 534), 18, 18, Color("2b2b33"), 3.0)


static func _cel_ring(b: Backdrop) -> void:
	_sky(b, Color("6ab4ec"), Color("e8f0d8"))
	SetsExtra._mountains(b, 430, Color("9fb0a0"), 41)
	_band(b, 430, Color("c8b48a"))
	Art.shape(b.ci, PackedVector2Array([Vector2(-PAD, 600), Vector2(80, 470), Vector2(1200, 470), Vector2(W + PAD, 600)]), Color("dcd6c8"), 4.5)
	for i in 8:
		Art.stroke(b.ci, PackedVector2Array([Vector2(80 + i * 160, 470), Vector2(-60 + i * 200, 600)]), 2.0, Color("b8b2a4"))
	for x in [80, 1200]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 20, 380, 40, 100), 4), Color("dcd6c8"), 3.5)


static func _freeza_ship(b: Backdrop) -> void:
	_panels(b, Color("8a7aa8"), Color("f2c14e"))
	Art.shape(b.ci, Art.rrect(Rect2(440, 160, 400, 200), 100), Color("1d1033"), 4.0)
	_stars(b, 24, 9, Color(1, 1, 1, 0.8), 0)
	for i in 3:
		Art.dot(b.ci, Vector2(520 + i * 120, 220 + (i % 2) * 70), 4, Color.WHITE)
	Art.blob(b.ci, Vector2(780, 300), 30, 30, Color("4f9a3a"), 3.0)
	# Hover chair
	Art.shape(b.ci, Art.rrect(Rect2(560, 430, 160, 80), 30), Color("c8ccd6"), 4.0, 0.15)


static func _west_city(b: Backdrop) -> void:
	SetsExtra._day_sky(b)
	for i in 7:
		var x := -40.0 + i * 200.0
		var h := 240.0 + (i % 3) * 80.0
		Art.shape(b.ci, Art.rrect(Rect2(x, 570 - h, 160, h), 60), [Color("f4f2ec"), Color("dfe6ea"), Color("f2e3c4")][i % 3], 4.0, 0.12)
		for k in 3:
			b._window(Rect2(x + 30 + (k % 2) * 60, 600 - h + k * 70, 40, 34), Color("dfe6ea"), Color("6fb3e8"))
	b._sidewalk(570)


static func _korin_tower(b: Backdrop) -> void:
	_sky(b, Color("3a7fd8"), Color("cfe8f6"))
	for i in 4:
		b._cloud(Vector2(i * 360 + 60, 620), 2.6)
	Art.shape(b.ci, SetsExtra._rect(Rect2(560, -PAD, 160, 600)), Color("e8d39a"), 4.5, 0.15)
	for j in 8:
		Art.stroke(b.ci, PackedVector2Array([Vector2(560, j * 80), Vector2(720, j * 80 + 40)]), 3.0, Color("c8a86a"))
	Art.shape(b.ci, Art.rrect(Rect2(380, 470, 520, 70), 30), Color("f4f2ec"), 4.0, 0.1)
	Art.text(b.ci, b.sign_font, Vector2(380, 520), "KORIN TOWER", 36, Color("c8a86a"), 4, HORIZONTAL_ALIGNMENT_CENTER, 520)


# --------------------------------------------------- Attack on Titan --

static func _wall_top(b: Backdrop) -> void:
	_sky(b, Color("7ab0d8"), Color("e8eef0"))
	SetsExtra._mountains(b, 380, Color("9ab0a8"), 17)
	_band(b, 380, Color("9fc08a"))
	_the_wall(b, 470, H + PAD)
	# Cannons along the top
	for x in [180, 1000]:
		Art.shape(b.ci, Art.rrect(Rect2(x, 410, 130, 34), 14), Color("3a3d42"), 4.0, 0.15)
		Art.blob(b.ci, Vector2(x + 40, 450), 22, 22, Color("8a5a36"), 3.5)


static func _shiganshina(b: Backdrop) -> void:
	_sky(b, Color("8ab8e0"), Color("f2ead8"))
	_the_wall(b, 60, 300)
	for i in 5:
		_euro_house(b, Rect2(-40 + i * 280, 330, 220, 230), [Color("f2e3c4"), Color("e8d6b0"), Color("f4ece0")][i % 3],
			[Color("a8503a"), Color("8a5a3a"), Color("b86a4a")][i % 3])
	_cobbles(b, 560)


static func _training_grounds(b: Backdrop) -> void:
	_sky(b, Color("8ab8e0"), Color("eef2e6"))
	_band(b, 440, Color("8fbf6a"))
	for x in [100, 260, 1060, 1200]:
		SetsExtra._tree(b, x, 450, 0.6, Color("3f7a3a"))
	_band(b, 540, Color("c8a878"))
	# Wooden balance rig
	for x in [460, 820]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 560), Vector2(x, 280)]), 18, Color("8a5a36"))
	Art.limb(b.ci, PackedVector2Array([Vector2(460, 290), Vector2(820, 290)]), 16, Color("8a5a36"))
	for x in [600, 680]:
		Art.stroke(b.ci, PackedVector2Array([Vector2(x, 290), Vector2(x, 400)]), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(580, 400, 120, 30), 6), Color("6b4428"), 3.0)


static func _scout_hq(b: Backdrop) -> void:
	_sky(b, Color("8ab8e0"), Color("eef2e6"))
	SetsExtra._grass(b, 560, Color("8fbf6a"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(240, 200, 800, 360)), Color("b8b0a0"), 5.0, 0.1)
	for x in [240, 1040]:
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 70, 120, 140, 440)), Color("a89e8c"), 4.5, 0.12)
		for k in 4:
			Art.shape(b.ci, SetsExtra._rect(Rect2(x - 70 + k * 40, 100, 24, 24)), Color("a89e8c"), 3.0)
	b._door(Rect2(580, 400, 120, 160), Color("6b4428"))
	for x in [380, 820]:
		b._window(Rect2(x, 280, 70, 90), Color("8a7a6a"), Color("2b3a4a"))
	# The Wings of Freedom banner
	Art.shape(b.ci, SetsExtra._rect(Rect2(600, 220, 80, 120)), Color("3f7a3a"), 3.0)
	Art.blob(b.ci, Vector2(640, 270), 22, 26, Color("4a6fa8"), 2.5)


static func _giant_forest(b: Backdrop) -> void:
	_sky(b, Color("4a7a5a"), Color("a8c8a0"))
	_band(b, 560, Color("5a7a3a"))
	for i in 5:
		var x := 60.0 + i * 300.0
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 70, -PAD, 140, 640 + PAD)), Color("8a5a36"), 5.0, 0.15)
		for k in 4:
			Art.stroke(b.ci, PackedVector2Array([Vector2(x - 40 + k * 26, -PAD), Vector2(x - 44 + k * 26, 560)]), 2.5, Color("6b4428"))
	for i in 6:
		Art.blob(b.ci, Vector2(i * 260, 20), 180, 90, Color("3f7a3a"), 4.0, 0.12)


static func _mess_hall(b: Backdrop) -> void:
	SetsExtra._room(b, Color("c8a878"), Color("a8885a"), 545, Color("8a6a4a"))
	for i in 7:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-40 + i * 220, -PAD), Vector2(-40 + i * 220, 545)]), 6.0, Color("8a6a4a"))
	SetsExtra._table(b, 640, 440, 900, Color("a87a4a"))
	for i in 6:
		var x := 260.0 + i * 150.0
		Art.blob(b.ci, Vector2(x, 432), 26, 10, Color("dfe6ea"), 2.5)
		Art.blob(b.ci, Vector2(x + 40, 426), 18, 12, Color("d9a65a"), 2.5)
	b._window(Rect2(540, 120, 200, 160), Color("8a6a4a"), Color("bfe0f2"))


static func _rooftops(b: Backdrop) -> void:
	_sky(b, Color("e89a6a"), Color("fbe0b0"))
	_the_wall(b, 120, 380)
	for i in 6:
		var x := -60.0 + i * 240.0
		var top := 420.0 + (i % 2) * 40.0
		Art.shape(b.ci, PackedVector2Array([Vector2(x, H + PAD), Vector2(x, top + 40), Vector2(x + 110, top - 30), Vector2(x + 220, top + 40),
			Vector2(x + 220, H + PAD)]), Color("b86a4a"), 4.5, 0.15)
		Art.shape(b.ci, SetsExtra._rect(Rect2(x + 150, top - 30, 30, 50)), Color("8a6a5a"), 3.0)


static func _wall_gate(b: Backdrop) -> void:
	_sky(b, Color("8ab8e0"), Color("eef2e6"))
	_the_wall(b, -PAD, 560)
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 560), 240, 300, PI, TAU, 24) + PackedVector2Array([Vector2(880, 560), Vector2(400, 560)]),
		Color("6b4428"), 5.0, 0.12)
	for i in 7:
		Art.stroke(b.ci, PackedVector2Array([Vector2(430 + i * 70, 300), Vector2(430 + i * 70, 560)]), 4.0, Color("4a2f1f"))
	_cobbles(b, 560)


static func _titan_plains(b: Backdrop) -> void:
	_sky(b, Color("7ab0d8"), Color("e8eef0"))
	SetsExtra._mountains(b, 400, Color("9ab0a8"), 23)
	SetsExtra._grass(b, 400, Color("9fc08a"))
	SetsExtra._tree(b, 1100, 470, 0.5, Color("3f7a3a"))
	# The wall far away on the left
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 260, 260, 160)), Color("c9bea6"), 4.0, 0.1)


static func _stables(b: Backdrop) -> void:
	_sky(b, Color("8ab8e0"), Color("eef2e6"))
	_band(b, 540, Color("c8a878"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(80, 260, 1120, 280)), Color("a87a4a"), 5.0, 0.12)
	Art.shape(b.ci, PackedVector2Array([Vector2(40, 270), Vector2(640, 140), Vector2(1240, 270)]), Color("8a4a3a"), 5.0, 0.15)
	for i in 5:
		var x := 140.0 + i * 220.0
		Art.shape(b.ci, SetsExtra._rect(Rect2(x, 360, 160, 180)), Color("6b4428"), 4.0)
		Art.stroke(b.ci, PackedVector2Array([Vector2(x, 450), Vector2(x + 160, 450)]), 4.0)
	for k in 6:
		Art.blob(b.ci, Vector2(200 + k * 180, 560), 50, 14, Color("e8c860"), 2.5)


static func _old_castle(b: Backdrop) -> void:
	_sky(b, Color("3a3a6a"), Color("8a7aa8"))
	Art.blob(b.ci, Vector2(1060, 120), 50, 50, Color("f4f0d8"), 3.0)
	SetsExtra._grass(b, 540, Color("6a8a5a"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(320, 220, 640, 320)), Color("9a9488"), 5.0, 0.15)
	for x in [320, 960]:
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 70, 140, 140, 400)), Color("8a8478"), 4.5, 0.15)
	Art.shape(b.ci, PackedVector2Array([Vector2(800, 220), Vector2(880, 160), Vector2(960, 220)]), Color("6b6f78"), 0.0)
	b._door(Rect2(590, 400, 100, 140), Color("3a2416"))
	Art.shape(b.ci, PackedVector2Array([Vector2(700, 220), Vector2(760, 300), Vector2(820, 220)]), Color("3a3a6a"), 3.0)


static func _underground_city(b: Backdrop) -> void:
	_cave(b, Color("2a2a3a"), Color("4a4a5a"), Color("3a3640"), 7, 570)
	for i in 6:
		_euro_house(b, Rect2(-60 + i * 240, 340, 180, 220), Color("8a8478"), Color("5a4a4a"))
	for i in 3:
		Art.blob(b.ci, Vector2(200 + i * 440, 160), 6, 6, Color("ffe08a"), 0.0)


static func _the_ocean(b: Backdrop) -> void:
	_sky(b, Color("4aa8f0"), Color("e8f6fb"))
	SetsExtra._water(b, 380, 520, Color("3a8fd8"))
	_band(b, 520, Color("f2e3b4"))
	for i in 10:
		Art.blob(b.ci, Vector2(60 + i * 130, 600 + (i % 3) * 20), 8, 5, Color("dcc890"), 2.0)


static func _jaeger_basement(b: Backdrop) -> void:
	SetsExtra._room(b, Color("4a3a2e"), Color("3a2c22"), 545, Color("5a4a3a"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(160, 200, 260, 345)), Color("6b4428"), 4.0, 0.12)
	for k in 4:
		Art.stroke(b.ci, PackedVector2Array([Vector2(160, 260 + k * 70), Vector2(420, 260 + k * 70)]), 3.0)
		for j in 5:
			Art.shape(b.ci, SetsExtra._rect(Rect2(170 + j * 48, 214 + k * 70, 34, 46)), Color("a8603a").lightened(j * 0.05), 2.0)
	SetsExtra._table(b, 760, 450, 300, Color("8a5a36"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(700, 420, 120, 30)), Color("e9e2cf"), 2.5)
	# Hanging lamp
	Art.stroke(b.ci, PackedVector2Array([Vector2(760, -PAD), Vector2(760, 160)]), 2.5)
	Art.blob(b.ci, Vector2(760, 180), 24, 20, Color("ffe08a"), 3.0)


static func _trost_district(b: Backdrop) -> void:
	_sky(b, Color("8ab8e0"), Color("f2ead8"))
	_the_wall(b, 40, 260)
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 260), 120, 140, PI, TAU, 16) + PackedVector2Array([Vector2(760, 260), Vector2(520, 260)]),
		Color("3a2416"), 4.0)
	for i in 5:
		_euro_house(b, Rect2(-40 + i * 280, 300, 240, 260), [Color("e8d6b0"), Color("f4ece0"), Color("f2e3c4")][i % 3],
			[Color("6b4428"), Color("a8503a"), Color("8a5a3a")][i % 3])
	_cobbles(b, 560, Color("a89c84"))


# ----------------------------------------------------------- Breaking Bad --

static func _whyte_house(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f2e6cc"), Color("e2d2b0"), 545, Color("b8a07a"), "carpet")
	# Couch, lamp and the family photo
	Art.shape(b.ci, Art.rrect(Rect2(140, 420, 460, 125), 24), Color("8a7a5a"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(120, 380, 500, 60), 24), Color("8a7a5a"), 4.0, 0.12)
	Art.shape(b.ci, SetsExtra._rect(Rect2(300, 180, 140, 110)), Color("6b4428"), 4.0)
	Art.shape(b.ci, SetsExtra._rect(Rect2(316, 196, 108, 78)), Color("bfe0f2"), 2.5)
	b._window(Rect2(860, 140, 260, 200), Color("f4f2ec"), Color("9ccbe8"))
	Art.limb(b.ci, PackedVector2Array([Vector2(720, 545), Vector2(720, 360)]), 6, Color("6b6f78"))
	Art.shape(b.ci, PackedVector2Array([Vector2(680, 360), Vector2(760, 360), Vector2(740, 300), Vector2(700, 300)]), Color("f2e3b4"), 3.0)


static func _whyte_backyard(b: Backdrop) -> void:
	_sky(b, Color("4aa8f0"), Color("f6e6c8"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 200, 760, 360)), Color("e8d6b0"), 4.5, 0.1)
	Art.shape(b.ci, PackedVector2Array([Vector2(-PAD - 20, 210), Vector2(300, 120), Vector2(700, 210)]), Color("a89880"), 4.5, 0.15)
	# The pizza on the roof
	Art.shape(b.ci, PackedVector2Array([Vector2(380, 150), Vector2(470, 164), Vector2(420, 190)]), Color("f2c14e"), 2.5)
	Art.dot(b.ci, Vector2(420, 168), 5, Color("e6452f"))
	b._window(Rect2(200, 300, 160, 120))
	_band(b, 560, Color("d9c8a0"))
	Art.shape(b.ci, Art.rrect(Rect2(780, 480, 400, 90), 30), Color("4ab8e0"), 4.0)
	Art.stroke(b.ci, Art.curve(Vector2(820, 520), Vector2(980, 510), Vector2(1140, 520), 10), 2.5, Color(1, 1, 1, 0.6))


static func _rv_desert(b: Backdrop) -> void:
	_desert(b)
	_cactus(b, 140, 560, 0.9)
	# The old RV
	Art.shape(b.ci, Art.rrect(Rect2(560, 300, 520, 230), 16), Color("f2ead8"), 5.0, 0.12)
	Art.shape(b.ci, SetsExtra._rect(Rect2(560, 400, 520, 30)), Color("a8603a"), 3.5)
	Art.shape(b.ci, Art.rrect(Rect2(1000, 320, 70, 70), 8), Color("9ccbe8"), 3.0)
	for x in [620, 720, 820]:
		Art.shape(b.ci, Art.rrect(Rect2(x, 330, 70, 50), 6), Color("9ccbe8"), 3.0)
	b._door(Rect2(900, 360, 70, 160), Color("e9e2cf"), false)
	for x in [640, 980]:
		Art.blob(b.ci, Vector2(x, 534), 34, 34, Color("2b2b33"), 4.0)
		Art.blob(b.ci, Vector2(x, 534), 14, 14, Color("aab3bd"), 2.5)


static func _car_wash(b: Backdrop) -> void:
	_sky(b, Color("4aa8f0"), Color("f6e6c8"))
	b._sidewalk(575)
	Art.shape(b.ci, SetsExtra._rect(Rect2(140, 260, 1000, 315)), Color("f2ead8"), 5.0, 0.1)
	Art.shape(b.ci, SetsExtra._rect(Rect2(420, 330, 440, 245)), Color("3a3d42"), 4.0)
	for i in 8:
		Art.limb(b.ci, PackedVector2Array([Vector2(440 + i * 55, 340), Vector2(440 + i * 55, 470)]), 14, [Color("4a78d0"), Color("f2c14e"), Color("e6452f")][i % 3])
	Art.shape(b.ci, Art.rrect(Rect2(380, 150, 520, 90), 14), Color("3fae9a"), 4.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(380, 214), "A2A CAR WASH", 52, Color.WHITE, 8, HORIZONTAL_ALIGNMENT_CENTER, 520)


static func _pollitos(b: Backdrop) -> void:
	SetsExtra._room(b, Color("fbe6a8"), Color("f2d080"), 545, Color("e6452f"), "tile")
	Art.shape(b.ci, Art.rrect(Rect2(200, 380, 880, 165), 6), Color("f2c14e"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(180, 364, 920, 22), 4), Color("f4f2ec"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(300, 60, 680, 120), 20), Color("e6452f"), 5.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(300, 118), "LOS POLLITOS", 52, Color("f2c14e"), 8, HORIZONTAL_ALIGNMENT_CENTER, 680)
	Art.text(b.ci, b.sign_font, Vector2(300, 162), "HERMANOS", 34, Color.WHITE, 6, HORIZONTAL_ALIGNMENT_CENTER, 680)
	# The two chickens on the menu board
	for x in [420, 860]:
		Art.blob(b.ci, Vector2(x, 280), 40, 34, Color("f4f2ec"), 3.5)
		Art.shape(b.ci, PackedVector2Array([Vector2(x + 30, 270), Vector2(x + 52, 280), Vector2(x + 30, 290)]), Color("f2a65a"), 2.5)
		Art.dot(b.ci, Vector2(x + 14, 268), 4, INK)


static func _superlab(b: Backdrop) -> void:
	_panels(b, Color("dfe4e6"), Color("f2c14e"))
	# Big shiny steel tanks
	for x in [200, 1080]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 90, 180, 180, 365), 80), Color("c8ccd6"), 4.0, 0.15)
		Art.stroke(b.ci, PackedVector2Array([Vector2(x - 50, 220), Vector2(x - 50, 500)]), 6.0, Color(1, 1, 1, 0.6))
	SetsExtra._table(b, 640, 430, 420, Color("aab3bd"))
	for k in 3:
		Art.shape(b.ci, PackedVector2Array([Vector2(540 + k * 90, 430), Vector2(556 + k * 90, 370), Vector2(574 + k * 90, 370),
			Vector2(590 + k * 90, 430)]), Color("6fc8f2"), 2.5)


static func _chem_class(b: Backdrop) -> void:
	SetsExtra._room(b, Color("e8eadc"), Color("d4d8c4"), 545, Color("b8a07a"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(260, 100, 760, 260)), Color("2f5a3a"), 6.0)
	Art.text(b.ci, b.sign_font, Vector2(260, 200), "CHEMISTRY", 56, Color(1, 1, 1, 0.85), 0, HORIZONTAL_ALIGNMENT_CENTER, 760)
	Art.text(b.ci, b.sign_font, Vector2(260, 290), "= the study of change", 30, Color(1, 1, 1, 0.75), 0, HORIZONTAL_ALIGNMENT_CENTER, 760)
	# Periodic table poster
	for i in 9:
		for j in 3:
			Art.shape(b.ci, SetsExtra._rect(Rect2(1060 + (i % 3) * 40, 120 + j * 40, 34, 34)), [Color("f2c14e"), Color("6fb3e8"), Color("8fd06a")][j], 2.0)
	SetsExtra._table(b, 640, 440, 520, Color("2b2b33"))


static func _saul_office(b: Backdrop) -> void:
	SetsExtra._room(b, Color("e8dcc0"), Color("d8c8a0"), 545, Color("6b5a4a"), "carpet")
	SetsExtra._table(b, 640, 420, 440, Color("8a5a36"))
	Art.shape(b.ci, Art.rrect(Rect2(540, 300, 200, 120), 14), Color("6b4428"), 4.0)
	# Flags and the big statue
	for x in [160, 1120]:
		Art.limb(b.ci, PackedVector2Array([Vector2(x, 545), Vector2(x, 220)]), 6, Color("f2c14e"))
		Art.shape(b.ci, SetsExtra._rect(Rect2(x, 220, 90, 60)), Color("4a78d0"), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(380, 80, 520, 110), 12), Color("f2c14e"), 4.0, 0.12)
	Art.text(b.ci, b.sign_font, Vector2(380, 148), "BETTER CALL SAUL!", 40, Color("e6452f"), 6, HORIZONTAL_ALIGNMENT_CENTER, 520)


static func _dea_office(b: Backdrop) -> void:
	SetsExtra._room(b, Color("dfe6ea"), Color("c8d0d6"), 545, Color("8a96a3"), "tile")
	for x in [200, 1080]:
		SetsExtra._table(b, x, 430, 280, Color("6b6f78"))
		Art.shape(b.ci, Art.rrect(Rect2(x - 50, 360, 100, 70), 6), Color("2b2b33"), 3.0)
	# Mineral collection shelf
	Art.shape(b.ci, Art.rrect(Rect2(460, 220, 360, 14), 3), Color("8a5a36"), 3.0)
	for i in 6:
		Art.blob(b.ci, Vector2(490 + i * 60, 204), 20, 16, [Color("9b5fd0"), Color("6fc8f2"), Color("f2c14e")][i % 3], 2.5)
	Art.text(b.ci, b.sign_font, Vector2(460, 300), "DEA", 60, Color("2f5fa8"), 6, HORIZONTAL_ALIGNMENT_CENTER, 360)


static func _pinkman_house(b: Backdrop) -> void:
	SetsExtra._room(b, Color("6a5a8a"), Color("4a3a6a"), 545, Color("3a3d42"), "carpet")
	Art.shape(b.ci, Art.rrect(Rect2(160, 420, 520, 125), 24), Color("8a4a3a"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(140, 380, 560, 60), 24), Color("8a4a3a"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(800, 240, 360, 220), 10), Color("1d1d22"), 5.0)
	Art.shape(b.ci, Art.rrect(Rect2(816, 256, 328, 188), 6), Color("3a6aa8"), 2.5)
	# Speakers
	for x in [760, 1200]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 30, 380, 60, 165), 6), Color("2b2b33"), 3.0)
		Art.blob(b.ci, Vector2(x, 480), 18, 18, Color("4a4d55"), 2.5)


static func _schraeder_house(b: Backdrop) -> void:
	SetsExtra._room(b, Color("d9c3f0"), Color("c3a6e0"), 545, Color("9b7ac8"), "carpet")
	Art.shape(b.ci, Art.rrect(Rect2(160, 420, 460, 125), 24), Color("7a3fa0"), 4.0, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(140, 380, 500, 60), 24), Color("7a3fa0"), 4.0, 0.12)
	for x in [760, 960]:
		Art.shape(b.ci, PackedVector2Array([Vector2(x, 545), Vector2(x + 30, 545), Vector2(x + 26, 440), Vector2(x + 4, 440)]), Color("b48be0"), 3.0)
		Art.blob(b.ci, Vector2(x + 15, 420), 26, 30, Color("9b5fd0"), 3.0)
	b._window(Rect2(820, 120, 240, 180), Color("f4f2ec"), Color("d9c3f0"))


static func _desert_road(b: Backdrop) -> void:
	_desert(b, 440)
	Art.fill(b.ci, PackedVector2Array([Vector2(600, 440), Vector2(680, 440), Vector2(1100, H + PAD), Vector2(180, H + PAD)]), Color("4a4d55"))
	for k in 5:
		var t := k / 5.0
		Art.fill(b.ci, PackedVector2Array([Vector2(638 - t * 4, 450 + t * 280), Vector2(642 + t * 4, 450 + t * 280),
			Vector2(643 + t * 6, 470 + t * 300), Vector2(637 - t * 6, 470 + t * 300)]), Color("f2c14e"))
	_cactus(b, 140, 560)
	_cactus(b, 1120, 540, 0.8)


static func _crossroads_motel(b: Backdrop) -> void:
	_sky(b, Color("2a2a5a"), Color("e8806a"))
	b._sidewalk(575)
	Art.shape(b.ci, SetsExtra._rect(Rect2(60, 320, 1160, 255)), Color("e8d6b0"), 5.0, 0.1)
	for i in 6:
		b._door(Rect2(120 + i * 180, 430, 60, 145), [Color("4a78d0"), Color("3fae9a")][i % 2], false)
		b._window(Rect2(190 + i * 180, 440, 50, 50), Color("e9e2cf"), Color("ffe08a"))
	Art.limb(b.ci, PackedVector2Array([Vector2(1180, 575), Vector2(1180, 200)]), 10, Color("6b6f78"))


static func _junkyard(b: Backdrop) -> void:
	_sky(b, Color("6ab4ec"), Color("f2e3c4"))
	_band(b, 540, Color("a89070"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	for i in 8:
		var x := 60.0 + i * 160.0
		var h := rng.randf_range(60, 140)
		Art.shape(b.ci, Art.rrect(Rect2(x, 540 - h, 140, h), 10), [Color("a8503a"), Color("6b6f78"), Color("4a78d0"), Color("8a7a5a")][i % 4], 4.0, 0.15)
		Art.blob(b.ci, Vector2(x + 30, 540), 20, 20, Color("2b2b33"), 3.0)
	SetsExtra._fence(b, 380, 470, Color("9aa3ad"))


static func _laundry(b: Backdrop) -> void:
	SetsExtra._room(b, Color("e8eef0"), Color("d0dce2"), 545, Color("aab3bd"), "tile")
	for i in 6:
		var x := 60.0 + i * 200.0
		Art.shape(b.ci, Art.rrect(Rect2(x, 340, 170, 205), 10), Color("f4f4f2"), 4.0, 0.12)
		Art.blob(b.ci, Vector2(x + 85, 450), 56, 56, Color("aab3bd"), 4.0)
		Art.blob(b.ci, Vector2(x + 85, 450), 42, 42, Color("9ccbe8"), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(380, 100, 520, 80), 10), Color("4a78d0"), 4.0)
	Art.text(b.ci, b.sign_font, Vector2(380, 156), "LAVANDERIA", 44, Color.WHITE, 6, HORIZONTAL_ALIGNMENT_CENTER, 520)


# ------------------------------------------------- Super Mario Brothers --

static func _mushroom_kingdom(b: Backdrop) -> void:
	_sky(b, Color("5c94fc"), Color("9cc4fc"))
	_hill_eyes(b, Vector2(220, 560), 240, 160, Color("5ac85a"))
	_hill_eyes(b, Vector2(1000, 560), 160, 110, Color("4fb04a"))
	for p in [Vector2(260, 120), Vector2(900, 90)]:
		b._cloud(p, 1.4)
	for i in 4:
		if i == 1:
			_qblock(b, Vector2(560 + i * 56, 300))
		else:
			_bricks(b, Rect2(532 + i * 56, 272, 56, 56))
	_qblock(b, Vector2(980, 300))
	_pipe(b, 1180, 430, 120, 560)
	_mario_ground(b)


static func _peech_castle(b: Backdrop) -> void:
	_sky(b, Color("5c94fc"), Color("bfe0fc"))
	SetsExtra._grass(b, 540, Color("5ac85a"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(340, 230, 600, 310)), Color("f4ece0"), 5.0, 0.1)
	for x in [340, 940, 640]:
		var w := 120.0 if x != 640 else 160.0
		var top := 140.0 if x != 640 else 60.0
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - w / 2, top, w, 540 - top)), Color("f4ece0"), 4.5, 0.12)
		Art.shape(b.ci, PackedVector2Array([Vector2(x - w / 2 - 10, top), Vector2(x, top - 90), Vector2(x + w / 2 + 10, top)]), Color("e6452f"), 4.5, 0.15)
	b._door(Rect2(590, 420, 100, 120), Color("8a5a36"))
	Art.shape(b.ci, Art.star(Vector2(640, 330), 34), Color("f2c14e"), 3.5)
	b._window(Rect2(420, 300, 60, 80), Color("f4ece0"), Color("6fb3e8"))
	b._window(Rect2(800, 300, 60, 80), Color("f4ece0"), Color("6fb3e8"))


static func _peech_throne(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f7d6e2"), Color("f2b8cc"), 545, Color("e9e2cf"), "tile")
	for x in [180, 1100]:
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 40, 60, 80, 485)), Color("f4ece0"), 4.0, 0.12)
	Art.fill(b.ci, PackedVector2Array([Vector2(560, 545), Vector2(720, 545), Vector2(800, H + PAD), Vector2(480, H + PAD)]), Color("c1272d"))
	Art.shape(b.ci, Art.rrect(Rect2(560, 280, 160, 265), 30), Color("f2c14e"), 4.5, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(580, 330, 120, 160), 20), Color("e6409a"), 3.0)
	Art.shape(b.ci, Art.star(Vector2(640, 250), 26), Color("f2c14e"), 3.0)
	for x in [360, 920]:
		Art.blob(b.ci, Vector2(x, 160), 40, 40, Color("f2c14e"), 3.0)
		Art.text(b.ci, b.sign_font, Vector2(x - 40, 176), "P", 44, Color("e6409a"), 4, HORIZONTAL_ALIGNMENT_CENTER, 80)


static func _pipe_land(b: Backdrop) -> void:
	_sky(b, Color("5c94fc"), Color("bfe0fc"))
	for i in 6:
		var top := 300.0 + (i % 3) * 70.0
		_pipe(b, 80 + i * 220, top, 120 if i % 2 else 150, 560)
	_mario_ground(b)


static func _underground_bricks(b: Backdrop) -> void:
	_sky(b, Color("0a0a14"), Color("141428"))
	_bricks(b, Rect2(-PAD, -PAD, W + PAD * 2, 140), Color("3a6ab8"))
	for i in 5:
		_bricks(b, Rect2(220 + i * 56, 300, 56, 56), Color("3a6ab8"))
	_band(b, 560, Color("3a6ab8"))
	for j in 3:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, 590 + j * 32), Vector2(W + PAD, 590 + j * 32)]), 2.5)
	_pipe(b, 1100, 380, 120, 560)


static func _bowzer_castle(b: Backdrop) -> void:
	_sky(b, Color("1d0a0a"), Color("4a1a14"))
	for i in 8:
		_bricks(b, Rect2(-PAD + i * 200, -PAD, 180, 200 + (i % 2) * 40), Color("6b6f78"))
	_bricks(b, Rect2(-PAD, 520, 560, 200), Color("6b6f78"))
	_bricks(b, Rect2(760, 520, 600, 200), Color("6b6f78"))
	Art.fill(b.ci, SetsExtra._rect(Rect2(480, 580, 280, 200)), Color("e6452f"))
	Art.stroke(b.ci, PackedVector2Array([Vector2(480, 580), Vector2(760, 580)]), 4.0, Color("f2a65a"))
	# Bridge and the axe
	Art.shape(b.ci, SetsExtra._rect(Rect2(480, 520, 280, 20)), Color("c8642a"), 3.0)
	Art.limb(b.ci, PackedVector2Array([Vector2(860, 520), Vector2(860, 440)]), 6, Color("8a5a36"))
	Art.shape(b.ci, PackedVector2Array([Vector2(860, 440), Vector2(900, 420), Vector2(900, 470), Vector2(860, 460)]), Color("aab3bd"), 3.0)


static func _sky_land(b: Backdrop) -> void:
	_sky(b, Color("5c94fc"), Color("dff0ff"))
	for i in 6:
		b._cloud(Vector2(i * 240 + 40, 600 + (i % 2) * 40), 2.4)
	for p in [Vector2(200, 380), Vector2(1080, 340)]:
		Art.shape(b.ci, Art.rrect(Rect2(p - Vector2(110, 20), Vector2(220, 40)), 20), Color("f2a65a"), 4.0, 0.15)
	_qblock(b, Vector2(640, 260))
	Art.shape(b.ci, Art.rrect(Rect2(380, 540, 520, 40), 20), Color.WHITE, 4.0, 0.1)


static func _desert_land(b: Backdrop) -> void:
	_sky(b, Color("f2b03e"), Color("fbe6a8"))
	Art.blob(b.ci, Vector2(1080, 120), 50, 50, Color("ffe36a"), 3.0)
	for sx in [-1, 1]:
		Art.dot(b.ci, Vector2(1080 + sx * 16, 106), 5, INK)
	Art.shape(b.ci, PackedVector2Array([Vector2(260, 540), Vector2(500, 240), Vector2(740, 540)]), Color("e8c060"), 5.0, 0.15)
	for k in 6:
		Art.stroke(b.ci, PackedVector2Array([Vector2(260 + k * 40, 540 - k * 50), Vector2(740 - k * 40, 540 - k * 50)]), 2.5, Color("c8a040"))
	_band(b, 540, Color("f2d080"))
	_cactus(b, 960, 560)


static func _ice_land(b: Backdrop) -> void:
	_sky(b, Color("8ab8f0"), Color("e8f4fb"))
	for i in 5:
		var x := -40.0 + i * 300.0
		Art.shape(b.ci, PackedVector2Array([Vector2(x, 540), Vector2(x + 140, 300 - (i % 2) * 60), Vector2(x + 280, 540)]), Color("dff0fb"), 4.0, 0.15)
	_band(b, 540, Color("cfe8f8"))
	for i in 4:
		Art.shape(b.ci, Art.rrect(Rect2(160 + i * 300, 440, 56, 56), 6), Color("9cd6f0"), 3.5, 0.1)


static func _water_land(b: Backdrop) -> void:
	_sky(b, Color("2a5ab8"), Color("5ab0e0"))
	_band(b, 560, Color("e8d39a"))
	for i in 5:
		var x := 80.0 + i * 280.0
		for k in 3:
			Art.limb(b.ci, Art.curve(Vector2(x + k * 20, 570), Vector2(x + k * 20 - 20, 480), Vector2(x + k * 30 - 10, 400 + k * 20), 8), 14,
				[Color("f28cb8"), Color("e6452f"), Color("f2a65a")][k])
	for p in [Vector2(400, 200), Vector2(800, 260), Vector2(1000, 160)]:
		Art.blob(b.ci, p, 18, 22, Color("f2c14e"), 3.0)


static func _toad_house(b: Backdrop) -> void:
	SetsExtra._room(b, Color("f7e0b0"), Color("f2c88a"), 545, Color("c48a4f"))
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 380), 820, 520, PI, TAU, 40), Color("f4f4f2"), 5.0)
	for p in [Vector2(200, 80), Vector2(640, 20), Vector2(1080, 80)]:
		Art.blob(b.ci, p, 80, 50, Color("e6302a"), 3.0)
	# Treasure chest
	Art.shape(b.ci, Art.rrect(Rect2(560, 440, 160, 105), 10), Color("a8603a"), 4.0, 0.15)
	Art.shape(b.ci, Art.rrect(Rect2(560, 410, 160, 50), 20), Color("c8803a"), 4.0, 0.12)
	Art.shape(b.ci, SetsExtra._rect(Rect2(624, 450, 32, 30)), Color("f2c14e"), 2.5)


static func _boo_mansion(b: Backdrop) -> void:
	_sky(b, Color("1a1030"), Color("3a2a5a"))
	_stars(b, 40, 4, Color(1, 1, 1, 0.6), 300)
	SetsExtra._grass(b, 560, Color("3a5a3a"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(320, 200, 640, 360)), Color("5a4a6a"), 5.0, 0.12)
	Art.shape(b.ci, PackedVector2Array([Vector2(290, 210), Vector2(640, 60), Vector2(990, 210)]), Color("3a2a4a"), 5.0, 0.15)
	for x in [400, 560, 720, 880]:
		b._window(Rect2(x - 30, 280, 60, 80), Color("3a2a4a"), Color("f2e080"))
	b._door(Rect2(590, 420, 100, 140), Color("2b1a2a"))
	SetsExtra._tree(b, 140, 570, 0.7, Color("3a3a2a"))


static func _kong_jungle(b: Backdrop) -> void:
	_sky(b, Color("3a8a4a"), Color("a8d890"))
	for i in 6:
		Art.limb(b.ci, PackedVector2Array([Vector2(80 + i * 230, -PAD), Vector2(80 + i * 230, 560)]), 50, Color("8a5a36"))
		Art.blob(b.ci, Vector2(80 + i * 230, 40), 140, 80, Color("3f7a3a"), 4.0, 0.12)
	for x in [300, 760]:
		Art.stroke(b.ci, Art.curve(Vector2(x, -PAD), Vector2(x + 20, 200), Vector2(x - 10, 380), 10), 6.0, Color("5a8a3a"))
	_band(b, 560, Color("8a6a3a"))
	Art.shape(b.ci, Art.rrect(Rect2(940, 470, 90, 90), 20), Color("a8603a"), 4.0, 0.15)
	for k in 3:
		Art.stroke(b.ci, PackedVector2Array([Vector2(940, 490 + k * 25), Vector2(1030, 490 + k * 25)]), 3.0)


static func _goal_flagpole(b: Backdrop) -> void:
	_sky(b, Color("5c94fc"), Color("bfe0fc"))
	_hill_eyes(b, Vector2(300, 560), 200, 130, Color("5ac85a"))
	# Little castle
	_bricks(b, Rect2(900, 340, 280, 220))
	b._door(Rect2(1000, 450, 80, 110), Color("1d1d22"))
	Art.limb(b.ci, PackedVector2Array([Vector2(700, 540), Vector2(700, 80)]), 8, Color("6fbf6a"))
	Art.blob(b.ci, Vector2(700, 72), 12, 12, Color("3fae4a"), 3.0)
	Art.shape(b.ci, SetsExtra._rect(Rect2(676, 520, 48, 40)), Color("6b4428"), 3.0)
	_mario_ground(b)


static func _rainbow_road(b: Backdrop) -> void:
	_sky(b, Color("0a0a24"), Color("2a1a4a"))
	_stars(b, 70, 21, Color(1, 1, 1, 0.8), H)
	var cols := [Color("e6452f"), Color("f2a65a"), Color("f2c14e"), Color("6fbf6a"), Color("4a78d0"), Color("9b5fd0")]
	for k in 6:
		Art.fill(b.ci, SetsExtra._rect(Rect2(-PAD, 470 + k * 30, W + PAD * 2, 30)), cols[k])
	Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, 470), Vector2(W + PAD, 470)]), 4.0)


# ------------------------------------------------------------- Metroid --

static func _landing_site(b: Backdrop) -> void:
	_sky(b, Color("2a3a4a"), Color("6a7a7a"))
	_band(b, 540, Color("6a5a4a"))
	_rock(b, 120, 540, 200, 200, Color("5a4a3a"))
	_rock(b, 1180, 540, 220, 260, Color("5a4a3a"))
	# The gunship
	var c := Vector2(660, 380)
	Art.shape(b.ci, Art.smooth(PackedVector2Array([c + Vector2(-260, 40), c + Vector2(-120, -60), c + Vector2(120, -60), c + Vector2(260, 40),
		c + Vector2(120, 90), c + Vector2(-120, 90)]), 5), Color("e6702f"), 5.0, 0.15)
	Art.shape(b.ci, Art.rrect(Rect2(c + Vector2(-60, -50), Vector2(120, 40)), 16), Color("6fdc6a"), 3.5)
	for sx in [-1, 1]:
		Art.limb(b.ci, PackedVector2Array([c + Vector2(sx * 120, 80), c + Vector2(sx * 150, 160)]), 10, Color("6b6f78"))


static func _crateria(b: Backdrop) -> void:
	_sky(b, Color("1a2a3a"), Color("4a5a6a"))
	_rock(b, 260, 560, 420, 280, Color("6a5a7a"))
	_rock(b, 980, 560, 380, 220, Color("5a4a6a"))
	_band(b, 560, Color("5a4a5a"))


static func _brinstar(b: Backdrop) -> void:
	_cave(b, Color("1a3a2a"), Color("3a6a4a"), Color("4a6a3a"), 3)
	for i in 8:
		var x := 60.0 + i * 170.0
		Art.blob(b.ci, Vector2(x, 540), 46, 30, Color("6fbf4a"), 3.5, 0.12)
		Art.blob(b.ci, Vector2(x + 20, 120), 30, 40, Color("e6409a"), 3.0)


static func _norfair(b: Backdrop) -> void:
	_cave(b, Color("3a0a0a"), Color("8a2a1a"), Color("6a2a1a"), 5, 520)
	Art.fill(b.ci, SetsExtra._rect(Rect2(-PAD, 600, W + PAD * 2, 200)), Color("e6452f"))
	Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD, 600), Vector2(W + PAD, 600)]), 4.0, Color("f2c14e"))
	for x in [300, 900]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 120, 500, 240, 40), 8), Color("4a2a1a"), 4.0)


static func _maridia(b: Backdrop) -> void:
	_cave(b, Color("1a3a6a"), Color("3a7ab8"), Color("8a7a5a"), 9)
	for x in [200, 640, 1080]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 30, 200, 60, 360), 10), Color("6b6f78"), 4.0, 0.12)
	for i in 6:
		Art.limb(b.ci, Art.curve(Vector2(100 + i * 220, 560), Vector2(80 + i * 220, 480), Vector2(110 + i * 220, 420), 8), 10, Color("3fae9a"))


static func _tourian(b: Backdrop) -> void:
	_panels(b, Color("4a4d6a"), Color("e64a3a"))
	for x in [160, 1120]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 50, 120, 100, 425), 20), Color("2b2b40"), 4.0)
		for k in 4:
			Art.dot(b.ci, Vector2(x, 180 + k * 90), 14, Color("6fdc6a"))


static func _wrecked_ship(b: Backdrop) -> void:
	_panels(b, Color("4a5a5a"), Color("3a3d42"))
	for i in 5:
		Art.stroke(b.ci, PackedVector2Array([Vector2(100 + i * 260, 60), Vector2(160 + i * 260, 300)]), 4.0, Color("2b3030"))
	Art.shape(b.ci, Art.rrect(Rect2(500, 200, 280, 180), 20), Color("2b3030"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(520, 220, 240, 140), 16), Color("1a2020"), 2.5)


static func _chozo_ruins(b: Backdrop) -> void:
	_cave(b, Color("6a5a3a"), Color("b89a6a"), Color("8a7a5a"), 11)
	for x in [260, 1020]:
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 50, 200, 100, 360)), Color("c8b48a"), 4.0, 0.12)
	# Seated bird statue holding an item ball
	var c := Vector2(640, 420)
	Art.shape(b.ci, Art.rrect(Rect2(c - Vector2(90, 40), Vector2(180, 180)), 20), Color("a89878"), 4.0, 0.12)
	Art.blob(b.ci, c + Vector2(0, -100), 50, 46, Color("a89878"), 4.0, 0.12)
	Art.shape(b.ci, PackedVector2Array([c + Vector2(30, -100), c + Vector2(90, -86), c + Vector2(30, -76)]), Color("a89878"), 3.0)
	Art.blob(b.ci, c + Vector2(0, -20), 26, 26, Color("e6702f"), 3.0)


static func _save_room(b: Backdrop) -> void:
	_panels(b, Color("3a4a6a"), Color("6fd0ff"))
	Art.shape(b.ci, Art.rrect(Rect2(520, 520, 240, 40), 10), Color("6b6f78"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(560, 528, 160, 20), 8), Color("6fd0ff"), 2.5)
	Art.text(b.ci, b.sign_font, Vector2(440, 200), "SAVE", 70, Color("6fd0ff"), 6, HORIZONTAL_ALIGNMENT_CENTER, 400)


static func _elevator_shaft(b: Backdrop) -> void:
	_sky(b, Color("1a1a2a"), Color("3a3a4a"))
	for x in [200, 1080]:
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 120, -PAD, 240, 900)), Color("4a4d55"), 4.0, 0.12)
		for k in 8:
			Art.stroke(b.ci, PackedVector2Array([Vector2(x - 120, k * 100), Vector2(x + 120, k * 100)]), 2.5)
	Art.shape(b.ci, Art.rrect(Rect2(420, 560, 440, 40), 10), Color("6b6f78"), 4.0)
	Art.shape(b.ci, Art.rrect(Rect2(480, 568, 320, 16), 6), Color("6fd0ff"), 2.0)


static func _ceres_station(b: Backdrop) -> void:
	_panels(b, Color("8a96a3"), Color("f2c14e"))
	Art.shape(b.ci, Art.rrect(Rect2(400, 140, 480, 240), 30), Color("0a0a24"), 4.0)
	for i in 12:
		Art.dot(b.ci, Vector2(430 + (i * 37) % 420, 160 + (i * 53) % 200), 2.5, Color.WHITE)
	Art.blob(b.ci, Vector2(780, 300), 46, 46, Color("8a7a5a"), 3.0)


static func _ridlee_lair(b: Backdrop) -> void:
	_cave(b, Color("2a0a1a"), Color("6a1a2a"), Color("4a1a2a"), 13, 560)
	for x in [200, 1080]:
		Art.shape(b.ci, Art.rrect(Rect2(x - 60, 400, 120, 160), 12), Color("5a2a3a"), 4.0)
	Art.fill(b.ci, SetsExtra._rect(Rect2(-PAD, 640, W + PAD * 2, 200)), Color("e6452f"))


static func _krayd_lair(b: Backdrop) -> void:
	_cave(b, Color("1a2a1a"), Color("3a4a2a"), Color("4a5a3a"), 15)
	for i in 5:
		Art.shape(b.ci, PackedVector2Array([Vector2(100 + i * 260, 130), Vector2(130 + i * 260, 260), Vector2(160 + i * 260, 130)]), Color("6a7a4a"), 3.5)


static func _item_room(b: Backdrop) -> void:
	_cave(b, Color("3a2a4a"), Color("6a5a7a"), Color("5a4a5a"), 17)
	Art.shape(b.ci, Art.rrect(Rect2(560, 420, 160, 140), 10), Color("a89878"), 4.0, 0.12)
	Art.blob(b.ci, Vector2(640, 380), 34, 34, Color("e6702f"), 4.0, 0.15)
	Art.dot(b.ci, Vector2(628, 368), 8, Color(1, 1, 1, 0.7))


static func _map_station(b: Backdrop) -> void:
	_panels(b, Color("3a4a6a"), Color("6fdc6a"))
	Art.shape(b.ci, Art.rrect(Rect2(400, 140, 480, 260), 12), Color("17331f"), 4.0)
	for j in 5:
		for i in 8:
			if (i * 7 + j * 3) % 4 != 0:
				Art.shape(b.ci, SetsExtra._rect(Rect2(430 + i * 54, 170 + j * 44, 44, 34)), Color("3f8f6a"), 2.0)
	Art.shape(b.ci, Art.rrect(Rect2(560, 430, 160, 115), 10), Color("6b6f78"), 4.0)


# --------------------------------------------------------------- Kirby --

static func _green_greens(b: Backdrop) -> void:
	_kirby_sky(b)
	_rolling(b, 520, Color("8fe08a"), 1, 80)
	_kirby_tree(b, 220, 540)
	_kirby_tree(b, 1080, 530, 0.8)
	for p in [Vector2(420, 560), Vector2(860, 580)]:
		for k in 5:
			Art.blob(b.ci, p + Vector2(cos(k * 1.26) * 10, sin(k * 1.26) * 10), 8, 8, Color("f7a6c4"), 2.0)
		Art.dot(b.ci, p, 5, Color("f2c14e"))


static func _whispee_forest(b: Backdrop) -> void:
	_kirby_sky(b, Color("8ad8f6"), Color("e8fbe0"))
	_rolling(b, 540, Color("7cd07a"), 3, 40)
	for i in 6:
		_kirby_tree(b, 60 + i * 230, 560 + (i % 2) * 10, 0.9 + (i % 3) * 0.1, [Color("6fcf6a"), Color("5ab85a"), Color("8fe08a")][i % 3])


static func _dedeedee_castle(b: Backdrop) -> void:
	_kirby_sky(b)
	_rolling(b, 540, Color("8fe08a"), 5, 30)
	Art.shape(b.ci, SetsExtra._rect(Rect2(320, 220, 640, 320)), Color("f2e3b4"), 5.0, 0.1)
	for x in [320, 960]:
		Art.shape(b.ci, SetsExtra._rect(Rect2(x - 70, 140, 140, 400)), Color("f2e3b4"), 4.5, 0.12)
		Art.shape(b.ci, PackedVector2Array([Vector2(x - 80, 140), Vector2(x, 50), Vector2(x + 80, 140)]), Color("4a78d0"), 4.5, 0.15)
	b._door(Rect2(580, 400, 120, 140), Color("e6452f"))
	Art.shape(b.ci, Art.rrect(Rect2(500, 260, 280, 80), 20), Color("4a78d0"), 4.0)
	Art.text(b.ci, b.sign_font, Vector2(500, 314), "DEDEEDEE", 40, Color("f2c14e"), 6, HORIZONTAL_ALIGNMENT_CENTER, 280)


static func _dedeedee_throne(b: Backdrop) -> void:
	SetsExtra._room(b, Color("8a6ad8"), Color("6a4ab8"), 545, Color("f2e3b4"), "tile")
	Art.fill(b.ci, PackedVector2Array([Vector2(560, 545), Vector2(720, 545), Vector2(800, H + PAD), Vector2(480, H + PAD)]), Color("e6452f"))
	Art.shape(b.ci, Art.rrect(Rect2(540, 240, 200, 305), 40), Color("f2c14e"), 4.5, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(570, 300, 140, 200), 30), Color("e6452f"), 3.0)
	# Buffet table full of food
	SetsExtra._table(b, 1040, 440, 300, Color("c48a4f"))
	for k in 4:
		Art.blob(b.ci, Vector2(940 + k * 66, 424), 24, 18, [Color("f2a65a"), Color("e6452f"), Color("f7a6c4"), Color("6fbf6a")][k], 2.5)
	Art.shape(b.ci, Art.star(Vector2(640, 180), 40), Color("f2c14e"), 3.5)


static func _kirbie_house(b: Backdrop) -> void:
	_kirby_sky(b)
	_rolling(b, 540, Color("8fe08a"), 7, 30)
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 560), 220, 220, PI, TAU, 30) + PackedVector2Array([Vector2(860, 560), Vector2(420, 560)]),
		Color("f7c6d6"), 5.0, 0.12)
	Art.shape(b.ci, Art.arc_pts(Vector2(640, 560), 60, 110, PI, TAU, 16) + PackedVector2Array([Vector2(700, 560), Vector2(580, 560)]),
		Color("f2c14e"), 4.0)
	Art.shape(b.ci, Art.star(Vector2(640, 500), 22), Color("e6452f"), 2.5)
	b._window(Rect2(470, 420, 60, 60), Color("f4f2ec"), Color("9ccbe8"))
	b._window(Rect2(750, 420, 60, 60), Color("f4f2ec"), Color("9ccbe8"))
	_kirby_tree(b, 160, 560, 0.8)


static func _butter_building(b: Backdrop) -> void:
	_kirby_sky(b, Color("f2c14e"), Color("fbf0c0"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(380, -PAD, 520, 640 + PAD)), Color("f6e6a8"), 5.0, 0.12)
	for j in 6:
		for i in 3:
			b._window(Rect2(430 + i * 160, 40 + j * 100, 80, 60), Color("f4f2ec"), Color("9ccbe8"))
	_band(b, 560, Color("c8a86a"))
	for x in [160, 1120]:
		b._cloud(Vector2(x, 260), 1.6)


static func _cloudy_park(b: Backdrop) -> void:
	_kirby_sky(b, Color("8ab8f6"), Color("e8f4ff"))
	for i in 7:
		b._cloud(Vector2(-40 + i * 220, 580 + (i % 2) * 30), 2.6)
	for i in 3:
		b._cloud(Vector2(200 + i * 400, 200 + (i % 2) * 60), 1.3)


static func _fountain_of_dreams(b: Backdrop) -> void:
	_sky(b, Color("1a1a4a"), Color("5a3a8a"))
	_stars(b, 60, 8, Color(1, 1, 0.8, 0.9), 520)
	_band(b, 560, Color("6a5aa8"))
	Art.shape(b.ci, Art.ellipse(Vector2(640, 540), 260, 50, 40), Color("c8ccf6"), 5.0, 0.1)
	Art.shape(b.ci, Art.ellipse(Vector2(640, 530), 220, 34, 40), Color("8ad8f6"), 3.0)
	Art.shape(b.ci, Art.rrect(Rect2(620, 260, 40, 260), 10), Color("c8ccf6"), 4.0)
	Art.shape(b.ci, Art.star(Vector2(640, 230), 48), Color("ffe36a"), 4.0, 0.12)


static func _ice_cream_island(b: Backdrop) -> void:
	_kirby_sky(b, Color("6ac8f6"), Color("e8fbff"))
	SetsExtra._water(b, 420, 560, Color("4ab8e0"))
	_band(b, 560, Color("fbe6b0"))
	for p in [[Vector2(300, 440), Color("f7a6c4")], [Vector2(560, 450), Color("fff6d6")], [Vector2(900, 440), Color("b8e0a0")]]:
		var c: Vector2 = p[0]
		Art.shape(b.ci, PackedVector2Array([c + Vector2(-50, 0), c + Vector2(0, 130), c + Vector2(50, 0)]), Color("e8b060"), 4.0)
		Art.blob(b.ci, c + Vector2(0, -20), 64, 54, p[1], 4.0, 0.12)


static func _orange_ocean(b: Backdrop) -> void:
	_sky(b, Color("f28a3a"), Color("fbd08a"))
	Art.blob(b.ci, Vector2(640, 380), 110, 110, Color("ffe36a"), 0.0)
	SetsExtra._water(b, 380, 540, Color("f2a65a"))
	_band(b, 540, Color("f6dcae"))
	for x in [160, 1100]:
		Art.limb(b.ci, Art.curve(Vector2(x, 560), Vector2(x + 20, 400), Vector2(x - 10, 280), 10), 22, Color("a8703a"))
		for k in 4:
			var a := -PI / 2 + (k - 1.5) * 0.7
			Art.limb(b.ci, Art.curve(Vector2(x - 10, 280), Vector2(x - 10, 280) + Vector2(cos(a), sin(a)) * 60,
				Vector2(x - 10, 300) + Vector2(cos(a) * 110, sin(a) * 40 + 40), 8), 16, Color("5ab85a"))


static func _halberd_deck(b: Backdrop) -> void:
	_sky(b, Color("4a78d0"), Color("cfe8f6"))
	for i in 4:
		b._cloud(Vector2(i * 360, 160 + (i % 2) * 60), 1.6)
	Art.shape(b.ci, SetsExtra._rect(Rect2(-PAD, 480, W + PAD * 2, 300)), Color("8a96a3"), 5.0, 0.12)
	for i in 14:
		Art.stroke(b.ci, PackedVector2Array([Vector2(-PAD + i * 100, 480), Vector2(-PAD + i * 100 - 60, H + PAD)]), 2.5, Color("6b6f78"))
	Art.shape(b.ci, SetsExtra._rect(Rect2(900, 220, 260, 260)), Color("6b6f78"), 4.5, 0.12)
	Art.shape(b.ci, Art.rrect(Rect2(940, 260, 180, 70), 10), Color("e6452f"), 3.5)
	Art.limb(b.ci, PackedVector2Array([Vector2(160, 480), Vector2(160, 140)]), 14, Color("4a4d55"))
	Art.shape(b.ci, PackedVector2Array([Vector2(170, 150), Vector2(300, 190), Vector2(170, 230)]), Color("2b2f6a"), 3.0)


static func _rainbow_resort(b: Backdrop) -> void:
	_kirby_sky(b, Color("b8a6f6"), Color("fbe6f6"))
	var cols := [Color("e6452f"), Color("f2a65a"), Color("f2c14e"), Color("6fbf6a"), Color("4a78d0"), Color("9b5fd0")]
	for k in 6:
		Art.stroke(b.ci, Art.arc_pts(Vector2(640, 620), 560 - k * 26, 440 - k * 26, PI, TAU, 40), 26.0, cols[k])
	_rolling(b, 560, Color("f7c6e6"), 2, 30)


static func _vegetable_valley(b: Backdrop) -> void:
	_kirby_sky(b)
	_rolling(b, 520, Color("8fe08a"), 9, 50)
	for i in 5:
		var x := 120.0 + i * 260.0
		Art.shape(b.ci, PackedVector2Array([Vector2(x - 30, 560), Vector2(x, 660), Vector2(x + 30, 560)]), Color("f2852a"), 3.5)
		for k in 3:
			Art.limb(b.ci, PackedVector2Array([Vector2(x, 560), Vector2(x - 20 + k * 20, 500)]), 10, Color("4fb04a"))


static func _grape_garden(b: Backdrop) -> void:
	_kirby_sky(b, Color("b8a6f6"), Color("f2e6fb"))
	for i in 5:
		b._cloud(Vector2(i * 300 - 20, 590), 2.4, Color(1, 1, 1, 0.95))
	for x in [260, 1020]:
		Art.limb(b.ci, Art.curve(Vector2(x, 600), Vector2(x - 30, 400), Vector2(x + 20, 220), 10), 14, Color("6fbf4a"))
		for k in 9:
			Art.blob(b.ci, Vector2(x + 20 + (k % 3) * 22 - 22, 240 + (k / 3) * 22), 13, 13, Color("8a4ab8"), 2.5)


static func _yogurt_yard(b: Backdrop) -> void:
	_kirby_sky(b, Color("8ac8f6"), Color("fff6e8"))
	for i in 4:
		var x := -40.0 + i * 360.0
		Art.shape(b.ci, Art.smooth(PackedVector2Array([Vector2(x, 560), Vector2(x + 80, 300), Vector2(x + 180, 220), Vector2(x + 280, 300),
			Vector2(x + 360, 560)]), 5), [Color("fff6e8"), Color("f7d6e6"), Color("e8f0d0")][i % 3], 4.5, 0.12)
		Art.blob(b.ci, Vector2(x + 180, 230), 20, 16, Color("e6452f"), 3.0)
	_band(b, 560, Color("f2e6c8"))


# ------------------------------------------------------------ moving bits --

static func draw_fx(b: Backdrop, id: String) -> void:
	var ci := b.ci
	var t := b._t
	match id:
		"the_lookout", "snake_way", "korin_tower", "sky_land", "cloudy_park", "grape_garden", "halberd_deck":
			for i in 2:
				b._cloud(Vector2(fmod(t * (10 + i * 6) + i * 640, W + 400) - 200, 140 + i * 90), 1.2)
		"kamee_house", "the_ocean", "orange_ocean", "ice_cream_island", "planet_nameck":
			var top: float = {"kamee_house": 400.0, "the_ocean": 400.0, "orange_ocean": 400.0, "ice_cream_island": 440.0, "planet_nameck": 450.0}[id]
			for i in 4:
				var w := PackedVector2Array()
				for k in 12:
					w.append(Vector2(-PAD + k * 130.0 + sin(t + i) * 20.0, top + i * 22.0 + sin(t * 2.0 + k + i) * 3.0))
				ci.draw_polyline(w, Color(1, 1, 1, 0.45), 2.0)
		"gravity_room":
			Art.fill(ci, SetsExtra._rect(Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2)), Color(1, 0.2, 0.1, 0.06 + 0.06 * sin(t * 4.0)))
		"west_city":
			for i in 2:
				var x := fmod(t * (90 + i * 50) + i * 500, W + 300) - 150
				var y := 120.0 + i * 90
				Art.shape(ci, Art.rrect(Rect2(x, y, 90, 30), 14), [Color("e6452f"), Color("f2c14e")][i], 3.0)
		"wall_top", "titan_plains":
			var x := 900.0 if id == "wall_top" else 1100.0
			var base := Vector2(x, 260 if id == "wall_top" else 240)
			ci.draw_line(base, base + Vector2(0, 180), INK, 4.0)
			var flag := PackedVector2Array()
			for k in 7:
				flag.append(base + Vector2(k * 14, sin(t * 4.0 + k * 0.8) * 5.0))
			for k in range(6, -1, -1):
				flag.append(base + Vector2(k * 14, 50 + sin(t * 4.0 + k * 0.8) * 5.0))
			ci.draw_colored_polygon(flag, CLOAK_GREEN)
		"crossroads_motel":
			var on := fmod(t, 2.4) > 0.3
			Art.shape(ci, Art.rrect(Rect2(1080, 160, 200, 80), 10), Color("e6452f") if on else Color("5a2a2a"), 3.0)
			if on:
				Art.text(ci, b.sign_font, Vector2(1080, 214), "MOTEL", 40, Color("ffe08a"), 4, HORIZONTAL_ALIGNMENT_CENTER, 200)
		"laundry":
			for i in 6:
				var c := Vector2(145 + i * 200, 450)
				var a := t * 4.0 + i
				for k in 3:
					var p := c + Vector2(cos(a + k * 2.1), sin(a + k * 2.1)) * 24.0
					Art.dot(ci, p, 8, [Color("f4f4f2"), Color("f28cb8"), Color("6fb3e8")][k])
		"car_wash":
			for i in 8:
				var p := Vector2(460 + i * 50, 480 - fmod(t * 40.0 + i * 37.0, 160.0))
				ci.draw_arc(p, 8 + (i % 3) * 3, 0, TAU, 12, Color(1, 1, 1, 0.8), 2.0)
		"mushroom_kingdom", "sky_land", "goal_flagpole":
			# A spinning coin
			var w := absf(cos(t * 3.0)) * 16.0 + 2.0
			var c := Vector2(780 if id != "goal_flagpole" else 500, 200 + sin(t * 2.0) * 6.0)
			Art.shape(ci, Art.ellipse(c, w, 22, 16), Color("f2c14e"), 3.0)
		"rainbow_road", "fountain_of_dreams", "rainbow_resort":
			for i in 8:
				var p := Vector2(100 + i * 150, 80 + (i % 3) * 90)
				var tw := 0.3 + 0.7 * absf(sin(t * 2.0 + i))
				Art.fill(ci, Art.star(p, 6 + tw * 6), Color(1, 1, 0.8, tw))
		"water_land", "maridia":
			for i in 8:
				var p := Vector2(80 + i * 160 + sin(t + i) * 10, 600 - fmod(t * 50.0 + i * 70.0, 560.0))
				ci.draw_arc(p, 6 + (i % 3) * 3, 0, TAU, 12, Color(1, 1, 1, 0.6), 2.0)
		"bowzer_castle", "norfair", "ridlee_lair":
			var y := 600.0 if id == "bowzer_castle" or id == "norfair" else 640.0
			for i in 5:
				var x := 510.0 + i * 55.0 if id == "bowzer_castle" else 120.0 + i * 250.0
				var k := fmod(t * 0.8 + i * 0.37, 1.0)
				Art.blob(ci, Vector2(x, y - k * 30), 10 * (1.0 - k) + 2, 8 * (1.0 - k) + 2, Color("f2a65a"), 0.0)
		"crateria":
			for i in 40:
				var x := fmod(i * 97.0 + t * 30.0, W + 200) - 100
				var y := fmod(i * 53.0 + t * 500.0, H + 100) - 50
				ci.draw_line(Vector2(x, y), Vector2(x - 6, y + 22), Color(0.8, 0.9, 1, 0.5), 2.0)
		"save_room", "item_room":
			var glow := 0.25 + 0.2 * sin(t * 3.0)
			var c := Vector2(640, 540) if id == "save_room" else Vector2(640, 380)
			ci.draw_circle(c, 140, Color(0.4, 0.85, 1.0, glow * 0.4))
		"brinstar", "chozo_ruins":
			for i in 6:
				var p := Vector2(100 + i * 220 + sin(t * 0.7 + i) * 40, 200 + sin(t + i * 1.3) * 60)
				ci.draw_circle(p, 3, Color(1, 1, 0.6, 0.5 + 0.5 * sin(t * 3.0 + i)))
		"green_greens", "whispee_forest", "vegetable_valley", "kirbie_house", "dedeedee_castle", "yogurt_yard":
			for i in 2:
				b._cloud(Vector2(fmod(t * (8 + i * 5) + i * 600, W + 300) - 150, 70 + i * 60), 0.9)


const CLOAK_GREEN := Color("3f7a3a")
