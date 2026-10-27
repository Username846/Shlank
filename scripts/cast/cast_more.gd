class_name CastMore
extends RefCounted
## The third wave of characters: Dragon Ball Z, Attack on Titan, Breaking Bad,
## Super Mario Brothers, Metroid and Kirby. People are HumanRig settings;
## everyone else has a small drawing function. CastExtra.draw() falls
## through to draw() for any style it doesn't know.

const INK := Art.INK


static func draw(p: Puppet, style: String) -> bool:
	var h := _human(style)
	if not h.is_empty():
		HumanRig.draw(p, h)
		return true
	match style:
		"frieza": _frieza(p)
		"titan": _titan(p)
		"toad": _toad(p)
		"bowser": _bowser(p)
		"yoshi": _yoshi(p)
		"kong": _kong(p)
		"goomba": _goomba(p)
		"troopa": _troopa(p)
		"power_suit": _power_suit(p, Color("e6702f"), Color("f2c14e"), Color("6fdc6a"))
		"dark_suit": _power_suit(p, Color("2b2f4a"), Color("6fd0ff"), Color("ffe36a"))
		"ridley": _ridley(p)
		"kraid": _kraid(p)
		"brain": _mother_brain(p)
		"metroid": _metroid(p)
		"chozo": _chozo(p)
		"pirate": _space_pirate(p)
		"etecoon": _etecoon(p)
		"dachora": _dachora(p)
		"kirby": _ball(p, Color("f7a6c4"), Color("e6304a"), "kirby")
		"waddle_dee": _ball(p, Color("f2a65a"), Color("c8642a"), "dee")
		"bandana_dee": _ball(p, Color("f2a65a"), Color("4a78d0"), "bandana")
		"waddle_doo": _ball(p, Color("e6702f"), Color("c8642a"), "doo")
		"meta_knight": _ball(p, Color("2b2f6a"), Color("7a3fa0"), "meta")
		"marx": _ball(p, Color("f2a1c8"), Color("e6a02f"), "marx")
		"magolor": _magolor(p)
		"dedede": _dedede(p)
		"whispy": _whispy(p)
		_: return false
	return true


# ------------------------------------------------------------------ people --

const SURVEY := Color("c8a06a")
const CLOAK := Color("3f7a3a")


static func _human(style: String) -> Dictionary:
	match style:
		# Dragon Ball Z
		"goku":
			return {"size": "adult", "top": Color("f2852a"), "sleeves": "none", "bottom_col": Color("f2852a"), "shoe": Color("2f5fa8"),
				"hair": "saiyan", "hair_col": Color("1d1d22"), "torso_w": 37.0, "arm_w": 10.0, "torso_extra": _x_gi.bind(Color("2f5fa8")),
				"eye": Vector2(7, 10)}
		"vegeta":
			return {"size": "adult", "top": Color("2f4f9a"), "sleeves": "long", "sleeve": Color("2f4f9a"), "legs": Color("2f4f9a"),
				"shoe": Color("f4f4f2"), "hair": "flame", "hair_col": Color("1d1d22"), "base_lid": 0.3, "torso_w": 34.0,
				"torso_extra": _x_saiyan_armor}
		"gohan":
			return {"size": "teen", "top": Color("5a3fa0"), "sleeves": "none", "bottom_col": Color("5a3fa0"), "shoe": Color("8a5a36"),
				"hair": "saiyan", "hair_col": Color("1d1d22"), "torso_extra": _x_gi.bind(Color("e6452f"))}
		"piccolo":
			return {"size": "adult", "skin": Color("6fbf4a"), "top": Color("6a3fa8"), "sleeves": "none", "bottom_col": Color("6a3fa8"),
				"shoe": Color("8a5a36"), "hair": "none", "ears": false, "torso_w": 36.0, "arm_w": 10.0, "base_lid": 0.25,
				"torso_extra": _x_gi.bind(Color("4a8fe0")), "extra": _x_turban, "back_extra": _x_cape.bind(Color("f4f4f2"))}
		"krillin":
			return {"size": "kid", "top": Color("f2852a"), "sleeves": "none", "bottom_col": Color("f2852a"), "shoe": Color("2f5fa8"),
				"hair": "none", "nose": "none", "torso_extra": _x_gi.bind(Color("2f5fa8")), "extra": _x_forehead_dots}
		"bulma":
			return {"size": "adult", "top": Color("f28cb8"), "bottom": "dress", "flare": 14.0, "hair": "bob", "hair_col": Color("3fbcc0"),
				"lashes": 2, "eye_iris": Color("3d8fe0"), "legs": Puppet.SKIN, "shoe": Color("e6452f"), "torso_w": 28.0}
		"master_roshi":
			return {"size": "adult", "top": Color("f2c14e"), "bottom": "shorts", "bottom_col": Color("c8a86a"), "hair": "none",
				"skin": Color("f2c9a5"), "shoe": Color("8a5a36"), "nose": "big", "torso_w": 30.0, "head_y": -236.0,
				"extra": _x_roshi_face, "back_extra": _x_turtle_shell}
		"cell":
			return {"size": "adult", "skin": Color("8fd06a"), "top": Color("8fd06a"), "sleeves": "none", "legs": Color("8fd06a"),
				"shoe": Color("f4f4f2"), "hair": "none", "ears": false, "eye_iris": Color("9b5fd0"), "base_lid": 0.2, "torso_w": 35.0,
				"torso_extra": _x_cell_spots, "extra": _x_cell_crest, "back_extra": _x_bug_wings}
		"trunks":
			return {"size": "teen", "top": Color("2b3a6a"), "sleeves": "long", "bottom_col": Color("6b6f78"), "shoe": Color("c8a06a"),
				"hair": "bob", "hair_col": Color("b9a6e0"), "eye_iris": Color("3d8fe0"), "torso_extra": _x_open_coat,
				"back_extra": _x_sword_hilt}
		"chi_chi":
			return {"size": "adult", "top": Color("7a3fa0"), "bottom": "dress", "flare": 10.0, "hair": "bun", "hair_col": Color("1d1d22"),
				"lashes": 2, "legs": Color("7a3fa0"), "shoe": Color("2b2b33"), "torso_w": 27.0, "torso_extra": _x_sash.bind(Color("f2c14e"))}
		# Attack on Titan
		"eren", "mikasa", "armin", "levi", "hange", "jean", "sasha", "connie_springer", "reiner", "erwin":
			return _scout(style)
		# Breaking Bad
		"walt":
			return {"size": "adult", "top": Color("8fa06a"), "sleeves": "long", "bottom_col": Color("c8b48a"), "hair": "fringe",
				"hair_col": Color("8a7a6a"), "glasses": true, "nose": "big", "torso_w": 31.0, "extra": _x_heisenberg}
		"pinkman":
			return {"size": "teen", "top": Color("f2c14e"), "sleeves": "long", "bottom_col": Color("3d5aa8"), "hair": "none",
				"torso_w": 30.0, "leg_w": 16.0, "torso_extra": _x_hoodie_strings, "extra": _x_beanie.bind(Color("3a3d42"))}
		"skyler":
			return {"size": "adult", "top": Color("4a78d0"), "bottom": "skirt", "bottom_col": Color("2b3a6a"), "hair": "long",
				"hair_col": Color("e8c860"), "lashes": 2, "legs": Puppet.SKIN, "shoe": Color("2b2b33"), "torso_w": 28.0}
		"hank":
			return {"size": "adult", "top": Color("3d4a5a"), "bottom_col": Color("8a7a5a"), "hair": "none", "torso_w": 40.0, "belly": 10.0,
				"arm_w": 10.0, "brow_w": 5.0, "extra": _x_goatee.bind(Color("6b5a4a"))}
		"marie":
			return {"size": "adult", "top": Color("9b5fd0"), "sleeves": "long", "bottom_col": Color("7a3fa0"), "hair": "bob",
				"hair_col": Color("e8d08a"), "lashes": 2, "shoe": Color("7a3fa0"), "torso_w": 28.0, "torso_extra": _x_pearls_purple}
		"flynn":
			return {"size": "teen", "top": Color("6a7a8a"), "sleeves": "long", "bottom_col": Color("3d4a5a"), "hair": "crew",
				"hair_col": Color("3a2416"), "glasses": true, "torso_w": 30.0}
		"saul":
			return {"size": "adult", "top": Color("d9c27a"), "sleeves": "long", "bottom_col": Color("d9c27a"), "hair": "slick",
				"hair_col": Color("6b4428"), "hairline": -0.5, "shoe": Color("6b4428"), "torso_extra": _x_loud_suit}
		"gus":
			return {"size": "adult", "skin": Color("8a5a3a"), "top": Color("f2c14e"), "sleeves": "long", "bottom_col": Color("2b2b33"),
				"hair": "crew", "hair_col": Color("3a3d42"), "hairline": -0.6, "glasses": true, "torso_w": 31.0, "torso_extra": _x_tie.bind(Color("2b2b33"))}
		"mike":
			return {"size": "adult", "top": Color("a89a7a"), "sleeves": "long", "bottom_col": Color("5a5a5a"), "hair": "fringe",
				"hair_col": Color("e2e2e2"), "base_lid": 0.45, "skin": Color("f2c9a5"), "nose": "big", "torso_w": 32.0,
				"torso_extra": _x_jacket_collar}
		"badger":
			return {"size": "teen", "top": Color("8a8f98"), "sleeves": "long", "bottom_col": Color("3d5aa8"), "hair": "long",
				"hair_col": Color("5a3a24"), "head_shape": "long", "head": Vector2(28, 40), "torso_w": 26.0, "extra": _x_goatee.bind(Color("5a3a24"))}
		"skinny_pete":
			return {"size": "teen", "top": Color("b3202f"), "sleeves": "long", "bottom_col": Color("2b2b33"), "hair": "none",
				"torso_w": 23.0, "arm_w": 7.0, "torso_extra": _x_flannel, "extra": _x_beanie.bind(Color("2b2b33"))}
		# Super Mario Brothers
		"mario", "luigi", "wario":
			var col: Color = {"mario": Color("e6302a"), "luigi": Color("3fae4a"), "wario": Color("f2c14e")}[style]
			var bib: Color = {"mario": Color("2f5fd8"), "luigi": Color("2f5fd8"), "wario": Color("7a3fa0")}[style]
			var letter: String = {"mario": "M", "luigi": "L", "wario": "W"}[style]
			return {"size": "teen" if style == "luigi" else "kid", "top": col, "sleeves": "long", "bottom_col": bib,
				"shoe": Color("6b4428"), "hair": "crew", "hair_col": Color("5a3a24"), "nose": "big", "ears": true,
				"torso_w": 34.0 if style != "luigi" else 28.0, "belly": 12.0 if style == "wario" else 4.0,
				"head": Vector2(40, 40) if style != "luigi" else Vector2(34, 40),
				"torso_extra": _x_overalls.bind(bib), "extra": _x_plumber.bind(col, letter, style == "wario")}
		"peach", "daisy":
			var peach := style == "peach"
			return {"size": "adult", "top": Color("f7a6c8") if peach else Color("f2a03a"), "bottom": "dress", "flare": 34.0,
				"hair": "long", "hair_col": Color("f4d24e") if peach else Color("b8573e"), "lashes": 2,
				"eye_iris": Color("3d8fe0") if peach else Color("3fae9a"), "legs": Color("f7a6c8") if peach else Color("f2a03a"),
				"shoe": Color("e6452f"), "sleeves": "short", "sleeve": Color("f7c6d6") if peach else Color("f6d06a"), "torso_w": 27.0,
				"torso_extra": _x_brooch.bind(Color("3d8fe0") if peach else Color("6fbf6a")), "extra": _x_crown}
		# Metroid
		"adam":
			return {"size": "adult", "top": Color("6b7a5a"), "sleeves": "long", "bottom_col": Color("4a5a3a"), "hair": "crew",
				"hair_col": Color("a8a8a8"), "hairline": -0.5, "base_lid": 0.3, "torso_w": 33.0, "torso_extra": _x_medals}
		# Kirby
		"adeleine":
			return {"size": "kid", "top": Color("6fbf6a"), "bottom": "skirt", "bottom_col": Color("4a78d0"), "hair": "long",
				"hair_col": Color("6b4428"), "lashes": 2, "sock": Color.WHITE, "shoe": Color("8a5a36"), "extra": _x_painter_beret}
		"ribbon":
			return {"size": "baby", "top": Color("f7a6c8"), "bottom": "dress", "flare": 16.0, "hair": "bob", "hair_col": Color("e6409a"),
				"lashes": 2, "eye": Vector2(8, 10), "legs": Puppet.SKIN, "shoe": Color("e6452f"), "extra": _x_big_bow,
				"back_extra": _x_fairy_wings}
	return {}


## Survey Corps uniform shared by the Attack on Titan cast.
static func _scout(style: String) -> Dictionary:
	var c := {"size": "teen", "top": SURVEY, "sleeves": "long", "bottom_col": Color("efe8d6"), "shoe": Color("5a3a24"),
		"torso_w": 27.0, "torso_extra": _x_harness, "back_extra": _x_cloak}
	match style:
		"eren":
			c.merge({"hair": "crew", "hair_col": Color("4a2f1f"), "hairline": -0.15, "eye_iris": Color("3fae7a")})
		"mikasa":
			c.merge({"hair": "bob", "hair_col": Color("1d1d22"), "hairline": -0.2, "eye_iris": Color("4a4d55"), "lashes": 1,
				"extra": _x_scarf})
		"armin":
			c.merge({"size": "kid", "hair": "bob", "hair_col": Color("f4d24e"), "hairline": -0.1, "eye_iris": Color("3d8fe0"),
				"torso_w": 26.0})
		"levi":
			c.merge({"hair": "bob", "hair_col": Color("1d1d22"), "hairline": -0.15, "base_lid": 0.45, "eye_iris": Color("6b6f78"),
				"torso_extra": _x_cravat})
		"hange":
			c.merge({"size": "adult", "hair": "ponytail", "hair_col": Color("6b4428"), "glasses": true, "eye_iris": Color("8a5a36"),
				"torso_w": 28.0, "extra": _x_goggles})
		"jean":
			c.merge({"hair": "crew", "hair_col": Color("a07a4a"), "head_shape": "long", "head": Vector2(30, 40), "base_lid": 0.2})
		"sasha":
			c.merge({"hair": "ponytail", "hair_col": Color("8a5a36"), "eye_iris": Color("8a5a36"), "lashes": 1})
		"connie_springer":
			c.merge({"size": "kid", "hair": "crew", "hair_col": Color("6b6f78"), "hairline": -0.75, "torso_w": 25.0})
		"reiner":
			c.merge({"size": "adult", "hair": "crew", "hair_col": Color("e8c860"), "hairline": -0.45, "torso_w": 38.0, "arm_w": 10.0,
				"eye_iris": Color("c8a06a"), "base_lid": 0.15})
		"erwin":
			c.merge({"size": "adult", "hair": "slick", "hair_col": Color("f4d24e"), "brow_w": 6.0, "eye_iris": Color("3d8fe0"),
				"torso_w": 35.0, "torso_extra": _x_bolo})
	return c


# ---------------------------------------------------- costume details --

static func _x_gi(p: Puppet, under: Color) -> void:
	# Undershirt showing at the V neck, and a belt
	var sh := -196.0 if p.style in ["goku", "piccolo"] else (-178.0 if p.style == "gohan" else -126.0)
	var hip := -104.0 if p.style in ["goku", "piccolo"] else (-92.0 if p.style == "gohan" else -62.0)
	Art.shape(p.ci, PackedVector2Array([Vector2(-14, sh), Vector2(14, sh), Vector2(0, sh + 34)]), under, 2.5)
	var tw := 34.0 if p.style in ["goku", "piccolo"] else 28.0
	Art.shape(p.ci, Art.rrect(Rect2(-tw, hip - 14, tw * 2, 14), 4), under if p.style != "gohan" else Color("e6452f"), 3.0)
	if p.style in ["goku", "krillin"]:
		# Turtle school badge
		Art.blob(p.ci, Vector2(-tw * 0.45, sh + 30), 9, 9, Color.WHITE, 2.5)


static func _x_saiyan_armor(p: Puppet) -> void:
	var plate := PackedVector2Array([Vector2(-36, -192), Vector2(36, -192), Vector2(32, -130), Vector2(-32, -130)])
	Art.shape(p.ci, plate, Color("f4f4f2"), 3.5, 0.12)
	for sx in [-1, 1]:
		Art.shape(p.ci, Art.rrect(Rect2(sx * 34 - 14, -200, 28, 20), 6), Color("f2c14e"), 3.0)


static func _x_turban(p: Puppet, hc: Vector2) -> void:
	for sx in [-1, 1]:
		Art.shape(p.ci, PackedVector2Array([hc + Vector2(sx * 30, -6), hc + Vector2(sx * 52, -22), hc + Vector2(sx * 32, 12)]), Color("6fbf4a"), 3.0)
	Art.shape(p.ci, Art.arc_pts(hc + Vector2(0, -10), 38, 38, PI, TAU, 16), Color("f4f4f2"), 3.5)
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-14, -40), Vector2(28, 14)), 4), Color("6a3fa8"), 2.5)
	for sx in [-1, 1]:
		Art.stroke(p.ci, Art.curve(hc + Vector2(sx * 8, -46), hc + Vector2(sx * 12, -66), hc + Vector2(sx * 24, -72), 8), 3.0, Color("6fbf4a"))


static func _x_cape(p: Puppet, hc: Vector2, col: Color) -> void:
	var cape := PackedVector2Array([hc + Vector2(-52, 64), hc + Vector2(52, 64), hc + Vector2(70, 250), hc + Vector2(-70, 250)])
	Art.shape(p.ci, Art.smooth(cape, 3), col, 4.0, 0.12)
	for sx in [-1, 1]:
		Art.blob(p.ci, hc + Vector2(sx * 46, 70), 22, 14, col, 3.5)


static func _x_forehead_dots(p: Puppet, hc: Vector2) -> void:
	for i in 6:
		Art.dot(p.ci, hc + Vector2(-10 + (i % 3) * 10, -28 + (i / 3) * 9), 2.5, INK)


static func _x_roshi_face(p: Puppet, hc: Vector2) -> void:
	# Big white beard, sunglasses over the eyes
	var beard := PackedVector2Array([hc + Vector2(-26, 14), hc + Vector2(26, 14), hc + Vector2(20, 70), hc + Vector2(0, 92),
		hc + Vector2(-20, 70)])
	Art.shape(p.ci, Art.smooth(beard, 4), Color("f4f4f2"), 3.0)
	for sx in [-1, 1]:
		Art.blob(p.ci, hc + Vector2(sx * 13, -4), 13, 10, Color("1d1d22"), 3.0)
	Art.stroke(p.ci, PackedVector2Array([hc + Vector2(-2, -4), hc + Vector2(2, -4)]), 3.0)


static func _x_turtle_shell(p: Puppet, hc: Vector2) -> void:
	var c := hc + Vector2(-20, 110)
	Art.blob(p.ci, c, 46, 62, Color("5aa84a"), 4.0, 0.15)
	for k in 3:
		Art.blob(p.ci, c + Vector2(0, -34 + k * 32), 14, 12, Color("3f7a3a"), 2.5)


static func _x_cell_spots(p: Puppet) -> void:
	for d in [Vector2(-18, -180), Vector2(14, -168), Vector2(-6, -146), Vector2(20, -130), Vector2(-22, -126)]:
		Art.dot(p.ci, d, 5, Color("1d1d22"))
	Art.shape(p.ci, Art.rrect(Rect2(-34, -118, 68, 16), 4), Color("2b2b33"), 3.0)


static func _x_cell_crest(p: Puppet, hc: Vector2) -> void:
	for sx in [-1, 1]:
		Art.shape(p.ci, PackedVector2Array([hc + Vector2(sx * 6, -32), hc + Vector2(sx * 30, -66), hc + Vector2(sx * 34, -20)]), Color("2b2b33"), 3.0)
	Art.stroke(p.ci, PackedVector2Array([hc + Vector2(-10, 28), hc + Vector2(-16, 36)]), 3.0, Color("9b5fd0"))


static func _x_bug_wings(p: Puppet, hc: Vector2) -> void:
	for sx in [-1, 1]:
		var base := hc + Vector2(sx * 24, 80)
		Art.shape(p.ci, PackedVector2Array([base, base + Vector2(sx * 70, 10), base + Vector2(sx * 60, 130), base + Vector2(sx * 10, 120)]),
			Color("2b2b33"), 3.5, 0.1)


static func _x_open_coat(p: Puppet) -> void:
	Art.shape(p.ci, PackedVector2Array([Vector2(-10, -176), Vector2(10, -176), Vector2(12, -96), Vector2(-12, -96)]), Color("2b2b33"), 2.5)
	Art.shape(p.ci, Art.rrect(Rect2(-30, -100, 60, 10), 3), Color("f2c14e"), 2.5)


static func _x_sword_hilt(p: Puppet, hc: Vector2) -> void:
	Art.limb(p.ci, PackedVector2Array([hc + Vector2(-38, 30), hc + Vector2(30, 140)]), 9, Color("8a5a36"))
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-50, 18), Vector2(28, 10)), 3), Color("c8a06a"), 2.5)


static func _x_sash(p: Puppet, col: Color) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(-29, -118, 58, 12), 4), col, 3.0)


static func _x_harness(p: Puppet) -> void:
	var adult := p.style in ["hange", "reiner", "erwin"]
	var kid := p.style in ["armin", "connie_springer"]
	var sh := -196.0 if adult else (-126.0 if kid else -178.0)
	var hip := -104.0 if adult else (-62.0 if kid else -92.0)
	var tw := 26.0 if not adult else 30.0
	# White shirt between the jacket fronts, then the gear straps
	Art.shape(p.ci, PackedVector2Array([Vector2(-9, sh), Vector2(9, sh), Vector2(10, hip), Vector2(-10, hip)]), Color("f4f2ec"), 2.5)
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([Vector2(sx * tw * 0.75, sh + 4), Vector2(sx * tw * 0.55, hip + 4)]), 5.0, Color("5a3a24"))
	Art.stroke(p.ci, PackedVector2Array([Vector2(-tw, (sh + hip) * 0.5 + 6), Vector2(tw, (sh + hip) * 0.5 + 6)]), 5.0, Color("5a3a24"))
	# Wings badge on the chest
	var bc := Vector2(-tw * 0.45, sh + 22)
	Art.blob(p.ci, bc, 9, 10, Color("4a6fa8"), 2.0)
	Art.dot(p.ci, bc + Vector2(-2, 0), 3, Color.WHITE)


static func _x_cloak(p: Puppet, hc: Vector2) -> void:
	var top := hc + Vector2(0, 60)
	var cloak := PackedVector2Array([top + Vector2(-40, 0), top + Vector2(40, 0), top + Vector2(54, 112), top + Vector2(-54, 112)])
	Art.shape(p.ci, Art.smooth(cloak, 3), CLOAK, 4.0, 0.12)
	Art.blob(p.ci, top + Vector2(-20, 60), 10, 11, Color("4a6fa8"), 2.0)


static func _x_scarf(p: Puppet, hc: Vector2) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-26, 32), Vector2(52, 18)), 8), Color("c1272d"), 3.0)
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(8, 40), Vector2(14, 40)), 5), Color("c1272d"), 3.0)


static func _x_cravat(p: Puppet) -> void:
	_x_harness(p)
	Art.blob(p.ci, Vector2(0, -170), 10, 9, Color.WHITE, 2.5)
	Art.shape(p.ci, PackedVector2Array([Vector2(-7, -164), Vector2(7, -164), Vector2(0, -142)]), Color.WHITE, 2.5)


static func _x_goggles(p: Puppet, hc: Vector2) -> void:
	Art.stroke(p.ci, PackedVector2Array([hc + Vector2(-34, -24), hc + Vector2(34, -24)]), 5.0, Color("5a3a24"))
	for sx in [-1, 1]:
		Art.blob(p.ci, hc + Vector2(sx * 13, -26), 11, 9, Color("9ccbe8"), 3.0)


static func _x_bolo(p: Puppet) -> void:
	_x_harness(p)
	Art.blob(p.ci, Vector2(0, -184), 6, 6, Color("3fae7a"), 2.0)
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([Vector2(sx * 2, -180), Vector2(sx * 4, -156)]), 2.0)


static func _x_heisenberg(p: Puppet, hc: Vector2) -> void:
	_x_goatee(p, hc, Color("6b5a4a"))
	# Pork-pie hat
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-50, -30), Vector2(100, 12)), 5), Color("1d1d22"), 3.0)
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-30, -58), Vector2(60, 32)), 8), Color("1d1d22"), 3.0)
	Art.stroke(p.ci, PackedVector2Array([hc + Vector2(-30, -34), hc + Vector2(30, -34)]), 3.0, Color("3a3d42"))


static func _x_goatee(p: Puppet, hc: Vector2, col: Color) -> void:
	Art.shape(p.ci, Art.smooth(PackedVector2Array([hc + Vector2(-14, 26), hc + Vector2(14, 26), hc + Vector2(8, 44),
		hc + Vector2(-8, 44)]), 3), col, 2.5)
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([hc + Vector2(sx * 4, 15), hc + Vector2(sx * 14, 18)]), 4.0, col)


static func _x_beanie(p: Puppet, hc: Vector2, col: Color) -> void:
	Art.shape(p.ci, Art.arc_pts(hc + Vector2(0, -10), 37, 34, PI, TAU, 16), col, 3.5)
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-38, -18), Vector2(76, 12)), 5), col.lightened(0.15), 3.0)


static func _x_hoodie_strings(p: Puppet) -> void:
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([Vector2(sx * 8, -176), Vector2(sx * 9, -148)]), 3.0, Color.WHITE)
	Art.shape(p.ci, Art.rrect(Rect2(-22, -130, 44, 26), 6), Color("e0b03e"), 2.5)


static func _x_pearls_purple(p: Puppet) -> void:
	for i in 7:
		var a := PI * 0.2 + PI * 0.6 * i / 6.0
		Art.dot(p.ci, Vector2(cos(a) * 15, -192 + sin(a) * 10), 3.5, Color("d9c3f0"))


static func _x_loud_suit(p: Puppet) -> void:
	Art.shape(p.ci, PackedVector2Array([Vector2(-14, -196), Vector2(14, -196), Vector2(0, -150)]), Color("8fd0f6"), 2.5)
	_x_tie(p, Color("e6452f"))
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([Vector2(sx * 14, -196), Vector2(sx * 6, -150)]), 3.0)


static func _x_tie(p: Puppet, col: Color) -> void:
	Art.shape(p.ci, PackedVector2Array([Vector2(-5, -194), Vector2(5, -194), Vector2(4, -156), Vector2(0, -148), Vector2(-4, -156)]), col, 2.0)


static func _x_jacket_collar(p: Puppet) -> void:
	for sx in [-1, 1]:
		Art.shape(p.ci, PackedVector2Array([Vector2(0, -194), Vector2(sx * 22, -198), Vector2(sx * 14, -174)]), Color("8a7c5c"), 2.5)
	Art.stroke(p.ci, PackedVector2Array([Vector2(0, -192), Vector2(0, -110)]), 2.5)


static func _x_flannel(p: Puppet) -> void:
	for i in 4:
		Art.stroke(p.ci, PackedVector2Array([Vector2(-22, -170 + i * 18), Vector2(22, -170 + i * 18)]), 2.0, Color("5a1a1a"))
	for i in 3:
		Art.stroke(p.ci, PackedVector2Array([Vector2(-12 + i * 12, -176), Vector2(-12 + i * 12, -96)]), 2.0, Color("5a1a1a"))


static func _x_overalls(p: Puppet, col: Color) -> void:
	var luigi := p.style == "luigi"
	var sh := -178.0 if luigi else -126.0
	var hip := -92.0 if luigi else -62.0
	var tw := 28.0 if luigi else 34.0
	var bib := PackedVector2Array([Vector2(-tw * 0.55, sh + 24), Vector2(tw * 0.55, sh + 24), Vector2(tw, hip + 6), Vector2(-tw, hip + 6)])
	Art.shape(p.ci, bib, col, 3.0)
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([Vector2(sx * tw * 0.55, sh + 24), Vector2(sx * tw * 0.6, sh)]), 6.0, col)
		Art.dot(p.ci, Vector2(sx * tw * 0.45, sh + 30), 4, Color("f2c14e"))


static func _x_plumber(p: Puppet, hc: Vector2, col: Color, letter: String, zigzag: bool) -> void:
	# Big moustache under the nose
	if zigzag:
		Art.shape(p.ci, PackedVector2Array([hc + Vector2(-34, 12), hc + Vector2(-20, 22), hc + Vector2(-8, 14), hc + Vector2(0, 22),
			hc + Vector2(8, 14), hc + Vector2(20, 22), hc + Vector2(34, 12), hc + Vector2(20, 28), hc + Vector2(-20, 28)]), Color("3a2416"), 2.5)
	else:
		for sx in [-1, 1]:
			Art.blob(p.ci, hc + Vector2(sx * 14, 20), 17, 8, Color("3a2416"), 2.5, 0.0, sx * 0.2)
	# Cap with a round emblem
	Art.shape(p.ci, Art.arc_pts(hc + Vector2(0, -12), 42, 34, PI, TAU, 16), col, 3.5)
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(6, -18), Vector2(50, 10)), 5), col, 3.0)
	Art.blob(p.ci, hc + Vector2(0, -30), 13, 12, Color.WHITE, 2.5)
	# Counter-flip so the letter never reads backwards
	p.ci.draw_set_transform(-Puppet.BOUNDS.position * Puppet.BAKE_SCALE, 0.0, Vector2(Puppet.BAKE_SCALE * p.facing, Puppet.BAKE_SCALE))
	Art.text(p.ci, UiKit.TITLE_FONT, Vector2(-20, hc.y - 21), letter, 20, col, 0, HORIZONTAL_ALIGNMENT_CENTER, 40)
	p.ci.draw_set_transform(-Puppet.BOUNDS.position * Puppet.BAKE_SCALE, 0.0, Vector2.ONE * Puppet.BAKE_SCALE)


static func _x_brooch(p: Puppet, col: Color) -> void:
	Art.blob(p.ci, Vector2(0, -184), 7, 8, col, 2.5)


static func _x_crown(p: Puppet, hc: Vector2) -> void:
	var y := hc.y - 40
	var crown := PackedVector2Array([Vector2(-20, y + 14), Vector2(-20, y - 6), Vector2(-10, y + 4), Vector2(0, y - 10),
		Vector2(10, y + 4), Vector2(20, y - 6), Vector2(20, y + 14)])
	Art.shape(p.ci, crown, Color("f2c14e"), 3.0, 0.12)
	Art.dot(p.ci, Vector2(0, y + 6), 3.5, Color("e6452f"))


static func _x_medals(p: Puppet) -> void:
	for i in 3:
		Art.shape(p.ci, Art.rrect(Rect2(-26 + i * 9, -176, 7, 10), 1), [Color("e6452f"), Color("f2c14e"), Color("4a78d0")][i], 1.5)
	Art.stroke(p.ci, PackedVector2Array([Vector2(0, -194), Vector2(0, -110)]), 2.5)


static func _x_painter_beret(p: Puppet, hc: Vector2) -> void:
	Art.blob(p.ci, hc + Vector2(-4, -34), 40, 14, Color("e6452f"), 3.5, 0.0, -0.12)
	Art.dot(p.ci, hc + Vector2(-6, -48), 4, Color("e6452f"))


static func _x_big_bow(p: Puppet, hc: Vector2) -> void:
	var b := hc + Vector2(0, -44)
	Art.shape(p.ci, PackedVector2Array([b, b + Vector2(-26, -16), b + Vector2(-26, 16)]), Color("e6304a"), 3.0)
	Art.shape(p.ci, PackedVector2Array([b, b + Vector2(26, -16), b + Vector2(26, 16)]), Color("e6304a"), 3.0)
	Art.blob(p.ci, b, 7, 7, Color("e6304a"), 2.5)


static func _x_fairy_wings(p: Puppet, hc: Vector2) -> void:
	var flap := sin(p._t * 10.0) * 0.15
	for sx in [-1, 1]:
		var base := hc + Vector2(0, 56)
		var wing := PackedVector2Array([base, base + Vector2(sx * 60, -50).rotated(flap * sx), base + Vector2(sx * 74, 0).rotated(flap * sx),
			base + Vector2(sx * 40, 30)])
		Art.shape(p.ci, wing, Color(0.75, 0.9, 1.0, 0.85), 3.0)


# ------------------------------------------------------- Dragon Ball Z --

static func _frieza(p: Puppet) -> void:
	HumanRig.draw(p, {"size": "kid", "skin": Color("f4f2f6"), "top": Color("f4f2f6"), "sleeves": "none", "legs": Color("f4f2f6"),
		"shoe": Color("f4f2f6"), "hair": "none", "ears": false, "eye_iris": Color("c1272d"), "base_lid": 0.35, "torso_w": 26.0,
		"torso_extra": _x_frieza_plates, "extra": _x_frieza_dome, "back_extra": _x_frieza_tail})


static func _x_frieza_plates(p: Puppet) -> void:
	for sx in [-1, 1]:
		Art.blob(p.ci, Vector2(sx * 22, -116), 14, 10, Color("9b5fd0"), 3.0, 0.1)
	Art.blob(p.ci, Vector2(0, -96), 12, 10, Color("9b5fd0"), 3.0, 0.1)


static func _x_frieza_dome(p: Puppet, hc: Vector2) -> void:
	Art.shape(p.ci, Art.arc_pts(hc + Vector2(0, -8), 36, 38, PI * 1.08, PI * 1.92, 14) + PackedVector2Array([hc + Vector2(0, -20)]),
		Color("9b5fd0"), 3.5, 0.15)
	Art.dot(p.ci, hc + Vector2(-10, -34), 5, Color(1, 1, 1, 0.7))


static func _x_frieza_tail(p: Puppet, hc: Vector2) -> void:
	var tail := PackedVector2Array()
	for i in 12:
		var f := i / 11.0
		tail.append(hc + Vector2(-20 - f * 80, 150 - f * 40 + sin(f * 5.0 + p._t * 2.0) * 12.0))
	Art.limb(p.ci, tail, 16, Color("f4f2f6"))


# -------------------------------------------------- Attack on Titan --

static func _titan(p: Puppet) -> void:
	var ci := p.ci
	var skin := Color("e8b48a")
	var raise := p._arm_raise()
	p._arm(Vector2(-40, -246), -1, raise.x, 110, 22, skin, 16, skin)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.6
		Art.limb(ci, PackedVector2Array([Vector2(sx * 24, -140), Vector2(sx * 26 + sw, -12)]), 26, skin)
		Art.blob(ci, Vector2(sx * 26 + sw + 8, -8), 20, 9, skin, 3.0)
	var body := Art.smooth(PackedVector2Array([Vector2(-46, -262), Vector2(46, -262), Vector2(52, -190), Vector2(42, -130),
		Vector2(-42, -130), Vector2(-52, -190)]), 5)
	Art.shape(ci, body, skin, 4.0, 0.12)
	Art.stroke(ci, Art.curve(Vector2(-20, -220), Vector2(0, -210), Vector2(20, -220), 8), 2.5, skin.darkened(0.3))
	Art.shape(ci, Art.rrect(Rect2(-40, -142, 80, 22), 8), skin.darkened(0.08), 3.0)
	var hc := Vector2(0, -306)
	Art.blob(ci, hc, 48, 50, skin, 4.0, 0.1)
	for i in 3:
		Art.stroke(ci, Art.curve(hc + Vector2(-8 + i * 8, -48), hc + Vector2(-14 + i * 8, -64), hc + Vector2(-2 + i * 8, -70), 8), 3.0, Color("5a3a24"))
	# Blank staring eyes and a huge grin full of teeth
	for sx in [-1, 1]:
		Art.blob(ci, hc + Vector2(sx * 18, -12), 9, 7, Color("fbf6ea"), 3.0)
		Art.dot(ci, hc + Vector2(sx * 18, -12), 2.5, INK)
	var grin := Art.arc_pts(hc + Vector2(0, 6), 36, 26, 0.05, PI - 0.05, 16)
	Art.fill(ci, grin, Color.WHITE)
	Art.outline(ci, grin, 3.0)
	for i in 7:
		var x := -27.0 + i * 9.0
		Art.stroke(ci, PackedVector2Array([hc + Vector2(x, 8), hc + Vector2(x, 20 + absf(x) * -0.2 + 6)]), 2.0)
	if p._talk_open > 0.1:
		Art.stroke(ci, Art.curve(hc + Vector2(-30, 16), hc + Vector2(0, 26), hc + Vector2(30, 16), 8), 2.5)
	p._arm(Vector2(40, -246), 1, raise.y, 110, 22, skin, 16, skin)


# --------------------------------------------------- Super Mario Brothers --

static func _toad(p: Puppet) -> void:
	var ci := p.ci
	var skin := Puppet.SKIN
	var raise := p._arm_raise()
	p._human_legs(-40, -10, 9, 11, Color.WHITE, Color("8a5a36"))
	p._arm(Vector2(-18, -80), -1, raise.x, 30, 7, skin, 6, skin)
	Art.shape(ci, Art.rrect(Rect2(-22, -92, 44, 52), 10), Color("3d5aa8"), 3.5, 0.12)
	Art.shape(ci, Art.rrect(Rect2(-24, -52, 48, 16), 6), Color.WHITE, 3.0)
	var hc := Vector2(0, -122)
	Art.blob(ci, hc, 28, 26, skin, 3.5, 0.1)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 10, -2), 6, 10, 0, Color(0, 0, 0, 0), sx, 0.0, skin)
	p._mouth(hc + Vector2(0, 14), 16, 0)
	var cap := Art.smooth(PackedVector2Array([hc + Vector2(-64, -10), hc + Vector2(-50, -60), hc + Vector2(0, -80), hc + Vector2(50, -60),
		hc + Vector2(64, -10), hc + Vector2(0, -14)]), 6)
	Art.shape(ci, cap, Color("f4f4f2"), 4.0, 0.1)
	for d in [Vector2(-38, -40), Vector2(0, -60), Vector2(38, -40)]:
		Art.blob(ci, hc + d, 15, 13, Color("e6302a"), 2.5)
	p._arm(Vector2(18, -80), 1, raise.y, 30, 7, skin, 6, skin)


static func _bowser(p: Puppet) -> void:
	var ci := p.ci
	var hide := Color("f2b03e")
	var raise := p._arm_raise()
	# Spiked shell behind
	var sc := Vector2(-30, -170)
	Art.blob(ci, sc, 78, 92, Color("3f8f3a"), 4.0, 0.15)
	for k in 4:
		var s := sc + Vector2(-60, -60 + k * 40)
		Art.shape(ci, PackedVector2Array([s + Vector2(8, -12), s + Vector2(-22, 0), s + Vector2(8, 12)]), Color("f4f4f2"), 3.0)
	Art.stroke(ci, Art.ellipse(sc, 82, 96, 40), 5.0, Color("f4f2e6"))
	p._arm(Vector2(-44, -220), -1, raise.x, 60, 16, hide, 13, hide)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.limb(ci, PackedVector2Array([Vector2(sx * 28, -80), Vector2(sx * 30 + sw, -10)]), 30, hide)
		for t in 3:
			Art.dot(ci, Vector2(sx * 30 + sw + 6 + t * 7, -6), 4, Color.WHITE)
	var belly := Art.smooth(PackedVector2Array([Vector2(-50, -250), Vector2(46, -250), Vector2(56, -150), Vector2(40, -70), Vector2(-40, -70),
		Vector2(-56, -150)]), 6)
	Art.shape(ci, belly, hide, 4.0, 0.12)
	for k in 4:
		Art.stroke(ci, PackedVector2Array([Vector2(-34, -220 + k * 36), Vector2(34, -220 + k * 36)]), 2.5, hide.darkened(0.25))
	var hc := Vector2(20, -292)
	# Red hair and horns
	Art.blob(ci, hc + Vector2(-20, -30), 34, 22, Color("e6452f"), 3.5)
	for sx in [-1, 1]:
		Art.shape(ci, PackedVector2Array([hc + Vector2(sx * 22 - 6, -30), hc + Vector2(sx * 40, -66), hc + Vector2(sx * 22 + 8, -26)]), Color("f4f2e6"), 3.0)
	Art.blob(ci, hc, 46, 40, Color("3f8f3a"), 4.0, 0.12)
	Art.blob(ci, hc + Vector2(30, 14), 30, 22, hide, 3.5)
	for sx in [-1, 1]:
		Art.dot(ci, hc + Vector2(44, 6 + sx * 6), 3, INK)
	p._brows(hc.y - 22, 14, 13, 6.0, Color("e6452f"))
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 14 + 2, -6), 8, 10, 3.5, Color("e6452f"), sx, 0.25, Color("3f8f3a"))
	p._mouth(hc + Vector2(22, 24), 30, 2)
	p._arm(Vector2(44, -220), 1, raise.y, 60, 16, hide, 13, hide)


static func _yoshi(p: Puppet) -> void:
	var ci := p.ci
	var green := Color("5ac85a")
	var raise := p._arm_raise()
	Art.limb(ci, Art.curve(Vector2(-26, -70), Vector2(-60, -60), Vector2(-74, -36), 8), 22, green)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.6
		Art.limb(ci, PackedVector2Array([Vector2(sx * 14, -60), Vector2(sx * 16 + sw, -14)]), 16, green)
		Art.blob(ci, Vector2(sx * 16 + sw + 8, -10), 18, 10, Color("e6702f"), 3.0)
	p._arm(Vector2(-18, -128), -1, raise.x, 30, 9, green, 7, green)
	Art.blob(ci, Vector2(0, -96), 30, 44, green, 4.0, 0.12)
	Art.blob(ci, Vector2(6, -90), 18, 32, Color("f6f2e6"), 3.0)
	# Red saddle
	Art.blob(ci, Vector2(-22, -108), 18, 14, Color("e6302a"), 3.0)
	var hc := Vector2(10, -170)
	for k in 3:
		Art.shape(ci, PackedVector2Array([hc + Vector2(-34, -20 + k * 18), hc + Vector2(-50, -12 + k * 18), hc + Vector2(-34, -4 + k * 18)]),
			Color("e6302a"), 2.5)
	Art.blob(ci, hc, 30, 34, green, 4.0, 0.12)
	Art.blob(ci, hc + Vector2(34, 10), 34, 24, green, 4.0, 0.1)
	for sx in [-1, 1]:
		Art.dot(ci, hc + Vector2(58, 2 + sx * 8), 3, INK)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 10 + 6, -26), 10, 14, 0, Color(0, 0, 0, 0), sx, 0.0, green)
	p._mouth(hc + Vector2(40, 28), 28, 0)
	p._arm(Vector2(18, -128), 1, raise.y, 30, 9, green, 7, green)


static func _kong(p: Puppet) -> void:
	var ci := p.ci
	var fur := Color("8a4a24")
	var tan := Color("e8b48a")
	var raise := p._arm_raise()
	p._arm(Vector2(-50, -200), -1, raise.x, 100, 24, fur, 18, tan)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.limb(ci, PackedVector2Array([Vector2(sx * 26, -90), Vector2(sx * 30 + sw, -12)]), 24, fur)
		Art.blob(ci, Vector2(sx * 30 + sw + 6, -8), 18, 9, tan, 3.0)
	Art.blob(ci, Vector2(0, -150), 58, 72, fur, 4.0, 0.12)
	Art.blob(ci, Vector2(4, -140), 34, 46, tan, 3.0)
	# Red tie
	Art.shape(ci, PackedVector2Array([Vector2(-14, -214), Vector2(14, -214), Vector2(10, -150), Vector2(0, -138), Vector2(-10, -150)]), Color("e6302a"), 3.0)
	p.ci.draw_set_transform(-Puppet.BOUNDS.position * Puppet.BAKE_SCALE, 0.0, Vector2(Puppet.BAKE_SCALE * p.facing, Puppet.BAKE_SCALE))
	Art.text(p.ci, UiKit.TITLE_FONT, Vector2(-20, -172), "DK", 16, Color("f2c14e"), 3, HORIZONTAL_ALIGNMENT_CENTER, 40)
	p.ci.draw_set_transform(-Puppet.BOUNDS.position * Puppet.BAKE_SCALE, 0.0, Vector2.ONE * Puppet.BAKE_SCALE)
	var hc := Vector2(0, -256)
	Art.blob(ci, hc + Vector2(0, -16), 20, 16, fur, 3.0)
	Art.blob(ci, hc, 44, 40, fur, 4.0, 0.12)
	Art.blob(ci, hc + Vector2(4, 12), 34, 24, tan, 3.0)
	Art.blob(ci, hc + Vector2(0, -12), 30, 16, tan, 2.5)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 12, -12), 8, 9, 0, Color(0, 0, 0, 0), sx, 0.0, tan)
		Art.dot(ci, hc + Vector2(sx * 6, 6), 3, INK)
	p._brows(hc.y - 26, 12, 10, 5.0)
	p._mouth(hc + Vector2(4, 22), 34, 1)
	p._arm(Vector2(50, -200), 1, raise.y, 100, 24, fur, 18, tan)


static func _goomba(p: Puppet) -> void:
	var ci := p.ci
	var brown := Color("a0602a")
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.4
		Art.blob(ci, Vector2(sx * 22 + sw, -12), 22, 13, Color("3a2416"), 3.0)
	Art.shape(ci, Art.rrect(Rect2(-24, -56, 48, 40), 12), Color("f2d9a8"), 3.5)
	var cap := Art.smooth(PackedVector2Array([Vector2(-62, -50), Vector2(-44, -120), Vector2(0, -136), Vector2(44, -120), Vector2(62, -50),
		Vector2(0, -42)]), 6)
	Art.shape(ci, cap, brown, 4.0, 0.12)
	for sx in [-1, 1]:
		p._eye(Vector2(sx * 16, -84), 10, 14, 0, Color(0, 0, 0, 0), sx, 0.0, brown)
	p._brows(-104, 16, 14, 7.0)
	p._mouth(Vector2(0, -58), 34, 1)


static func _troopa(p: Puppet) -> void:
	var ci := p.ci
	var skin := Color("f6d63c")
	var raise := p._arm_raise()
	Art.blob(ci, Vector2(-16, -106), 40, 52, Color("3fae4a"), 4.0, 0.15)
	Art.stroke(ci, Art.ellipse(Vector2(-16, -106), 40, 52, 30), 5.0, Color("f4f2e6"))
	p._arm(Vector2(-14, -128), -1, raise.x, 30, 9, skin, 7, skin)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.limb(ci, PackedVector2Array([Vector2(sx * 12, -56), Vector2(sx * 14 + sw, -14)]), 14, skin)
		Art.blob(ci, Vector2(sx * 14 + sw + 6, -10), 15, 9, Color("e6452f"), 3.0)
	Art.blob(ci, Vector2(6, -100), 26, 44, Color("f6f2e6"), 3.5, 0.1)
	var hc := Vector2(6, -170)
	Art.blob(ci, hc, 28, 30, skin, 4.0, 0.1)
	Art.blob(ci, hc + Vector2(22, 8), 18, 16, skin, 3.0)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 9 + 2, -10), 8, 12, 0, Color(0, 0, 0, 0), sx, 0.0, skin)
	p._mouth(hc + Vector2(18, 16), 20, 0)
	p._arm(Vector2(22, -128), 1, raise.y, 30, 9, skin, 7, skin)


# ----------------------------------------------------------- Metroid --

static func _power_suit(p: Puppet, main: Color, accent: Color, visor: Color) -> void:
	var ci := p.ci
	var raise := p._arm_raise()
	var dark := main.darkened(0.35)
	# Back arm, legs and boots
	p._arm(Vector2(-34, -196), -1, raise.x, 70, 12, accent, 10, dark)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx)
		var knee := Vector2(sx * 15 + sw * 0.5, -56)
		Art.limb(ci, PackedVector2Array([Vector2(sx * 15, -112), knee]), 22, accent)
		Art.limb(ci, PackedVector2Array([knee, Vector2(sx * 16 + sw, -12)]), 22, main)
		Art.blob(ci, knee, 14, 12, main, 3.0)
		Art.shape(ci, Art.rrect(Rect2(sx * 16 + sw - 16, -22, 36, 20), 6), main, 3.0)
	# Torso, belt and the big round shoulder pads
	Art.shape(ci, Art.rrect(Rect2(-30, -200, 60, 96), 14), main, 4.0, 0.14)
	Art.shape(ci, Art.rrect(Rect2(-28, -118, 56, 14), 4), dark, 3.0)
	Art.shape(ci, PackedVector2Array([Vector2(-16, -196), Vector2(16, -196), Vector2(10, -150), Vector2(-10, -150)]), accent, 2.5)
	for sx in [-1, 1]:
		Art.blob(ci, Vector2(sx * 38, -194), 28, 24, main, 4.0, 0.14)
		Art.stroke(ci, Art.arc_pts(Vector2(sx * 38, -194), 18, 14, PI * 1.1, PI * 1.9, 8), 3.0, accent)
	# Helmet with visor
	var hc := Vector2(0, -246)
	Art.blob(ci, hc, 30, 34, main, 4.0, 0.12)
	Art.shape(ci, Art.rrect(Rect2(hc + Vector2(-20, -10), Vector2(40, 20)), 8), visor, 3.0)
	var glint := 0.3 + p._talk_open * 0.6
	Art.stroke(ci, PackedVector2Array([hc + Vector2(-12, -4), hc + Vector2(-2, -4)]), 3.0, Color(1, 1, 1, glint))
	Art.shape(ci, Art.rrect(Rect2(hc + Vector2(-6, -36), Vector2(12, 14)), 3), Color("e64a3a"), 2.5)
	# Arm cannon on the front arm (unless holding something)
	if p.held == "":
		var a := 0.22 + raise.y
		var dir := Vector2(sin(a), cos(a))
		var sh := Vector2(34, -188)
		var elbow := sh + dir * 34
		Art.limb(ci, PackedVector2Array([sh, elbow]), 12, accent)
		Art.limb(ci, PackedVector2Array([elbow, elbow + dir * 46]), 26, main)
		Art.blob(ci, elbow + dir * 48, 10, 10, dark, 3.0)
	else:
		p._arm(Vector2(34, -196), 1, raise.y, 70, 12, accent, 10, dark)


static func _ridley(p: Puppet) -> void:
	var ci := p.ci
	var purple := Color("6a3f9a")
	var raise := p._arm_raise()
	var flap := sin(p._t * 3.0) * 0.12
	# Wings
	for sx in [-1, 1]:
		var base := Vector2(sx * 20, -230)
		var wing := PackedVector2Array([base, base + Vector2(sx * 150, -110).rotated(flap * sx), base + Vector2(sx * 160, 10).rotated(flap * sx),
			base + Vector2(sx * 110, -20), base + Vector2(sx * 80, 40), base + Vector2(sx * 40, 20)])
		Art.shape(ci, wing, Color("8a4a8a"), 4.0, 0.1)
	# Spiky tail
	var tail := PackedVector2Array()
	for i in 12:
		var f := i / 11.0
		tail.append(Vector2(-30 - f * 130, -80 + f * 40 + sin(f * 6.0 + p._t * 2.0) * 14.0))
	Art.limb(ci, tail, 14, purple)
	Art.shape(ci, PackedVector2Array([tail[11] + Vector2(0, -16), tail[11] + Vector2(-28, 0), tail[11] + Vector2(0, 16)]), Color("e6452f"), 3.0)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.6
		Art.limb(ci, PackedVector2Array([Vector2(sx * 20, -110), Vector2(sx * 30 + sw, -60), Vector2(sx * 22 + sw, -10)]), 16, purple)
	p._arm(Vector2(-22, -200), -1, raise.x, 50, 9, purple, 8, Color("e6452f"))
	Art.blob(ci, Vector2(0, -160), 34, 66, purple, 4.0, 0.12)
	for k in 4:
		Art.stroke(ci, PackedVector2Array([Vector2(-18, -190 + k * 22), Vector2(18, -190 + k * 22)]), 2.5, Color("f2c14e"))
	# Long neck and beaked head
	Art.limb(ci, PackedVector2Array([Vector2(0, -210), Vector2(16, -280)]), 22, purple)
	var hc := Vector2(30, -300)
	Art.shape(ci, PackedVector2Array([hc + Vector2(-20, -16), hc + Vector2(-70, -40), hc + Vector2(-24, 2)]), purple, 3.5)
	Art.shape(ci, Art.smooth(PackedVector2Array([hc + Vector2(-26, -20), hc + Vector2(20, -24), hc + Vector2(70, 0), hc + Vector2(20, 18),
		hc + Vector2(-24, 16)]), 4), purple, 4.0, 0.12)
	p._eye(hc + Vector2(6, -6), 7, 6, 3.0, Color("f2c14e"), 1, 0.3, purple, Color("f2c14e"))
	p._mouth(hc + Vector2(36, 10), 30, 2)
	p._arm(Vector2(22, -200), 1, raise.y, 50, 9, purple, 8, Color("e6452f"))


static func _kraid(p: Puppet) -> void:
	var ci := p.ci
	var green := Color("4f9a3a")
	var raise := p._arm_raise()
	p._arm(Vector2(-70, -230), -1, raise.x, 70, 22, green, 16, green)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.4
		Art.limb(ci, PackedVector2Array([Vector2(sx * 40, -80), Vector2(sx * 44 + sw, -10)]), 40, green)
		for t in 3:
			Art.shape(ci, PackedVector2Array([Vector2(sx * 44 + sw - 18 + t * 14, -6), Vector2(sx * 44 + sw - 12 + t * 14, 6),
				Vector2(sx * 44 + sw - 6 + t * 14, -6)]), Color.WHITE, 2.0)
	var body := Art.smooth(PackedVector2Array([Vector2(-80, -300), Vector2(80, -300), Vector2(96, -160), Vector2(70, -60),
		Vector2(-70, -60), Vector2(-96, -160)]), 6)
	Art.shape(ci, body, green, 4.5, 0.12)
	Art.blob(ci, Vector2(10, -160), 50, 80, Color("e8d39a"), 3.0)
	# Belly spikes
	for k in 3:
		var s := Vector2(60, -220 + k * 50)
		Art.shape(ci, PackedVector2Array([s + Vector2(0, -10), s + Vector2(34, 0), s + Vector2(0, 10)]), Color("f4f2e6"), 3.0)
	var hc := Vector2(10, -310)
	for sx in [-1, 1]:
		Art.shape(ci, PackedVector2Array([hc + Vector2(sx * 20, -20), hc + Vector2(sx * 54, -54), hc + Vector2(sx * 34, -6)]), Color("f4f2e6"), 3.0)
	Art.blob(ci, hc, 52, 40, green, 4.0, 0.12)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 20, -10), 9, 8, 3.5, Color("e6452f"), sx, 0.3, green, Color("f2c14e"))
	p._mouth(hc + Vector2(6, 18), 44, 2)
	p._arm(Vector2(70, -230), 1, raise.y, 70, 22, green, 16, green)


static func _mother_brain(p: Puppet) -> void:
	var ci := p.ci
	# Metal base and glass jar
	Art.shape(ci, Art.rrect(Rect2(-80, -60, 160, 60), 8), Color("6b6f78"), 4.0, 0.15)
	for k in 3:
		Art.dot(ci, Vector2(-40 + k * 40, -30), 6, Color("e6452f") if fmod(p._t + k * 0.5, 1.5) < 0.75 else Color("3a3d42"))
	var jar := Art.rrect(Rect2(-74, -280, 148, 222), 40)
	Art.fill(ci, jar, Color(0.6, 0.9, 1.0, 0.25))
	# The brain, pulsing gently
	var pulse := 1.0 + sin(p._t * 2.0) * 0.03
	var bc := Vector2(0, -170)
	Art.blob(ci, bc, 60 * pulse, 70 * pulse, Color("e88aa0"), 4.0, 0.15)
	for k in 4:
		Art.stroke(ci, Art.curve(bc + Vector2(-44, -40 + k * 24), bc + Vector2(0, -52 + k * 24), bc + Vector2(44, -40 + k * 24), 10), 3.0,
			Color("b85a70"))
	p._eye(bc + Vector2(0, 6), 18, 14, 9.0, Color("e6302a"), 1, 0.2, Color("e88aa0"), Color("fbf6ea"))
	p._mouth(bc + Vector2(0, 44), 24, 0)
	Art.outline(ci, jar, 4.0)
	Art.stroke(ci, PackedVector2Array([Vector2(-50, -250), Vector2(-50, -120)]), 6.0, Color(1, 1, 1, 0.35))


static func _metroid(p: Puppet) -> void:
	var ci := p.ci
	var bob := sin(p._t * 2.5) * 8.0
	var c := Vector2(0, -150 + bob)
	# Fangs below
	for sx in [-1, 1]:
		for k in 2:
			var base := c + Vector2(sx * (16 + k * 22), 30)
			Art.shape(ci, PackedVector2Array([base + Vector2(-8, 0), base + Vector2(sx * 4, 40 + sin(p._t * 6.0 + k) * 4.0), base + Vector2(8, 0)]),
				Color("f2e6c8"), 3.0)
	var dome := Art.arc_pts(c, 70, 64, PI, TAU, 24) + PackedVector2Array([c + Vector2(70, 34), c + Vector2(-70, 34)])
	Art.shape(ci, dome, Color(0.6, 0.95, 0.5, 0.8), 4.0, 0.1)
	for d in [Vector2(-26, -10), Vector2(24, -20), Vector2(0, 14)]:
		Art.blob(ci, c + d, 16, 14, Color("e6302a"), 3.0)
	for sx in [-1, 1]:
		p._eye(c + Vector2(sx * 22, -38), 7, 8, 0, Color(0, 0, 0, 0), sx, 0.0, Color(0.6, 0.95, 0.5))
	p._mouth(c + Vector2(0, 24), 18, 0)


static func _chozo(p: Puppet) -> void:
	var ci := p.ci
	var robe := Color("c8a06a")
	var feather := Color("8a5a36")
	var raise := p._arm_raise()
	p._arm(Vector2(-30, -196), -1, raise.x, 70, 9, feather, 8, Color("e8c860"))
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.limb(ci, PackedVector2Array([Vector2(sx * 14, -80), Vector2(sx * 16 + sw, -10)]), 10, Color("e8c860"))
		for t in 3:
			Art.stroke(ci, PackedVector2Array([Vector2(sx * 16 + sw, -10), Vector2(sx * 16 + sw - 10 + t * 10, 0)]), 3.0)
	Art.shape(ci, PackedVector2Array([Vector2(-30, -210), Vector2(30, -210), Vector2(46, -70), Vector2(-46, -70)]), robe, 4.0, 0.12)
	Art.shape(ci, PackedVector2Array([Vector2(-30, -210), Vector2(30, -210), Vector2(0, -160)]), Color("e6702f"), 3.0)
	var hc := Vector2(0, -250)
	for k in 5:
		Art.shape(ci, PackedVector2Array([hc + Vector2(-20, -20 + k * 8), hc + Vector2(-60, -30 + k * 14), hc + Vector2(-18, -6 + k * 8)]),
			[Color("e6452f"), Color("f2c14e"), Color("4a78d0")][k % 3], 2.5)
	Art.blob(ci, hc, 34, 34, feather, 4.0, 0.12)
	Art.shape(ci, PackedVector2Array([hc + Vector2(22, -6), hc + Vector2(64, 10), hc + Vector2(22, 18)]), Color("f2c14e"), 3.0)
	p._eye(hc + Vector2(8, -6), 8, 10, 3.5, Color("3fae9a"), 1, 0.3, feather)
	p._mouth(hc + Vector2(34, 12), 14, 0)
	p._arm(Vector2(30, -196), 1, raise.y, 70, 9, feather, 8, Color("e8c860"))


static func _space_pirate(p: Puppet) -> void:
	var ci := p.ci
	var shell := Color("7a4a9a")
	var raise := p._arm_raise()
	p._claw(Vector2(-34, -196), -1, raise.x, shell)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx)
		Art.limb(ci, PackedVector2Array([Vector2(sx * 14, -110), Vector2(sx * 26 + sw * 0.5, -60), Vector2(sx * 16 + sw, -10)]), 16, shell)
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(-34, -220), Vector2(34, -220), Vector2(30, -110), Vector2(-30, -110)]), 4), shell, 4.0, 0.14)
	for k in 3:
		Art.stroke(ci, PackedVector2Array([Vector2(-26, -196 + k * 28), Vector2(26, -196 + k * 28)]), 3.0, shell.darkened(0.3))
	var hc := Vector2(6, -262)
	Art.shape(ci, Art.smooth(PackedVector2Array([hc + Vector2(-34, -10), hc + Vector2(-10, -50), hc + Vector2(30, -36), hc + Vector2(40, 10),
		hc + Vector2(10, 34), hc + Vector2(-26, 24)]), 5), shell, 4.0, 0.12)
	Art.shape(ci, Art.rrect(Rect2(hc + Vector2(-6, -18), Vector2(42, 16)), 6), Color("6fdc6a"), 3.0)
	p._mouth(hc + Vector2(16, 16), 22, 2)
	p._claw(Vector2(34, -196), 1, raise.y, shell)


static func _etecoon(p: Puppet) -> void:
	var ci := p.ci
	var green := Color("8fd06a")
	var raise := p._arm_raise()
	Art.limb(ci, Art.curve(Vector2(-14, -30), Vector2(-50, -40), Vector2(-46, -80), 8), 6, green)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.limb(ci, PackedVector2Array([Vector2(sx * 8, -26), Vector2(sx * 10 + sw, -6)]), 8, green)
	p._arm(Vector2(-14, -50), -1, raise.x, 22, 5, green, 5, green)
	Art.blob(ci, Vector2(0, -38), 18, 22, green, 3.5, 0.1)
	var hc := Vector2(0, -80)
	for sx in [-1, 1]:
		Art.blob(ci, hc + Vector2(sx * 28, -10), 12, 10, green, 3.0)
	Art.blob(ci, hc, 28, 24, green, 3.5, 0.1)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 11, -4), 9, 10, 0, Color(0, 0, 0, 0), sx, 0.0, green)
	p._mouth(hc + Vector2(0, 12), 12, 0)
	p._arm(Vector2(14, -50), 1, raise.y, 22, 5, green, 5, green)


static func _dachora(p: Puppet) -> void:
	var ci := p.ci
	var body_col := Color("e8d070")
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx)
		Art.limb(ci, PackedVector2Array([Vector2(sx * 12, -110), Vector2(sx * 20 + sw * 0.5, -60), Vector2(sx * 12 + sw, -8)]), 9, Color("c8a06a"))
		Art.stroke(ci, PackedVector2Array([Vector2(sx * 12 + sw - 10, -4), Vector2(sx * 12 + sw + 12, -4)]), 4.0)
	Art.blob(ci, Vector2(-10, -140), 52, 40, body_col, 4.0, 0.12)
	for k in 3:
		Art.shape(ci, PackedVector2Array([Vector2(-56, -150 + k * 12), Vector2(-90, -170 + k * 18), Vector2(-56, -136 + k * 12)]),
			Color("6fbf6a"), 2.5)
	Art.limb(ci, Art.curve(Vector2(26, -160), Vector2(40, -220), Vector2(30, -270), 8), 14, body_col)
	var hc := Vector2(34, -284)
	Art.blob(ci, hc, 22, 18, body_col, 3.5)
	Art.shape(ci, PackedVector2Array([hc + Vector2(14, -6), hc + Vector2(48, 4), hc + Vector2(14, 10)]), Color("e6702f"), 3.0)
	p._eye(hc + Vector2(2, -4), 7, 8, 0, Color(0, 0, 0, 0), 1, 0.0, body_col)
	for k in 3:
		Art.stroke(ci, Art.curve(hc + Vector2(-6 + k * 6, -16), hc + Vector2(-12 + k * 6, -32), hc + Vector2(-4 + k * 6, -40), 6), 3.0,
			Color("6fbf6a"))


# --------------------------------------------------------------- Kirby --

## A round Dream Land resident: a ball with stubby arms and big feet.
## `kind` picks the face and extras.
static func _ball(p: Puppet, body: Color, feet: Color, kind: String) -> void:
	var ci := p.ci
	var raise := p._arm_raise()
	var r := 56.0 if kind != "meta" else 50.0
	var c := Vector2(0, -r - 14)
	var squish := 1.0 + p._talk_open * 0.03
	if kind == "meta":
		# Cape behind
		var cape := PackedVector2Array([c + Vector2(-50, -30), c + Vector2(50, -30), c + Vector2(70, 60), c + Vector2(-70, 60)])
		Art.shape(ci, Art.smooth(cape, 3), feet, 4.0, 0.12)
	if kind == "marx":
		for sx in [-1, 1]:
			Art.shape(ci, PackedVector2Array([c + Vector2(sx * 20, -r + 10), c + Vector2(sx * 74, -r - 30), c + Vector2(sx * 40, -r + 20)]),
				Color("e6304a") if sx < 0 else Color("4a78d0"), 3.5)
			Art.blob(ci, c + Vector2(sx * 74, -r - 30), 9, 9, Color("f2c14e"), 2.5)
	# Back nub arm, feet, body
	var ab := c + Vector2(-r * 0.9, 8 - raise.x * 22)
	Art.blob(ci, ab, 16, 13, body, 3.5)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.blob(ci, Vector2(sx * 24 + sw, -12), 26, 14, feet, 3.5, 0.1)
	Art.shape(ci, Art.ellipse(c, r * squish, r / squish, 40), body, 4.0, 0.12)
	match kind:
		"kirby":
			for sx in [-1, 1]:
				p._eye(c + Vector2(sx * 12, -12), 6, 15, 0, Color(0, 0, 0, 0), sx, 0.0, body, Color("1b2a6a"))
				Art.blob(ci, c + Vector2(sx * 30, 6), 9, 5, Color("f2608a"), 0.0)
			p._mouth(c + Vector2(0, 14), 16, 0)
		"dee", "bandana":
			var face := Art.ellipse(c + Vector2(4, 4), r * 0.68, r * 0.58, 30)
			Art.shape(ci, face, Color("f6dcae"), 0.0)
			for sx in [-1, 1]:
				p._eye(c + Vector2(sx * 13 + 4, -4), 6, 12, 0, Color(0, 0, 0, 0), sx, 0.0, Color("f6dcae"), Color("1d1d22"))
				Art.blob(ci, c + Vector2(sx * 28 + 4, 14), 7, 4, Color("f2a090"), 0.0)
			if p._talk_open > 0.1:
				Art.blob(ci, c + Vector2(4, 20), 5, 4 * p._talk_open + 1, Color(0.36, 0.04, 0.1), 2.0)
			if kind == "bandana":
				Art.shape(ci, Art.arc_pts(c + Vector2(0, -12), r * 1.02, r * 0.95, PI * 1.05, PI * 1.95, 14) +
					PackedVector2Array([c + Vector2(r * 0.6, -r * 0.5), c + Vector2(-r * 0.6, -r * 0.5)]), Color("4a78d0"), 3.5)
				Art.shape(ci, PackedVector2Array([c + Vector2(-r * 0.8, -r * 0.45), c + Vector2(-r * 1.25, -r * 0.2), c + Vector2(-r * 1.05, -r * 0.6)]),
					Color("4a78d0"), 3.0)
		"doo":
			p._eye(c + Vector2(4, -6), 20, 22, 9.0, Color("f4f4f2"), 1, 0.0, body)
			if p._talk_open > 0.1:
				Art.blob(ci, c + Vector2(4, 30), 8, 5 * p._talk_open + 1, Color(0.36, 0.04, 0.1), 2.0)
		"meta":
			# Silver mask with a T-slit and glowing yellow eyes
			var mask := Art.ellipse(c + Vector2(6, 0), r * 0.82, r * 0.86, 30)
			Art.shape(ci, mask, Color("c8ccd6"), 3.5, 0.15)
			Art.shape(ci, PackedVector2Array([c + Vector2(-26, -14), c + Vector2(40, -14), c + Vector2(40, 0), c + Vector2(12, 0), c + Vector2(12, 34),
				c + Vector2(0, 34), c + Vector2(0, 0), c + Vector2(-26, 0)]), Color("1d1d22"), 2.5)
			for sx in [-1, 1]:
				var glow := Color("ffe36a") if p._blink < 0.5 else Color("1d1d22")
				Art.blob(ci, c + Vector2(sx * 16 + 6, -7), 7, 5, glow, 0.0)
			# Shoulder pads
			for sx in [-1, 1]:
				Art.blob(ci, c + Vector2(sx * r * 0.75, r * 0.2), 16, 12, Color("4a78d0"), 3.0)
		"marx":
			for sx in [-1, 1]:
				p._eye(c + Vector2(sx * 14, -14), 7, 11, 3.5, Color("3fae9a"), sx, 0.0, body)
			p._mouth(c + Vector2(0, 12), 44, 2)
	# Front nub arm (holds props)
	if p.held != "":
		p._arm(c + Vector2(r * 0.7, 6), 1, raise.y, 24, 12, body, 12, body)
	else:
		Art.blob(ci, c + Vector2(r * 0.9, 8 - raise.y * 22), 16, 13, body, 3.5)


static func _dedede(p: Puppet) -> void:
	var ci := p.ci
	var blue := Color("4a7fd8")
	var raise := p._arm_raise()
	# Royal robe behind
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(-70, -210), Vector2(70, -210), Vector2(84, -30), Vector2(-84, -30)]), 3),
		Color("e6302a"), 4.0, 0.12)
	Art.stroke(ci, PackedVector2Array([Vector2(-84, -34), Vector2(84, -34)]), 8.0, Color("f4f2e6"))
	p._arm(Vector2(-52, -170), -1, raise.x, 46, 16, blue, 14, Color("f4f4f2"))
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.blob(ci, Vector2(sx * 30 + sw, -12), 32, 15, Color("f2a65a"), 3.5)
	Art.blob(ci, Vector2(0, -120), 70, 94, blue, 4.5, 0.12)
	Art.blob(ci, Vector2(6, -108), 46, 62, Color("f4f2e6"), 3.0)
	Art.shape(ci, Art.rrect(Rect2(-62, -96, 124, 18), 6), Color("f2c14e"), 3.0)
	var hc := Vector2(0, -234)
	Art.blob(ci, hc, 48, 40, blue, 4.0, 0.12)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 16, -10), 9, 12, 0, Color(0, 0, 0, 0), sx, 0.2, blue)
	Art.blob(ci, hc + Vector2(6, 20), 30, 12, Color("f2c14e"), 3.0)
	if p._talk_open > 0.1:
		Art.blob(ci, hc + Vector2(6, 30), 18, 8 * p._talk_open + 2, Color(0.36, 0.04, 0.1), 2.5)
	# Crown hat
	Art.shape(ci, Art.rrect(Rect2(hc + Vector2(-42, -56), Vector2(84, 30)), 10), Color("e6302a"), 3.5)
	Art.shape(ci, Art.rrect(Rect2(hc + Vector2(-46, -32), Vector2(92, 12)), 5), Color("f4f2e6"), 3.0)
	Art.shape(ci, Art.star(hc + Vector2(0, -42), 10), Color("f2c14e"), 2.5)
	p._arm(Vector2(52, -170), 1, raise.y, 46, 16, blue, 14, Color("f4f4f2"))


static func _magolor(p: Puppet) -> void:
	var ci := p.ci
	var bob := sin(p._t * 2.0) * 6.0
	var c := Vector2(0, -110 + bob)
	var blue := Color("3f6fd8")
	var raise := p._arm_raise()
	# Floating glove hands
	Art.blob(ci, c + Vector2(-72, 20 - raise.x * 30), 14, 13, Color.WHITE, 3.0)
	# Long hood ears
	for sx in [-1, 1]:
		Art.shape(ci, PackedVector2Array([c + Vector2(sx * 26, -40), c + Vector2(sx * 60, -110), c + Vector2(sx * 44, -26)]), blue, 3.5)
	Art.shape(ci, Art.smooth(PackedVector2Array([c + Vector2(0, -60), c + Vector2(52, -30), c + Vector2(56, 40), c + Vector2(0, 60),
		c + Vector2(-56, 40), c + Vector2(-52, -30)]), 6), blue, 4.0, 0.12)
	Art.shape(ci, Art.rrect(Rect2(c + Vector2(-50, 20), Vector2(100, 14)), 6), Color("f2c14e"), 3.0)
	# Dark face opening with yellow eyes
	Art.blob(ci, c + Vector2(4, -14), 34, 26, Color("1d1d30"), 3.0)
	for sx in [-1, 1]:
		p._eye(c + Vector2(sx * 12 + 4, -16), 7, 9, 0, Color(0, 0, 0, 0), sx, 0.0, Color("1d1d30"), Color("ffe36a"))
	if p.held != "":
		p._arm(c + Vector2(50, 10), 1, raise.y, 24, 6, Color(0, 0, 0, 0), 13, Color.WHITE)
	else:
		Art.blob(ci, c + Vector2(72, 20 - raise.y * 30), 14, 13, Color.WHITE, 3.0)


static func _whispy(p: Puppet) -> void:
	var ci := p.ci
	var bark := Color("a0703a")
	# Leafy canopy
	for d in [Vector2(-80, -300), Vector2(0, -330), Vector2(80, -300), Vector2(-50, -260), Vector2(50, -260)]:
		Art.blob(ci, d, 70, 46, Color("5aa84a"), 4.0, 0.12)
	for d in [Vector2(-60, -280), Vector2(40, -312), Vector2(90, -270)]:
		Art.blob(ci, d, 10, 10, Color("e6302a"), 2.5)
	# Trunk with roots
	Art.shape(ci, PackedVector2Array([Vector2(-70, -240), Vector2(70, -240), Vector2(84, -10), Vector2(-84, -10)]), bark, 4.5, 0.12)
	for sx in [-1, 1]:
		Art.shape(ci, PackedVector2Array([Vector2(sx * 70, -40), Vector2(sx * 120, -6), Vector2(sx * 60, -6)]), bark, 3.5)
	var fc := Vector2(0, -150)
	for sx in [-1, 1]:
		p._eye(fc + Vector2(sx * 24, -30), 9, 14, 0, Color(0, 0, 0, 0), sx, 0.1, bark, Color("2b1a0e"))
	Art.blob(ci, fc + Vector2(6, 4), 12, 16, bark.lightened(0.1), 3.0)
	p._mouth(fc + Vector2(0, 46), 40, 0)
