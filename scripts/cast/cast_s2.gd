class_name CastS2
extends RefCounted
## Season 2 characters. People are HumanRig settings; everyone else has a
## small drawing function. CastMore.draw() falls through to draw().

const INK := Art.INK
## Shoulder heights by HumanRig size, for costume details on the body.
const SHOULDER := {"baby": -80.0, "kid": -126.0, "teen": -178.0, "adult": -196.0}


static func draw(p: Puppet, style: String) -> bool:
	var h := _human(style)
	if not h.is_empty():
		HumanRig.draw(p, h)
		return true
	match style:
		# SpongeBob SquarePants
		"squilliam": _squid(p, Color("c8b8f0"), Color("2b2f4a"), true)
		# Pokémon
		"psyduck": _psyduck(p)
		"togepi": _togepi(p)
		"jigglypuff": _jigglypuff(p)
		# Super Mario Brothers
		"toadette": _toadette(p)
		"bowser_jr": _bowser_jr(p)
		"king_boo": _king_boo(p)
		# Metroid
		"phantoon": _phantoon(p)
		"crocomire": _crocomire(p)
		"draygon": _draygon(p)
		"torizo": _torizo(p)
		# Kirby
		"rick": _rick(p)
		"kine": _kine(p)
		"coo": _coo(p)
		"gooey": _gooey(p)
		_: return false
	return true


static func _human(style: String) -> Dictionary:
	match style:
		# SpongeBob SquarePants
		"mermaid_man":
			return {"size": "adult", "top": Color("f2852a"), "sleeves": "long", "bottom_col": Color("3fae4a"), "shoe": Color("3fae4a"),
				"hair": "crew", "hair_col": Color("eeeeee"), "brow_col": Color("eeeeee"), "brow_w": 7.0, "skin": Color("f2c9a5"),
				"nose": "big", "torso_w": 30.0, "belly": 8.0, "base_lid": 0.3,
				"torso_extra": _x_hero_belt.bind(Color("3fae4a"), Color("f2c14e")), "extra": _x_white_moustache}
		"barnacle_boy":
			return {"size": "adult", "top": Color("f4f4f2"), "sleeves": "short", "bottom": "shorts", "bottom_col": Color("2f4f9a"),
				"sock": Color("f4f4f2"), "shoe": Color("2b2b33"), "hair": "fringe", "hair_col": Color("bbbbbb"), "skin": Color("f2c9a5"),
				"base_lid": 0.35, "torso_w": 26.0, "torso_extra": _x_neckerchief.bind("adult", Color("e6452f")), "extra": _x_sailor_cap}
		"bubble_bass":
			return {"size": "adult", "skin": Color("6fbf6a"), "top": Color("f4f4f2"), "sleeves": "none", "bottom_col": Color("8a6a4a"),
				"shoe": Color("2b2b33"), "hair": "none", "ears": false, "head": Vector2(42, 38), "head_shape": "wide", "torso_w": 44.0,
				"belly": 22.0, "nose": "big", "eye": Vector2(8, 10), "extra": _x_small_moustache.bind(Color("1d1d22"))}
		"king_neptune":
			return {"size": "adult", "skin": Color("8fd0b8"), "top": Color("8fd0b8"), "sleeves": "none", "bottom": "dress", "flare": 10.0,
				"bottom_col": Color("f2c14e"), "shoe": Color("8fd0b8"), "hair": "long", "hair_col": Color("f4f4f2"), "torso_w": 38.0,
				"brow_col": Color("f4f4f2"), "brow_w": 8.0, "base_lid": 0.25,
				"extra": _x_neptune_head, "back_extra": _x_trident}
		# Hey Arnold!
		"eugene":
			return {"size": "kid", "top": Color("f4f4f2"), "sleeves": "short", "bottom": "shorts", "bottom_col": Color("6fbf6a"),
				"sock": Color.WHITE, "shoe": Color("2b2b33"), "hair": "curly", "hair_col": Color("e6702f"), "head": Vector2(34, 40),
				"head_shape": "long", "torso_w": 24.0, "torso_extra": _x_bandage.bind("kid")}
		"lila":
			return {"size": "kid", "top": Color("6fbf6a"), "bottom": "dress", "flare": 16.0, "hair": "pigtails", "hair_col": Color("e6702f"),
				"lashes": 2, "sock": Color.WHITE, "shoe": Color("8a5a36"), "eye_iris": Color("3f8f3a"), "torso_w": 26.0,
				"extra": _x_hair_bow.bind(Color("6fbf6a"))}
		"olga":
			return {"size": "teen", "top": Color("f28cb8"), "sleeves": "long", "bottom": "skirt", "bottom_col": Color("f4f4f2"),
				"hair": "long", "hair_col": Color("f4d24e"), "lashes": 3, "eye_iris": Color("3d8fe0"), "legs": Puppet.SKIN,
				"shoe": Color("f28cb8"), "extra": _x_hair_bow.bind(Color("f28cb8"))}
		"mr_simmons":
			return {"size": "adult", "top": Color("8fbfe6"), "sleeves": "long", "bottom_col": Color("c8a86a"), "shoe": Color("6b4428"),
				"hair": "slick", "hair_col": Color("6b4428"), "torso_w": 30.0, "torso_extra": CastMore._x_tie.bind(Color("e6702f"))}
		"curly":
			return {"size": "kid", "top": Color("c8642a"), "sleeves": "long", "bottom_col": Color("3d5aa8"), "shoe": Color("2b2b33"),
				"hair": "wild", "hair_col": Color("1d1d22"), "glasses": true, "eye": Vector2(9, 11), "torso_extra": _x_plaid.bind("kid", Color("5a1a1a"))}
		# Doug
		"theda_funnie":
			return {"size": "adult", "top": Color("f28cb8"), "sleeves": "long", "bottom": "skirt", "bottom_col": Color("6fbf6a"),
				"legs": Puppet.SKIN, "shoe": Color("8a5a36"), "hair": "bob", "hair_col": Color("c8582e"), "lashes": 2, "torso_w": 28.0,
				"extra": CastExtra._x_earrings}
		"phil_funnie":
			return {"size": "adult", "top": Color("f4f4f2"), "sleeves": "short", "bottom_col": Color("4a78d0"), "shoe": Color("6b4428"),
				"hair": "tuft", "tuft_n": 3, "hair_col": Color("6b4428"), "nose": "big", "torso_w": 32.0, "belly": 6.0,
				"torso_extra": CastMore._x_tie.bind(Color("4a78d0"))}
		"al_sleech", "moo_sleech":
			var al := style == "al_sleech"
			return {"size": "kid", "skin": Color("c8a8e6") if al else Color("a8d0e6"), "top": Color("f4f4f2"), "sleeves": "long",
				"bottom_col": Color("6a6a7a"), "shoe": Color("2b2b33"), "hair": "none", "glasses": true, "head": Vector2(40, 40),
				"eye": Vector2(8, 10), "torso_extra": _x_lab_coat.bind("kid"), "extra": _x_bow_tie.bind("kid", Color("9b5fd0") if al else Color("5fa8d0"))}
		"ned_cauphee":
			return {"size": "teen", "skin": Color("e8c8a0"), "top": Color("8a6a4a"), "sleeves": "long", "bottom_col": Color("3d4a5a"),
				"shoe": Color("2b2b33"), "hair": "fringe", "hair_col": Color("3a2416"), "head_shape": "long", "head": Vector2(28, 38),
				"base_lid": 0.4}
		# Rugrats
		"betty":
			return {"size": "adult", "top": Color("9b5fd0"), "sleeves": "short", "bottom": "shorts", "bottom_col": Color("4a78d0"),
				"legs": Puppet.SKIN, "sock": Color.WHITE, "shoe": Color.WHITE, "hair": "ponytail", "hair_col": Color("8a4a2a"),
				"torso_w": 38.0, "belly": 6.0, "brow_w": 6.0, "extra": _x_whistle}
		"howard":
			return {"size": "adult", "top": Color("e8a0c8"), "sleeves": "short", "bottom_col": Color("c8a86a"), "shoe": Color("6b4428"),
				"hair": "fringe", "hair_col": Color("8a5a36"), "hairline": 0.3, "glasses": true, "torso_w": 28.0, "belly": 10.0,
				"head": Vector2(34, 34), "head_shape": "wide"}
		"chas":
			return {"size": "adult", "top": Color("f4f4f2"), "sleeves": "long", "bottom_col": Color("6a7a5a"), "shoe": Color("6b4428"),
				"hair": "fringe", "hair_col": Color("e5642a"), "glasses": true, "eye": Vector2(9, 11), "torso_w": 23.0, "arm_w": 7.0,
				"head_shape": "long", "head": Vector2(28, 40), "torso_extra": _x_sweater_vest.bind(Color("5aa84a"))}
		"drew":
			return {"size": "adult", "top": Color("4a5a8a"), "sleeves": "long", "bottom_col": Color("4a5a8a"), "shoe": Color("2b2b33"),
				"hair": "slick", "hair_col": Color("6b4428"), "nose": "big", "torso_w": 31.0, "torso_extra": CastExtra._x_suit}
		"charlotte":
			return {"size": "adult", "top": Color("7a3fa0"), "sleeves": "long", "bottom": "skirt", "bottom_col": Color("7a3fa0"),
				"legs": Puppet.SKIN, "shoe": Color("2b2b33"), "hair": "bob", "hair_col": Color("f4d24e"), "lashes": 2, "torso_w": 27.0,
				"base_lid": 0.2, "extra": _x_phone}
		"kira":
			return {"size": "adult", "skin": Color("f2d2b0"), "top": Color("e6452f"), "sleeves": "long", "bottom_col": Color("2b2b33"),
				"shoe": Color("2b2b33"), "hair": "long", "hair_col": Color("1d1d22"), "lashes": 2, "torso_w": 27.0,
				"extra": CastExtra._x_earrings}
		"kimi":
			return {"size": "baby", "skin": Color("f2d2b0"), "top": Color("9b5fd0"), "bottom": "shorts", "bottom_col": Color("6fbf6a"),
				"shoe": Color("f28cb8"), "hair": "pigtails", "hair_col": Color("8a2a3a"), "lashes": 2, "eye": Vector2(8, 10)}
		# Pokémon
		"professor_oak":
			return {"size": "adult", "top": Color("c8503a"), "sleeves": "long", "sleeve": Color("f4f4f2"), "bottom_col": Color("8a6a4a"),
				"shoe": Color("6b4428"), "hair": "spiky", "hair_col": Color("b8b8c0"), "brow_col": Color("b8b8c0"), "brow_w": 7.0,
				"torso_w": 31.0, "torso_extra": _x_lab_coat.bind("adult")}
		"gary_oak":
			return {"size": "kid", "top": Color("7a3fa0"), "sleeves": "long", "bottom_col": Color("2b2b33"), "shoe": Color("2b2b33"),
				"hair": "spiky", "hair_col": Color("8a5a36"), "base_lid": 0.3, "torso_extra": _x_pendant}
		"delia_ketchum":
			return {"size": "adult", "top": Color("f28cb8"), "sleeves": "short", "bottom": "skirt", "bottom_col": Color("7a3fa0"),
				"legs": Puppet.SKIN, "shoe": Color("8a5a36"), "hair": "ponytail", "hair_col": Color("8a4a2a"), "lashes": 2, "torso_w": 28.0}
		# Dragon Ball Z
		"majin_buu":
			return {"size": "adult", "skin": Color("f7a8c8"), "top": Color("3a2a4a"), "sleeves": "none", "bottom_col": Color("f4f4f2"),
				"shoe": Color("f2c14e"), "hair": "none", "ears": false, "head": Vector2(40, 34), "head_shape": "wide", "torso_w": 46.0,
				"belly": 30.0, "arm_w": 11.0, "leg_w": 20.0, "base_lid": 0.45, "torso_extra": _x_buu_belt,
				"extra": _x_buu_antenna, "back_extra": CastMore._x_cape.bind(Color("6a3fa8"))}
		"videl":
			return {"size": "teen", "top": Color("f4f4f2"), "sleeves": "short", "bottom": "shorts", "bottom_col": Color("2b2b33"),
				"legs": Color("2b2b33"), "shoe": Color("2b2b33"), "hair": "pigtails", "hair_col": Color("1d1d22"), "lashes": 2,
				"eye_iris": Color("3d6fd0"), "torso_w": 25.0}
		"mr_satan":
			return {"size": "adult", "skin": Color("e9b48a"), "top": Color("f4f4f2"), "sleeves": "none", "bottom_col": Color("f4f4f2"),
				"shoe": Color("2b2b33"), "hair": "curly", "hair_col": Color("2b211c"), "torso_w": 40.0, "belly": 6.0, "arm_w": 11.0,
				"torso_extra": _x_champ_belt, "extra": CastS2._x_small_moustache.bind(Color("2b211c"))}
		"goten":
			return {"size": "kid", "top": Color("f2852a"), "sleeves": "none", "bottom_col": Color("f2852a"), "shoe": Color("2f5fa8"),
				"hair": "saiyan", "hair_col": Color("1d1d22"), "eye": Vector2(8, 10), "torso_extra": _x_kid_gi.bind("kid", Color("2f5fa8"))}
		"king_kai":
			return {"size": "teen", "skin": Color("3d6fd0"), "top": Color("2b2b33"), "sleeves": "long", "bottom": "dress", "flare": 12.0,
				"shoe": Color("8a5a36"), "hair": "none", "ears": false, "head": Vector2(36, 32), "head_shape": "wide", "torso_w": 32.0,
				"belly": 8.0, "extra": _x_kai_face}
		"yamcha":
			return {"size": "adult", "top": Color("f2852a"), "sleeves": "none", "bottom_col": Color("f2852a"), "shoe": Color("2f5fa8"),
				"hair": "spiky", "hair_col": Color("1d1d22"), "torso_w": 34.0, "arm_w": 9.0,
				"torso_extra": _x_kid_gi.bind("adult", Color("2f5fa8")), "extra": _x_scar}
		# Attack on Titan
		"historia":
			var c := CastMore._scout(style)
			c.merge({"hair": "long", "hair_col": Color("f4d24e"), "eye_iris": Color("3d8fe0"), "lashes": 2, "torso_w": 24.0}, true)
			return c
		"ymir":
			var c := CastMore._scout(style)
			c.merge({"hair": "ponytail", "hair_col": Color("6b4428"), "skin": Color("e9b48a"), "eye_iris": Color("8a5a36"),
				"base_lid": 0.25, "extra": _x_freckles}, true)
			return c
		"bertolt":
			var c := CastMore._scout(style)
			c.merge({"hair": "crew", "hair_col": Color("1d1d22"), "skin": Color("e9b48a"), "head_shape": "long", "head": Vector2(30, 42),
				"torso_w": 26.0, "leg_w": 14.0}, true)
			return c
		"annie":
			return {"size": "teen", "top": Color("e8e8ea"), "sleeves": "long", "bottom_col": Color("2b2b33"), "shoe": Color("5a3a24"),
				"hair": "bun", "hair_col": Color("f4d24e"), "eye_iris": Color("3d8fe0"), "base_lid": 0.35, "nose": "long",
				"torso_w": 25.0, "torso_extra": CastMore._x_hoodie_strings}
		"hannes":
			return {"size": "adult", "top": Color("b88a5a"), "sleeves": "long", "bottom_col": Color("efe8d6"), "shoe": Color("5a3a24"),
				"hair": "crew", "hair_col": Color("e8c860"), "skin": Color("f2c0a0"), "nose": "big", "torso_w": 32.0,
				"torso_extra": _x_garrison_rose, "extra": CastMore._x_goatee.bind(Color("c8a050"))}
		# Breaking Bad
		"gale":
			return {"size": "adult", "top": Color("f4ecd8"), "sleeves": "long", "bottom_col": Color("6a5a4a"), "shoe": Color("6b4428"),
				"hair": "bob", "hair_col": Color("3a2416"), "glasses": true, "torso_w": 29.0,
				"torso_extra": _x_sweater_vest.bind(Color("8a6a3a")), "extra": _x_small_moustache.bind(Color("3a2416"))}
		"huell":
			return {"size": "adult", "skin": Color("8a5a3a"), "top": Color("2b2b33"), "sleeves": "long", "bottom_col": Color("2b2b33"),
				"hair": "crew", "hair_col": Color("1d1d22"), "hairline": -0.4, "base_lid": 0.5, "torso_w": 46.0, "belly": 22.0,
				"arm_w": 12.0, "leg_w": 19.0, "head": Vector2(38, 38), "torso_extra": CastMore._x_tie.bind(Color("6a3a2a")),
				"extra": CastMore._x_goatee.bind(Color("1d1d22"))}
		"gomez":
			return {"size": "adult", "skin": Color("c98a5a"), "top": Color("4a6a8a"), "sleeves": "short", "bottom_col": Color("3d4a5a"),
				"hair": "crew", "hair_col": Color("1d1d22"), "torso_w": 33.0, "torso_extra": _x_dea_badge,
				"extra": _x_small_moustache.bind(Color("1d1d22"))}
		"hector":
			return {"size": "adult", "skin": Color("c98a5a"), "top": Color("e8e0d0"), "sleeves": "long", "bottom_col": Color("5a4a3a"),
				"hair": "crew", "hair_col": Color("e8e8e8"), "brow_col": Color("e8e8e8"), "base_lid": 0.55, "nose": "big", "torso_w": 30.0,
				"torso_extra": _x_bell, "extra": _x_small_moustache.bind(Color("e8e8e8"))}
		"francesca":
			return {"size": "adult", "top": Color("2b3a4a"), "sleeves": "long", "bottom": "skirt", "bottom_col": Color("2b3a4a"),
				"legs": Puppet.SKIN, "shoe": Color("2b2b33"), "hair": "bob", "hair_col": Color("e8c860"), "lashes": 2, "base_lid": 0.3,
				"torso_w": 27.0, "extra": CastExtra._x_earrings}
		# Super Mario Brothers
		"waluigi":
			return {"size": "teen", "top": Color("7a3fa0"), "sleeves": "long", "bottom_col": Color("2b2b33"), "shoe": Color("e6702f"),
				"hair": "crew", "hair_col": Color("5a3a24"), "nose": "long", "torso_w": 22.0, "arm_w": 7.0, "leg_w": 11.0,
				"head": Vector2(30, 40), "head_shape": "long", "base_lid": 0.3,
				"torso_extra": _x_bib.bind("teen", Color("2b2b33")), "extra": CastMore._x_plumber.bind(Color("7a3fa0"), "Γ", true)}
		"rosalina":
			return {"size": "adult", "top": Color("8fd8e0"), "bottom": "dress", "flare": 40.0, "hair": "long", "hair_col": Color("f4f0d8"),
				"lashes": 2, "eye_iris": Color("3d8fe0"), "legs": Color("8fd8e0"), "shoe": Color("8fd8e0"), "sleeves": "long",
				"torso_w": 26.0, "extra": _x_star_crown}
		# Metroid
		"anthony_higgs":
			return {"size": "adult", "skin": Color("8a5a3a"), "top": Color("5a7a9a"), "sleeves": "long", "bottom_col": Color("4a5a6a"),
				"shoe": Color("2b2b33"), "hair": "none", "torso_w": 40.0, "arm_w": 11.0, "leg_w": 17.0, "head": Vector2(36, 38),
				"torso_extra": _x_armor_plate, "extra": _small_beard}
		# Kirby
		"susie_haltmann":
			return {"size": "adult", "top": Color("f4f4f2"), "sleeves": "long", "bottom": "skirt", "bottom_col": Color("2b2b33"),
				"legs": Color("2b2b33"), "shoe": Color("2b2b33"), "hair": "bob", "hair_col": Color("f28cb8"), "lashes": 2,
				"eye_iris": Color("3fae9a"), "base_lid": 0.2, "torso_w": 25.0, "torso_extra": _x_haltmann_jacket, "extra": _x_hair_clip}
		_: return {}


# --------------------------------------------------------- costume bits --

static func _x_haltmann_jacket(p: Puppet) -> void:
	for sx in [-1, 1]:
		Art.shape(p.ci, PackedVector2Array([Vector2(sx * 4, -196), Vector2(sx * 25, -196), Vector2(sx * 25, -110), Vector2(sx * 10, -110)]),
			Color("2b3a6a"), 2.5)
	Art.shape(p.ci, Art.rrect(Rect2(-8, -186, 16, 10), 3), Color("e6452f"), 2.0)


static func _x_hair_clip(p: Puppet, hc: Vector2) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(14, -34), Vector2(22, 10)), 4), Color("3fae9a"), 2.0)

static func _x_armor_plate(p: Puppet) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(-40, -196, 80, 60), 10), Color("8a9ab0"), 3.5, 0.12)
	for sx in [-1, 1]:
		Art.shape(p.ci, Art.rrect(Rect2(sx * 40 - 16, -204, 32, 22), 8), Color("8a9ab0"), 3.0)
	Art.shape(p.ci, Art.rrect(Rect2(-12, -180, 24, 14), 3), Color("f2c14e"), 2.0)


static func _small_beard(p: Puppet, hc: Vector2) -> void:
	Art.shape(p.ci, Art.arc_pts(hc + Vector2(0, 14), 28, 26, 0, PI, 14), Color("1d1d22"), 0.0)
	p._mouth(hc + Vector2(0, 20), 22, 0)

static func _x_bib(p: Puppet, size: String, col: Color) -> void:
	var sh: float = SHOULDER[size]
	var hip: float = HumanRig.SIZES[size].hip
	var tw: float = 22.0
	Art.shape(p.ci, PackedVector2Array([Vector2(-tw * 0.6, sh + 22), Vector2(tw * 0.6, sh + 22), Vector2(tw, hip + 6), Vector2(-tw, hip + 6)]), col, 3.0)
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([Vector2(sx * tw * 0.6, sh + 22), Vector2(sx * tw * 0.65, sh)]), 5.0, col)
		Art.dot(p.ci, Vector2(sx * tw * 0.45, sh + 28), 3.5, Color("f2c14e"))


static func _x_star_crown(p: Puppet, hc: Vector2) -> void:
	# Bangs swept over one eye, a little crown and a star wand
	Art.shape(p.ci, Art.smooth(PackedVector2Array([hc + Vector2(-34, -20), hc + Vector2(-8, -40), hc + Vector2(30, -26),
		hc + Vector2(6, 4), hc + Vector2(-10, -4)]), 4), Color("f4f0d8"), 3.0)
	CastMore._x_crown(p, hc)
	Art.limb(p.ci, PackedVector2Array([Vector2(56, -150), Vector2(66, -220)]), 4, Color("f2c14e"))
	Art.shape(p.ci, Art.star(Vector2(68, -232), 16), Color("f6e05a"), 2.5)

static func _x_dea_badge(p: Puppet) -> void:
	Art.shape(p.ci, Art.star(Vector2(-16, -170), 9), Color("f2c14e"), 2.0)


static func _x_bell(p: Puppet) -> void:
	# The little bell Hector rings to talk
	Art.stroke(p.ci, PackedVector2Array([Vector2(-10, -196), Vector2(0, -150), Vector2(10, -196)]), 2.0)
	Art.shape(p.ci, PackedVector2Array([Vector2(-10, -132), Vector2(-6, -150), Vector2(6, -150), Vector2(10, -132)]), Color("f2c14e"), 2.5)
	Art.dot(p.ci, Vector2(0, -129), 3, Color("c8902a"))

static func _x_freckles(p: Puppet, hc: Vector2) -> void:
	for sx in [-1, 1]:
		for k in 3:
			Art.dot(p.ci, hc + Vector2(sx * (16 + k * 5), 10 + (k % 2) * 4), 1.8, Color("8a5a36"))


static func _x_garrison_rose(p: Puppet) -> void:
	var bc := Vector2(-16, -172)
	Art.blob(p.ci, bc, 10, 11, Color("e6452f"), 2.0)
	Art.dot(p.ci, bc, 4, Color("8a1a1a"))

static func _x_kid_gi(p: Puppet, size: String, under: Color) -> void:
	var sh: float = SHOULDER[size]
	var hip: float = HumanRig.SIZES[size].hip
	var tw: float = 30.0 if size == "kid" else 32.0
	Art.shape(p.ci, PackedVector2Array([Vector2(-12, sh), Vector2(12, sh), Vector2(0, sh + 26)]), under, 2.5)
	Art.shape(p.ci, Art.rrect(Rect2(-tw, hip - 12, tw * 2, 12), 4), under, 3.0)


static func _x_buu_belt(p: Puppet) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(-60, -118, 120, 18), 6), Color("f2c14e"), 3.0)
	Art.shape(p.ci, Art.rrect(Rect2(-12, -122, 24, 26), 4), Color("2b2b33"), 2.5)
	Art.text(p.ci, ThemeDB.fallback_font, Vector2(-12, -101), "M", 18, Color("e6452f"), 0, HORIZONTAL_ALIGNMENT_CENTER, 24)


static func _x_buu_antenna(p: Puppet, hc: Vector2) -> void:
	Art.limb(p.ci, Art.curve(hc + Vector2(0, -30), hc + Vector2(-10, -64), hc + Vector2(-34, -70), 8), 10, Color("f7a8c8"))
	for i in 4:
		Art.dot(p.ci, hc + Vector2(-24 + i * 16, -18 + absf(i - 1.5) * 4), 3, Color("e6709a"))


static func _x_champ_belt(p: Puppet) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(-42, -122, 84, 18), 5), Color("2b2b33"), 3.0)
	Art.shape(p.ci, Art.rrect(Rect2(-18, -128, 36, 30), 6), Color("f2c14e"), 3.0)


static func _x_kai_face(p: Puppet, hc: Vector2) -> void:
	for sx in [-1, 1]:
		Art.blob(p.ci, hc + Vector2(sx * 14, -4), 14, 9, Color("1d1d22"), 3.0)
		Art.stroke(p.ci, Art.curve(hc + Vector2(sx * 12, -30), hc + Vector2(sx * 20, -56), hc + Vector2(sx * 34, -64), 8), 3.0)
	Art.stroke(p.ci, PackedVector2Array([hc + Vector2(-2, -4), hc + Vector2(2, -4)]), 3.0)
	Art.stroke(p.ci, Art.curve(hc + Vector2(-14, 26), hc + Vector2(0, 40), hc + Vector2(14, 26), 6), 4.0, Color("1d1d22"))


static func _x_scar(p: Puppet, hc: Vector2) -> void:
	Art.stroke(p.ci, PackedVector2Array([hc + Vector2(8, -16), hc + Vector2(24, 8)]), 2.5, Color("b8705a"))
	Art.stroke(p.ci, PackedVector2Array([hc + Vector2(-20, 10), hc + Vector2(-10, 20)]), 2.5, Color("b8705a"))

static func _x_pendant(p: Puppet) -> void:
	Art.stroke(p.ci, Art.curve(Vector2(-12, -126), Vector2(0, -100), Vector2(12, -126), 8), 2.0)
	Art.blob(p.ci, Vector2(0, -98), 5, 6, Color("f4f4f2"), 2.0)

static func _x_whistle(p: Puppet, hc: Vector2) -> void:
	Art.stroke(p.ci, Art.curve(hc + Vector2(-16, 34), hc + Vector2(0, 66), hc + Vector2(16, 34), 8), 2.5, Color("f4f4f2"))
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-6, 62), Vector2(14, 10)), 3), Color("c0c4cc"), 2.0)


static func _x_phone(p: Puppet, hc: Vector2) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(30, -6), Vector2(12, 34)), 3), Color("2b2b33"), 2.0)
	Art.stroke(p.ci, PackedVector2Array([hc + Vector2(36, -6), hc + Vector2(36, -22)]), 2.5)


static func _x_sweater_vest(p: Puppet, col: Color) -> void:
	Art.shape(p.ci, PackedVector2Array([Vector2(-23, -190), Vector2(-6, -190), Vector2(0, -160), Vector2(6, -190),
		Vector2(23, -190), Vector2(23, -112), Vector2(-23, -112)]), col, 3.0, 0.1)

static func _x_hero_belt(p: Puppet, belt: Color, buckle: Color) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(-32, -118, 64, 14), 4), belt, 3.0)
	Art.shape(p.ci, Art.star(Vector2(0, -111), 13), buckle, 2.5)


static func _x_white_moustache(p: Puppet, hc: Vector2) -> void:
	for sx in [-1, 1]:
		Art.blob(p.ci, hc + Vector2(sx * 14, 16), 16, 7, Color("eeeeee"), 2.5, 0.0, sx * 0.3)


static func _x_small_moustache(p: Puppet, hc: Vector2, col: Color) -> void:
	for sx in [-1, 1]:
		Art.blob(p.ci, hc + Vector2(sx * 9, 14), 9, 4, col, 2.0, 0.0, sx * 0.2)


static func _x_neckerchief(p: Puppet, size: String, col: Color) -> void:
	var sh: float = SHOULDER[size]
	Art.shape(p.ci, PackedVector2Array([Vector2(-18, sh + 2), Vector2(18, sh + 2), Vector2(0, sh + 32)]), col, 2.5)


static func _x_sailor_cap(p: Puppet, hc: Vector2) -> void:
	Art.shape(p.ci, Art.arc_pts(hc + Vector2(0, -22), 30, 18, PI, TAU, 12), Color("f4f4f2"), 3.0)
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-34, -26), Vector2(68, 10)), 4), Color("2f4f9a"), 2.5)


static func _x_neptune_head(p: Puppet, hc: Vector2) -> void:
	# Big white beard and a tall gold crown
	Art.shape(p.ci, Art.smooth(PackedVector2Array([hc + Vector2(-30, 10), hc + Vector2(30, 10), hc + Vector2(24, 70), hc + Vector2(0, 86),
		hc + Vector2(-24, 70)]), 4), Color("f4f4f2"), 3.0)
	p._mouth(hc + Vector2(0, 22), 18, 0)
	var y := hc.y - 40
	var crown := PackedVector2Array([Vector2(-28, y + 14), Vector2(-30, y - 22), Vector2(-14, y - 4), Vector2(0, y - 30), Vector2(14, y - 4),
		Vector2(30, y - 22), Vector2(28, y + 14)])
	Art.shape(p.ci, crown, Color("f2c14e"), 3.0, 0.12)
	for x in [-16, 0, 16]:
		Art.dot(p.ci, Vector2(x, y + 4), 3.5, Color("e6452f"))


static func _x_trident(p: Puppet, hc: Vector2) -> void:
	var x := 46.0
	Art.limb(p.ci, PackedVector2Array([Vector2(x, -10), Vector2(x, hc.y - 70)]), 8, Color("f2c14e"))
	for dx in [-16, 0, 16]:
		Art.limb(p.ci, PackedVector2Array([Vector2(x + dx, hc.y - 70), Vector2(x + dx, hc.y - 110)]), 6, Color("f2c14e"))
	Art.limb(p.ci, PackedVector2Array([Vector2(x - 16, hc.y - 70), Vector2(x + 16, hc.y - 70)]), 6, Color("f2c14e"))


static func _x_bandage(p: Puppet, size: String) -> void:
	# A sticking plaster on the arm: Eugene always has at least one
	var sh: float = SHOULDER[size]
	Art.shape(p.ci, Art.rrect(Rect2(-30, sh + 20, 16, 9), 3), Color("f2c9a5"), 2.0)


static func _x_plaid(p: Puppet, size: String, col: Color) -> void:
	var sh: float = SHOULDER[size]
	var hip: float = HumanRig.SIZES[size].hip
	for i in 3:
		var y := sh + 14 + (hip - sh - 20) * (i + 0.5) / 3.0
		Art.stroke(p.ci, PackedVector2Array([Vector2(-20, y), Vector2(20, y)]), 2.0, col)
	for i in 3:
		Art.stroke(p.ci, PackedVector2Array([Vector2(-12 + i * 12, sh + 8), Vector2(-12 + i * 12, hip - 4)]), 2.0, col)


static func _x_lab_coat(p: Puppet, size: String) -> void:
	var sh: float = SHOULDER[size]
	var hip: float = HumanRig.SIZES[size].hip
	for sx in [-1, 1]:
		Art.shape(p.ci, PackedVector2Array([Vector2(sx * 4, sh + 2), Vector2(sx * 30, sh + 4), Vector2(sx * 32, hip + 30),
			Vector2(sx * 10, hip + 30)]), Color("f4f4f2"), 2.5)
	Art.dot(p.ci, Vector2(-18, sh + 30), 3, Color("4a78d0"))


static func _x_bow_tie(p: Puppet, hc: Vector2, size: String, col: Color) -> void:
	var y: float = SHOULDER[size] + 4
	for sx in [-1, 1]:
		Art.shape(p.ci, PackedVector2Array([Vector2(0, y), Vector2(sx * 12, y - 7), Vector2(sx * 12, y + 7)]), col, 2.0)


static func _x_hair_bow(p: Puppet, hc: Vector2, col: Color) -> void:
	var b := hc + Vector2(0, -42)
	Art.shape(p.ci, PackedVector2Array([b, b + Vector2(-16, -10), b + Vector2(-16, 10)]), col, 2.5)
	Art.shape(p.ci, PackedVector2Array([b, b + Vector2(16, -10), b + Vector2(16, 10)]), col, 2.5)
	Art.blob(p.ci, b, 5, 5, col, 2.0)


# --------------------------------------------------------- creatures --

## A squid in a shirt (Squilliam): tentacle legs, a tall bulb head and a long nose.
static func _squid(p: Puppet, skin: Color, shirt: Color, unibrow: bool) -> void:
	var ci := p.ci
	var raise := p._arm_raise()
	p._arm(Vector2(-33, -118), -1, raise.x, 64, 7, skin, 7, skin)
	for i in 4:
		var x := -24.0 + i * 16.0
		var sw := sin(p._walk_phase + i * PI * 0.5) * 9.0 if p.walking else 0.0
		var foot := Vector2(x * 1.7 + sw, -8)
		Art.limb(ci, Art.curve(Vector2(x, -62), Vector2(x * 1.2 - 6, -34), foot, 10) + PackedVector2Array([foot + Vector2(signf(x + 0.1) * 10, 0)]),
			12, skin)
	var torso := Art.smooth(PackedVector2Array([Vector2(-30, -128), Vector2(30, -128), Vector2(42, -60), Vector2(0, -54), Vector2(-42, -60)]), 4)
	Art.shape(ci, torso, shirt, 4.0, 0.15)
	# Open collar and a little bow tie
	Art.shape(ci, PackedVector2Array([Vector2(-10, -126), Vector2(10, -126), Vector2(0, -104)]), Color.WHITE, 2.5)
	for sx in [-1, 1]:
		Art.shape(ci, PackedVector2Array([Vector2(0, -120), Vector2(sx * 12, -127), Vector2(sx * 12, -113)]), Color("e6452f"), 2.0)
	var head := Art.smooth(PackedVector2Array([Vector2(-15, -128), Vector2(-50, -170), Vector2(-60, -226), Vector2(-38, -274),
		Vector2(0, -288), Vector2(38, -274), Vector2(60, -226), Vector2(50, -170), Vector2(15, -128)]), 6)
	Art.shape(ci, head, skin, 4.5, 0.14, Vector2(-12, -10))
	for sx in [-1, 1]:
		p._eye(Vector2(sx * 20, -212), 17, 14, 5, Color("3a2416"), sx, 0.35, skin, Color("f6f0e6"))
	if unibrow:
		Art.limb(ci, PackedVector2Array([Vector2(-38, -236), Vector2(0, -244), Vector2(38, -236)]), 7, Color("2b2b33"), 0.0)
	p._mouth(Vector2(4, -150), 30, 0)
	var nose := Art.smooth(PackedVector2Array([Vector2(-6, -206), Vector2(8, -206), Vector2(20, -176), Vector2(12, -152),
		Vector2(0, -154), Vector2(-4, -180)]), 5)
	Art.shape(ci, nose, skin, 4.0, 0.15)
	p._arm(Vector2(33, -118), 1, raise.y, 64, 7, skin, 7, skin)



# ------------------------------------------------------------- Pokémon --

static func _psyduck(p: Puppet) -> void:
	var ci := p.ci
	var yel := Color("f6d65a")
	var raise := p._arm_raise()
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.blob(ci, Vector2(sx * 18 + sw, -8), 18, 8, Color("f2e8c8"), 3.0)
	Art.blob(ci, Vector2(0, -56), 36, 44, yel, 4.0, 0.12)
	var hc := Vector2(0, -132)
	Art.blob(ci, hc, 44, 40, yel, 4.0, 0.1)
	for dx in [-8, 0, 8]:
		Art.stroke(ci, PackedVector2Array([hc + Vector2(dx, -38), hc + Vector2(dx * 1.4, -60)]), 3.0)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 16, -10), 9, 9, 0, Color(0, 0, 0, 0), sx, 0.0, yel)
	Art.shape(ci, Art.ellipse(hc + Vector2(0, 16), 24, 12, 20), Color("f2e8c8"), 3.5)
	if p._talk_open > 0.1:
		Art.blob(ci, hc + Vector2(0, 18), 10, 5 * p._talk_open + 1, Color(0.36, 0.04, 0.1), 2.0)
	# Both hands on its aching head
	p._arm(Vector2(-30, -80), -1, maxf(raise.x, 2.6), 40, 9, yel, 8, yel)
	p._arm(Vector2(30, -80), 1, maxf(raise.y, 2.6), 40, 9, yel, 8, yel)


static func _togepi(p: Puppet) -> void:
	var ci := p.ci
	var cream := Color("f6ecc8")
	var raise := p._arm_raise()
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.4
		Art.blob(ci, Vector2(sx * 14 + sw, -8), 12, 8, cream, 3.0)
	p._arm(Vector2(-26, -58), -1, raise.x, 14, 8, cream, 7, cream)
	Art.blob(ci, Vector2(0, -60), 34, 44, cream, 4.0, 0.1)
	for dx in [-16, 0, 16]:
		Art.shape(ci, PackedVector2Array([Vector2(dx - 8, -100), Vector2(dx, -116), Vector2(dx + 8, -100)]), cream, 3.0)
	# Eggshell with red and blue triangles
	var shell := PackedVector2Array([Vector2(-36, -64), Vector2(-24, -76), Vector2(-12, -62), Vector2(0, -76), Vector2(12, -62),
		Vector2(24, -76), Vector2(36, -64), Vector2(34, -36), Vector2(20, -18), Vector2(-20, -18), Vector2(-34, -36)])
	Art.shape(ci, shell, Color.WHITE, 3.5, 0.08)
	Art.shape(ci, PackedVector2Array([Vector2(-22, -54), Vector2(-8, -54), Vector2(-15, -36)]), Color("e6452f"), 2.0)
	Art.shape(ci, PackedVector2Array([Vector2(8, -50), Vector2(22, -50), Vector2(15, -32)]), Color("4a78d0"), 2.0)
	for sx in [-1, 1]:
		p._eye(Vector2(sx * 12, -86), 5, 7, 0, Color(0, 0, 0, 0), sx, 0.0, cream)
	p._mouth(Vector2(0, -76), 14, 0)
	p._arm(Vector2(26, -58), 1, raise.y, 14, 8, cream, 7, cream)


static func _jigglypuff(p: Puppet) -> void:
	var ci := p.ci
	var pink := Color("f7b8d2")
	var raise := p._arm_raise()
	var c := Vector2(0, -62)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.blob(ci, Vector2(sx * 18 + sw, -8), 14, 8, pink, 3.0)
	Art.blob(ci, c + Vector2(-48, 4 - raise.x * 16), 12, 10, pink, 3.0)
	for sx in [-1, 1]:
		Art.shape(ci, PackedVector2Array([c + Vector2(sx * 18, -44), c + Vector2(sx * 40, -70), c + Vector2(sx * 42, -30)]), pink, 3.0)
		Art.fill(ci, PackedVector2Array([c + Vector2(sx * 26, -44), c + Vector2(sx * 38, -60), c + Vector2(sx * 38, -36)]), Color("2b2b33"))
	Art.shape(ci, Art.ellipse(c, 52, 52, 40), pink, 4.0, 0.1)
	Art.stroke(ci, Art.curve(c + Vector2(-8, -50), c + Vector2(-2, -30), c + Vector2(10, -40), 10), 4.0)
	for sx in [-1, 1]:
		p._eye(c + Vector2(sx * 20, -4), 13, 14, 8.0, Color("3fa0d8"), sx, 0.0, pink)
	p._mouth(c + Vector2(0, 26), 16, 0)
	Art.blob(ci, c + Vector2(48, 4 - raise.y * 16), 12, 10, pink, 3.0)




# ----------------------------------------------- Super Mario Brothers --

static func _toadette(p: Puppet) -> void:
	var ci := p.ci
	var skin := Puppet.SKIN
	var pink := Color("f28cb8")
	var raise := p._arm_raise()
	p._human_legs(-40, -10, 9, 11, skin, Color("e6452f"))
	p._arm(Vector2(-18, -80), -1, raise.x, 30, 7, skin, 6, skin)
	Art.shape(ci, PackedVector2Array([Vector2(-20, -94), Vector2(20, -94), Vector2(32, -40), Vector2(-32, -40)]), pink, 3.5, 0.12)
	Art.shape(ci, Art.rrect(Rect2(-14, -94, 28, 16), 6), Color.WHITE, 2.5)
	var hc := Vector2(0, -122)
	for sx in [-1, 1]:
		Art.blob(ci, hc + Vector2(sx * 52, 6), 14, 22, pink, 3.0)
		Art.dot(ci, hc + Vector2(sx * 52, 26), 5, Color.WHITE)
	Art.blob(ci, hc, 28, 26, skin, 3.5, 0.1)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 10, -2), 6, 10, 0, Color(0, 0, 0, 0), sx, 0.0, skin, Color.WHITE, 2)
		Art.blob(ci, hc + Vector2(sx * 18, 10), 5, 3, Color("f2a0a0"), 0.0)
	p._mouth(hc + Vector2(0, 14), 16, 0)
	var cap := Art.smooth(PackedVector2Array([hc + Vector2(-60, -10), hc + Vector2(-46, -58), hc + Vector2(0, -76), hc + Vector2(46, -58),
		hc + Vector2(60, -10), hc + Vector2(0, -14)]), 6)
	Art.shape(ci, cap, pink, 4.0, 0.1)
	for d in [Vector2(-34, -38), Vector2(0, -58), Vector2(34, -38)]:
		Art.blob(ci, hc + d, 13, 11, Color.WHITE, 2.5)
	p._arm(Vector2(18, -80), 1, raise.y, 30, 7, skin, 6, skin)


static func _bowser_jr(p: Puppet) -> void:
	var ci := p.ci
	var hide := Color("f2c14e")
	var green := Color("3f8f3a")
	var raise := p._arm_raise()
	Art.blob(ci, Vector2(-18, -96), 40, 46, green, 4.0, 0.15)
	Art.stroke(ci, Art.ellipse(Vector2(-18, -96), 42, 48, 30), 4.0, Color("f4f2e6"))
	for k in 3:
		var s := Vector2(-56, -126 + k * 30)
		Art.shape(ci, PackedVector2Array([s + Vector2(6, -8), s + Vector2(-14, 0), s + Vector2(6, 8)]), Color("f4f4f2"), 2.5)
	p._arm(Vector2(-22, -112), -1, raise.x, 28, 10, hide, 8, hide)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.limb(ci, PackedVector2Array([Vector2(sx * 14, -50), Vector2(sx * 16 + sw, -10)]), 18, hide)
	Art.blob(ci, Vector2(4, -84), 30, 40, hide, 3.5, 0.1)
	# His bib, with a big drawn-on mouth
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(-22, -116), Vector2(26, -116), Vector2(20, -78), Vector2(2, -66), Vector2(-16, -78)]), 4),
		Color.WHITE, 3.0)
	Art.shape(ci, PackedVector2Array([Vector2(-12, -104), Vector2(18, -104), Vector2(14, -92), Vector2(-8, -92)]), Color("e6452f"), 2.0)
	for k in 4:
		Art.dot(ci, Vector2(-8 + k * 8, -102), 2.5, Color.WHITE)
	var hc := Vector2(10, -156)
	Art.blob(ci, hc + Vector2(-16, -26), 22, 14, Color("e6702f"), 3.0)
	Art.blob(ci, hc, 36, 32, green, 4.0, 0.12)
	Art.blob(ci, hc + Vector2(24, 12), 22, 16, hide, 3.0)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 11 + 2, -6), 7, 9, 3.0, Color("e6452f"), sx, 0.1, green)
	p._mouth(hc + Vector2(20, 20), 22, 2)
	p._arm(Vector2(28, -112), 1, raise.y, 28, 10, hide, 8, hide)


static func _king_boo(p: Puppet) -> void:
	var ci := p.ci
	var white := Color("f6f4fa")
	var bob := sin(p._t * 2.0) * 8.0
	var c := Vector2(0, -150 + bob)
	Art.blob(ci, Vector2(0, -12), 50, 10, Color(0, 0, 0, 0.12), 0.0)
	var body := Art.smooth(PackedVector2Array([c + Vector2(-80, -20), c + Vector2(-60, -80), c + Vector2(0, -100), c + Vector2(60, -80),
		c + Vector2(80, -10), c + Vector2(60, 60), c + Vector2(110, 90), c + Vector2(20, 80), c + Vector2(-60, 70)]), 6)
	Art.shape(ci, body, white, 4.0, 0.08)
	for sx in [-1, 1]:
		Art.blob(ci, c + Vector2(sx * 74, 10 - p._arm_raise().x * 10), 18, 12, white, 3.0)
	for sx in [-1, 1]:
		p._eye(c + Vector2(sx * 24, -30), 12, 16, 7.0, Color("9b5fd0"), sx, 0.2, white)
	p._mouth(c + Vector2(0, 20), 70, 2)
	Art.shape(ci, Art.smooth(PackedVector2Array([c + Vector2(-10, 26), c + Vector2(14, 26), c + Vector2(10, 60), c + Vector2(-6, 56)]), 3),
		Color("e6609a"), 2.5)
	var y := c.y - 100
	Art.shape(ci, PackedVector2Array([Vector2(-34, y + 16), Vector2(-34, y - 14), Vector2(-17, y + 2), Vector2(0, y - 20), Vector2(17, y + 2),
		Vector2(34, y - 14), Vector2(34, y + 16)]), Color("f2c14e"), 3.0, 0.12)
	Art.dot(ci, Vector2(0, y + 4), 6, Color("e6452f"))




# ------------------------------------------------------------- Metroid --

static func _phantoon(p: Puppet) -> void:
	var ci := p.ci
	var bob := sin(p._t * 1.6) * 10.0
	var c := Vector2(0, -230 + bob)
	var body := Color(0.55, 0.45, 0.75, 0.9)
	# Wavy tentacles hanging down
	for i in 6:
		var x := -70.0 + i * 28.0
		var pts := PackedVector2Array()
		for k in 8:
			var f := k / 7.0
			pts.append(c + Vector2(x + sin(f * 5.0 + p._t * 3.0 + i) * 10.0, 40 + f * 150))
		Art.limb(ci, pts, 12 - i % 2 * 3, Color(0.6, 0.5, 0.8, 0.8))
	Art.shape(ci, Art.smooth(PackedVector2Array([c + Vector2(-100, 30), c + Vector2(-80, -60), c + Vector2(0, -100), c + Vector2(80, -60),
		c + Vector2(100, 30), c + Vector2(0, 60)]), 6), body, 4.0, 0.12)
	# One huge eye, and a little crown of spikes
	p._eye(c + Vector2(0, -16), 36, 30, 16.0, Color("e6452f"), 1, 0.1, body, Color("f6e05a"))
	for k in 5:
		var x := -40.0 + k * 20.0
		Art.shape(ci, PackedVector2Array([c + Vector2(x - 8, -86), c + Vector2(x, -120), c + Vector2(x + 8, -86)]), Color("8a3a8a"), 2.5)
	p._mouth(c + Vector2(0, 34), 40, 2)


static func _crocomire(p: Puppet) -> void:
	var ci := p.ci
	var red := Color("c8402a")
	var raise := p._arm_raise()
	p._arm(Vector2(-60, -200), -1, raise.x, 60, 14, red, 14, Color("f2c14e"))
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.4
		Art.limb(ci, PackedVector2Array([Vector2(sx * 34, -80), Vector2(sx * 40 + sw, -10)]), 30, red.darkened(0.15))
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(-70, -260), Vector2(70, -260), Vector2(80, -120), Vector2(50, -60), Vector2(-50, -60),
		Vector2(-80, -120)]), 6), red, 4.5, 0.14)
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(-40, -200), Vector2(40, -200), Vector2(40, -90), Vector2(-40, -90)]), 4),
		Color("f2a060"), 3.0)
	# A row of eyes all the way up
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(-66, -250), Vector2(-50, -316), Vector2(0, -336), Vector2(50, -316), Vector2(66, -250)]), 5),
		red, 4.0, 0.1)
	for k in 4:
		p._eye(Vector2(-42 + k * 28, -296), 9, 11, 0, Color(0, 0, 0, 0), 1 if k > 1 else -1, 0.2, red)
	p._mouth(Vector2(0, -230), 80, 3)
	p._arm(Vector2(60, -200), 1, raise.y, 60, 14, red, 14, Color("f2c14e"))


static func _draygon(p: Puppet) -> void:
	var ci := p.ci
	var shell := Color("4a8a7a")
	var belly := Color("e8d890")
	var bob := sin(p._t * 2.0) * 6.0
	var raise := p._arm_raise()
	# A big swimming crustacean: tail, belly plates, six little arms
	var tail := PackedVector2Array()
	for i in 10:
		var f := i / 9.0
		tail.append(Vector2(-40 - f * 120, -120 + bob + sin(f * 4.0 + p._t * 2.0) * 16.0))
	Art.limb(ci, tail, 26, shell)
	Art.shape(ci, PackedVector2Array([tail[9] + Vector2(10, -30), tail[9] + Vector2(-40, 0), tail[9] + Vector2(10, 30)]), shell.lightened(0.2), 3.0)
	for k in 3:
		p._arm(Vector2(-10 + k * 20, -90 + bob), 1 if k % 2 == 0 else -1, raise.x * 0.5 + 0.6, 30, 6, shell, 5, belly)
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(-60, -200 + bob), Vector2(40, -220 + bob), Vector2(70, -150 + bob), Vector2(40, -60 + bob),
		Vector2(-40, -60 + bob), Vector2(-70, -130 + bob)]), 6), shell, 4.5, 0.14)
	for k in 4:
		Art.shape(ci, Art.rrect(Rect2(-30, -170 + k * 26 + bob, 70, 20), 8), belly, 2.5)
	var hc := Vector2(40, -232 + bob)
	Art.blob(ci, hc, 40, 30, shell, 4.0, 0.12)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 12 + 6, -8), 7, 8, 3.0, Color("e6452f"), sx, 0.1, shell, Color("f6e05a"))
	p._mouth(hc + Vector2(16, 16), 24, 2)


static func _torizo(p: Puppet) -> void:
	var ci := p.ci
	var stone := Color("a8a090")
	var raise := p._arm_raise()
	# An old Chozo statue that came to life: stone body, bird head, glowing eyes
	p._arm(Vector2(-30, -200), -1, raise.x, 58, 12, stone, 12, stone.darkened(0.2))
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.limb(ci, PackedVector2Array([Vector2(sx * 20, -110), Vector2(sx * 26 + sw, -60), Vector2(sx * 16 + sw, -10)]), 18, stone)
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(-36, -230), Vector2(36, -230), Vector2(30, -110), Vector2(-30, -110)]), 4), stone, 4.0, 0.15)
	for d in [Vector2(-18, -200), Vector2(12, -170), Vector2(-8, -140)]:
		Art.stroke(ci, PackedVector2Array([d, d + Vector2(14, 10)]), 2.0, stone.darkened(0.35))
	var hc := Vector2(6, -270)
	Art.blob(ci, hc, 30, 28, stone, 4.0, 0.12)
	Art.shape(ci, PackedVector2Array([hc + Vector2(20, -6), hc + Vector2(60, 6), hc + Vector2(20, 14)]), Color("c8a050"), 3.0)
	var glow := Color("f2602a") if p._blink < 0.5 else Color("8a3a2a")
	for sx in [-1, 1]:
		Art.blob(ci, hc + Vector2(sx * 10 + 4, -6), 6, 5, glow, 0.0)
	p._arm(Vector2(30, -200), 1, raise.y, 58, 12, stone, 12, stone.darkened(0.2))




# --------------------------------------------------------------- Kirby --

static func _rick(p: Puppet) -> void:
	var ci := p.ci
	var fur := Color("e8c8a0")
	var raise := p._arm_raise()
	# A chubby hamster: round body, white belly, round ears
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.blob(ci, Vector2(sx * 22 + sw, -10), 18, 10, Color("c8a080"), 3.0)
	p._arm(Vector2(-40, -70), -1, raise.x, 22, 9, fur, 8, fur)
	Art.blob(ci, Vector2(0, -60), 54, 52, fur, 4.0, 0.1)
	Art.blob(ci, Vector2(6, -50), 34, 34, Color("f8f0e0"), 0.0)
	var hc := Vector2(6, -128)
	for sx in [-1, 1]:
		Art.blob(ci, hc + Vector2(sx * 30, -32), 16, 16, fur, 3.0)
		Art.blob(ci, hc + Vector2(sx * 30, -32), 8, 8, Color("f2a0b0"), 0.0)
	Art.blob(ci, hc, 46, 40, fur, 4.0, 0.1)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 16, -6), 7, 10, 0, Color(0, 0, 0, 0), sx, 0.0, fur, Color("1d1d22"))
		Art.blob(ci, hc + Vector2(sx * 30, 12), 8, 5, Color("f2a0b0"), 0.0)
	Art.dot(ci, hc + Vector2(0, 8), 4, Color("c86a6a"))
	p._mouth(hc + Vector2(0, 18), 16, 0)
	p._arm(Vector2(46, -70), 1, raise.y, 22, 9, fur, 8, fur)


static func _kine(p: Puppet) -> void:
	var ci := p.ci
	var body := Color("6ab8a0")
	var bob := sin(p._t * 2.5) * 6.0
	var c := Vector2(0, -110 + bob)
	# A sunfish standing on his tail: big round body, orange lips, fins
	Art.shape(ci, PackedVector2Array([c + Vector2(-20, 50), c + Vector2(20, 50), c + Vector2(30, 100 - bob), c + Vector2(-30, 100 - bob)]),
		body.darkened(0.15), 3.0)
	Art.shape(ci, PackedVector2Array([c + Vector2(-10, -60), c + Vector2(0, -110), c + Vector2(16, -60)]), body.darkened(0.1), 3.0)
	Art.blob(ci, c, 64, 70, body, 4.0, 0.12)
	Art.blob(ci, c + Vector2(10, 18), 40, 34, Color("e8f0d0"), 0.0)
	for sx in [-1, 1]:
		var fin := c + Vector2(sx * 60, 10)
		Art.shape(ci, PackedVector2Array([fin, fin + Vector2(sx * 26, -16 - p._arm_raise().x * 12), fin + Vector2(sx * 22, 20)]), body.lightened(0.15), 3.0)
	for sx in [-1, 1]:
		p._eye(c + Vector2(sx * 22 + 10, -20), 9, 13, 0, Color(0, 0, 0, 0), sx, 0.0, body, Color("1d1d22"))
	Art.blob(ci, c + Vector2(40, 22), 16, 12, Color("f2852a"), 3.0)
	if p._talk_open > 0.1:
		Art.blob(ci, c + Vector2(42, 22), 6, 4 * p._talk_open + 1, Color(0.36, 0.04, 0.1), 0.0)


static func _coo(p: Puppet) -> void:
	var ci := p.ci
	var feathers := Color("8a5a9a")
	var raise := p._arm_raise()
	var flap := sin(p._t * 6.0) * 0.2
	# A purple owl: big round body, yellow beak and feet, wide wings
	for sx in [-1, 1]:
		var base := Vector2(sx * 40, -100)
		var wing := PackedVector2Array([base, base + Vector2(sx * 60, -30 - (raise.x if sx < 0 else raise.y) * 30).rotated(flap * sx),
			base + Vector2(sx * 50, 30), base + Vector2(sx * 10, 40)])
		Art.shape(ci, wing, feathers.darkened(0.12), 3.5)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.4
		Art.shape(ci, PackedVector2Array([Vector2(sx * 16 + sw - 12, -10), Vector2(sx * 16 + sw + 12, -10), Vector2(sx * 16 + sw, -28)]), Color("f2c14e"), 2.5)
	Art.blob(ci, Vector2(0, -90), 54, 70, feathers, 4.0, 0.12)
	Art.blob(ci, Vector2(0, -70), 34, 40, Color("e8d8f0"), 0.0)
	var hc := Vector2(0, -130)
	for sx in [-1, 1]:
		Art.shape(ci, PackedVector2Array([hc + Vector2(sx * 20, -30), hc + Vector2(sx * 40, -66), hc + Vector2(sx * 44, -24)]), feathers, 3.0)
		Art.blob(ci, hc + Vector2(sx * 20, -4), 18, 18, Color.WHITE, 2.5)
		p._eye(hc + Vector2(sx * 20, -4), 9, 11, 0, Color(0, 0, 0, 0), sx, 0.1, Color.WHITE, Color("f6e05a"))
	Art.shape(ci, PackedVector2Array([hc + Vector2(-8, 12), hc + Vector2(8, 12), hc + Vector2(0, 30)]), Color("f2c14e"), 2.5)


static func _gooey(p: Puppet) -> void:
	var ci := p.ci
	var blue := Color("3d6fd0")
	var squish := 1.0 + sin(p._t * 3.0) * 0.04
	var c := Vector2(0, -56)
	# A wobbly blue blob with a long tongue that is always sticking out
	Art.shape(ci, Art.ellipse(c, 60 * squish, 54 / squish, 36), blue, 4.0, 0.12)
	for sx in [-1, 1]:
		Art.blob(ci, Vector2(sx * 30, -8), 18, 9, blue.darkened(0.15), 2.5)
		p._eye(c + Vector2(sx * 18, -12), 9, 12, 0, Color(0, 0, 0, 0), sx, 0.0, blue, Color("1d1d22"))
	var tongue := PackedVector2Array([c + Vector2(-8, 18), c + Vector2(8, 18), c + Vector2(12, 46 + p._talk_open * 8), c + Vector2(0, 54 + p._talk_open * 8),
		c + Vector2(-12, 46 + p._talk_open * 8)])
	Art.shape(ci, Art.smooth(tongue, 3), Color("e6609a"), 2.5)
	Art.stroke(ci, Art.curve(c + Vector2(-20, 16), c + Vector2(0, 26), c + Vector2(20, 16), 8), 3.0)

