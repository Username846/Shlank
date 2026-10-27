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
		_: return {}


# --------------------------------------------------------- costume bits --

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

