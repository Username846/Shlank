class_name CastExtra
extends RefCounted
## Drawings for the larger cast. People are HumanRig settings; animals and
## oddballs have their own small drawing functions. Puppet._draw_body() falls
## through to draw() for any style it doesn't know.

const INK := Art.INK


static func draw(p: Puppet, style: String) -> bool:
	if HUMANS.has(style):
		HumanRig.draw(p, _human(style))
		return true
	match style:
		"plankton": _plankton(p)
		"computer": _computer(p)
		"puffer": _puffer(p)
		"whale": _whale(p)
		"snail": _snail(p)
		"lobster": _lobster(p)
		"dog": _dog(p)
		"cat": _cat(p)
		"wobble": _wobble(p)
		_: return false
	return true


# ------------------------------------------------------------------ people --

const HUMANS := ["grandma", "harold", "stinky", "sid", "rhonda", "big_bob",
	"dug", "skeetor", "patty", "rodger",
	"tommi", "chuckey", "angelika", "phill", "lill",
	"jessee", "jaymes", "boss"]


static func _human(style: String) -> Dictionary:
	match style:
		# Hillwood
		"grandma":
			return {"size": "adult", "top": Color("c9a6e3"), "bottom": "dress", "flare": 20.0, "hair": "bun", "hair_col": Color("dcdcdc"),
				"glasses": true, "brow_col": Color("bbbbbb"), "skin": Color("f2c9a5"), "shoe": Color("6b4428"), "sleeves": "long",
				"torso_extra": _x_flower_dots}
		"harold":
			return {"size": "kid", "torso_w": 40.0, "belly": 8.0, "top": Color("8a5fc0"), "bottom_col": Color("6a6a7a"),
				"hair": "tuft", "tuft_n": 1, "head": Vector2(44, 40), "head_shape": "wide", "nose": "big", "leg_w": 17.0}
		"stinky":
			return {"size": "teen", "torso_w": 22.0, "top": Color("c8d86a"), "bottom_col": Color("4a6fa8"), "head_shape": "long",
				"head": Vector2(26, 40), "hair": "tuft", "tuft_n": 2, "hair_col": Color("e8cf6a"), "arm_w": 7.0,
				"torso_extra": _x_overall_straps}
		"sid":
			return {"size": "kid", "top": Color("2e2e38"), "sleeves": "long", "bottom_col": Color("4a6fa8"), "hair": "crew",
				"hair_col": Color("c8582e"), "nose": "long", "base_lid": 0.2, "extra": _x_backwards_cap}
		"rhonda":
			return {"size": "kid", "top": Color("f28cb8"), "bottom": "skirt", "bottom_col": Color("7a3fa0"), "hair": "bob",
				"hair_col": Color("1d1d2a"), "hairline": -0.2, "glasses": true, "lashes": 2, "sock": Color.WHITE, "shoe": Color("26222c")}
		"big_bob":
			return {"size": "adult", "torso_w": 44.0, "belly": 16.0, "top": Color("4a78d0"), "sleeves": "long", "bottom_col": Color("2e2e38"),
				"hair": "fringe", "hair_col": Color("2b211c"), "nose": "big", "skin": Color("e9b48a"), "brow_w": 6.0, "head": Vector2(36, 38),
				"torso_extra": _x_tie}
		# Bluffington
		"dug":
			return {"size": "kid", "top": Color.WHITE, "bottom": "shorts", "bottom_col": Color("c8a86a"), "sock": Color.WHITE,
				"shoe": Color("6b4428"), "hair": "tuft", "tuft_n": 3, "hair_col": Color("3a2416"), "torso_extra": _x_vest}
		"skeetor":
			return {"size": "kid", "skin": Color("6fb8e0"), "top": Color("f2a65a"), "sleeves": "long", "bottom_col": Color("4a5a8a"),
				"hair": "tuft", "tuft_n": 3, "hair_col": Color("a0522d"), "nose": "big", "eye": Vector2(8, 10)}
		"patty":
			return {"size": "kid", "top": Color("5a8fd8"), "bottom": "skirt", "bottom_col": Color("f2c14e"), "hair": "bob",
				"hair_col": Color("8a4a2a"), "hairline": -0.25, "lashes": 2, "sock": Color.WHITE, "shoe": Color("6b4428"),
				"extra": _x_headband}
		"rodger":
			return {"size": "kid", "skin": Color("9ccf6a"), "top": Color("2b2b33"), "sleeves": "long", "bottom_col": Color("4a6fa8"),
				"hair": "slick", "hair_col": Color("1d1d22"), "base_lid": 0.35, "nose": "long", "torso_extra": _x_jacket_zip}
		# Playpen
		"tommi":
			return {"size": "baby", "top": Color("7ab8ea"), "bottom": "diaper", "shoe": Puppet.SKIN, "hair": "tuft", "tuft_n": 3,
				"hair_col": Color("6b4428"), "eye": Vector2(9, 11)}
		"chuckey":
			return {"size": "baby", "top": Color("4a78d0"), "bottom": "shorts", "bottom_col": Color("6fbf6a"), "hair": "wild",
				"hair_col": Color("e5642a"), "glasses": true, "eye": Vector2(8, 10), "shoe": Color("2e2a35"), "torso_extra": _x_planet}
		"angelika":
			return {"size": "kid", "top": Color("9b5fd0"), "bottom": "dress", "flare": 18.0, "hair": "pigtails",
				"hair_col": Color("f4d24e"), "lashes": 2, "sock": Color.WHITE, "shoe": Color("7a3fa0"), "eye_iris": Color("3d6fd0"),
				"extra": _x_purple_bows}
		"phill", "lill":
			var c := {"size": "baby", "top": Color("6fbf6a"), "bottom": "shorts" if style == "phill" else "skirt",
				"bottom_col": Color("4a78d0") if style == "phill" else Color("f28cb8"), "hair": "bob", "hair_col": Color("6b4428"),
				"hairline": -0.15, "shoe": Puppet.SKIN, "eye": Vector2(8, 10), "torso_extra": _x_duck}
			if style == "lill":
				c["extra"] = _x_pink_bow
				c["lashes"] = 2
			return c
		# Team Rokket
		"jessee", "jaymes":
			var jess := style == "jessee"
			return {"size": "adult", "top": Color("f4f4f2"), "sleeves": "long", "sleeve": Color("f4f4f2"),
				"bottom": "skirt" if jess else "pants", "bottom_col": Color("f4f4f2"), "legs": Color("2b2b33") if jess else Color("f4f4f2"),
				"shoe": Color("2b2b33"), "hair": "big_wave" if jess else "bob", "hair_col": Color("d9407a") if jess else Color("8f8fd8"),
				"eye_iris": Color("3d6fd0") if jess else Color("3f8f3a"), "lashes": 2 if jess else 0, "torso_w": 28.0 if jess else 31.0,
				"torso_extra": _x_rokket_r, "extra": _x_earrings if jess else _x_rose}
		"boss":
			return {"size": "adult", "top": Color("c8742a"), "sleeves": "long", "bottom_col": Color("a85f20"), "shoe": Color("2b211c"),
				"hair": "slick", "hair_col": Color("2b211c"), "base_lid": 0.4, "torso_w": 35.0, "torso_extra": _x_suit}
	return {}


# Small costume details used by the people above.

static func _x_flower_dots(p: Puppet) -> void:
	for d in [Vector2(-14, -170), Vector2(12, -150), Vector2(-6, -126), Vector2(16, -112)]:
		Art.dot(p.ci, d, 4, Color("f28cb8"))


static func _x_overall_straps(p: Puppet) -> void:
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([Vector2(sx * 14, -178), Vector2(sx * 12, -110)]), 6.0, Color("4a6fa8"))


static func _x_backwards_cap(p: Puppet, hc: Vector2) -> void:
	Art.shape(p.ci, Art.arc_pts(hc + Vector2(0, -16), 40, 30, PI, TAU, 16), Color("3f8f3a"), 3.5)
	Art.shape(p.ci, Art.rrect(Rect2(hc + Vector2(-58, -22), Vector2(26, 9)), 4), Color("3f8f3a"), 3.0)


static func _x_tie(p: Puppet) -> void:
	Art.shape(p.ci, PackedVector2Array([Vector2(-8, -196), Vector2(8, -196), Vector2(5, -140), Vector2(0, -132), Vector2(-5, -140)]), Color("e6452f"), 2.5)


static func _x_vest(p: Puppet) -> void:
	var vest := PackedVector2Array([Vector2(-29, -122), Vector2(-8, -122), Vector2(0, -100), Vector2(8, -122),
		Vector2(29, -122), Vector2(29, -56), Vector2(-29, -56)])
	Art.shape(p.ci, vest, Color("5aa84a"), 3.0, 0.12)


static func _x_headband(p: Puppet, hc: Vector2) -> void:
	Art.stroke(p.ci, Art.arc_pts(hc, 37, 39, PI * 1.15, PI * 1.85, 12), 5.0, Color("e6452f"))


static func _x_jacket_zip(p: Puppet) -> void:
	Art.stroke(p.ci, PackedVector2Array([Vector2(-10, -124), Vector2(0, -100), Vector2(10, -124)]), 3.0, Color("6b6b75"))


static func _x_planet(p: Puppet) -> void:
	Art.blob(p.ci, Vector2(0, -58), 9, 9, Color("f2c14e"), 2.5)
	p.ci.draw_arc(Vector2(0, -58), 14, -0.4, PI + 0.4, 10, INK, 2.5)


static func _x_purple_bows(p: Puppet, hc: Vector2) -> void:
	for sx in [-1, 1]:
		var b := hc + Vector2(sx * 50, -6)
		Art.shape(p.ci, PackedVector2Array([b, b + Vector2(-10, -10), b + Vector2(-10, 10)]), Color("c56bd8"), 2.5)
		Art.shape(p.ci, PackedVector2Array([b, b + Vector2(10, -10), b + Vector2(10, 10)]), Color("c56bd8"), 2.5)


static func _x_duck(p: Puppet) -> void:
	Art.blob(p.ci, Vector2(0, -58), 8, 6, Color("f6df4c"), 2.0)
	Art.blob(p.ci, Vector2(7, -64), 4, 4, Color("f6df4c"), 2.0)


static func _x_pink_bow(p: Puppet, hc: Vector2) -> void:
	var b := hc + Vector2(16, -38)
	Art.shape(p.ci, PackedVector2Array([b, b + Vector2(-12, -9), b + Vector2(-12, 9)]), Color("f28cb8"), 2.5)
	Art.shape(p.ci, PackedVector2Array([b, b + Vector2(12, -9), b + Vector2(12, 9)]), Color("f28cb8"), 2.5)


static func _x_rokket_r(p: Puppet) -> void:
	Art.shape(p.ci, Art.rrect(Rect2(-29, -196, 58, 26), 6), Color("2b2b33"), 3.0)
	# Counter-flip so the R never reads backwards
	p.ci.draw_set_transform(-Puppet.BOUNDS.position * Puppet.BAKE_SCALE, 0.0, Vector2(Puppet.BAKE_SCALE * p.facing, Puppet.BAKE_SCALE))
	Art.text(p.ci, UiKit.TITLE_FONT, Vector2(-20, -132), "R", 34, Color("e6452f"), 5, HORIZONTAL_ALIGNMENT_CENTER, 40)
	p.ci.draw_set_transform(-Puppet.BOUNDS.position * Puppet.BAKE_SCALE, 0.0, Vector2.ONE * Puppet.BAKE_SCALE)


static func _x_earrings(p: Puppet, hc: Vector2) -> void:
	for sx in [-1, 1]:
		Art.dot(p.ci, hc + Vector2(sx * 33, 16), 5, Color("3f8f3a"))


static func _x_rose(p: Puppet, hc: Vector2) -> void:
	Art.blob(p.ci, hc + Vector2(-10, 50), 7, 7, Color("e6452f"), 2.5)


static func _x_suit(p: Puppet) -> void:
	Art.shape(p.ci, PackedVector2Array([Vector2(-14, -196), Vector2(14, -196), Vector2(0, -150)]), Color.WHITE, 2.5)
	Art.shape(p.ci, PackedVector2Array([Vector2(-4, -192), Vector2(4, -192), Vector2(3, -160), Vector2(0, -154), Vector2(-3, -160)]), Color("b3202f"), 2.0)
	for sx in [-1, 1]:
		Art.stroke(p.ci, PackedVector2Array([Vector2(sx * 14, -196), Vector2(sx * 6, -150)]), 3.0)


# ---------------------------------------------------------- Bikini Bottom --

static func _plankton(p: Puppet) -> void:
	var ci := p.ci
	var green := Color("4f9a3a")
	var raise := p._arm_raise()
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.5
		Art.limb(ci, PackedVector2Array([Vector2(sx * 8, -24), Vector2(sx * 10 + sw, -2)]), 5, green)
	p._arm(Vector2(-20, -60), -1, raise.x, 26, 4, green, 4, green)
	var body := Art.smooth(PackedVector2Array([Vector2(0, -102), Vector2(22, -78), Vector2(24, -40), Vector2(14, -20),
		Vector2(-14, -20), Vector2(-24, -40), Vector2(-22, -78)]), 6)
	Art.shape(ci, body, green, 3.5, 0.15)
	for sx in [-1, 1]:
		Art.stroke(ci, Art.curve(Vector2(sx * 6, -100), Vector2(sx * 12, -120), Vector2(sx * 20, -130), 8), 3.0)
	p._eye(Vector2(0, -72), 13, 14, 6, Color("d8352a"), 1, 0.0, green, Color("f6ef9c"))
	p._brow(Vector2(0, -92), 15, 1, 6.0)
	p._mouth(Vector2(0, -42), 18, 0)
	p._arm(Vector2(20, -60), 1, raise.y, 26, 4, green, 4, green)


static func _computer(p: Puppet) -> void:
	var ci := p.ci
	var grey := Color("aab3bd")
	for x in [-26, 26]:
		Art.blob(ci, Vector2(x, -10), 10, 10, Color("3a3d42"), 3.0)
	Art.shape(ci, Art.rrect(Rect2(-42, -40, 84, 22), 6), grey, 3.5, 0.15)
	Art.limb(ci, PackedVector2Array([Vector2(0, -40), Vector2(0, -120)]), 10, Color("8a96a3"))
	var raise := p._arm_raise()
	p._arm(Vector2(-52, -160), -1, raise.x, 40, 4, Color("8a96a3"), 6, grey)
	Art.shape(ci, Art.rrect(Rect2(-58, -220, 116, 100), 12), grey, 4.0, 0.15)
	Art.shape(ci, Art.rrect(Rect2(-46, -208, 92, 74), 6), Color("17331f"), 3.0)
	# Face on the screen: line eyes and a waveform mouth that wiggles when talking
	var glow := Color("6dff8a")
	var lid := 0.0 if p.emotion != "smug" and p.emotion != "angry" else 6.0
	for sx in [-1, 1]:
		var e := Vector2(sx * 20, -186)
		if p.emotion == "angry":
			p.ci.draw_line(e + Vector2(-10, -6 * sx * -1), e + Vector2(10, 6 * sx * -1), glow, 4.0)
		else:
			p.ci.draw_line(e + Vector2(0, -10 + lid), e + Vector2(0, 8), glow, 4.0)
	var wave := PackedVector2Array()
	for i in 21:
		var x := -30.0 + i * 3.0
		var amp := 2.0 + p._talk_open * 9.0
		if p.emotion in ["happy", "excited"]:
			amp = maxf(amp, 4.0)
		wave.append(Vector2(x, -152 + sin(i * 1.3 + p._t * 12.0) * amp))
	p.ci.draw_polyline(wave, glow, 3.0)
	p._arm(Vector2(52, -160), 1, raise.y, 40, 4, Color("8a96a3"), 6, grey)


static func _puffer(p: Puppet) -> void:
	var ci := p.ci
	var tan := Color("e8d39a")
	var puffed := p.emotion in ["scared", "surprised", "angry", "nervous"]
	var r := 74.0 if puffed else 58.0
	var c := Vector2(0, -r - 18)
	# Tail fin behind
	Art.shape(ci, PackedVector2Array([c + Vector2(-r + 6, 0), c + Vector2(-r - 30, -24), c + Vector2(-r - 30, 24)]), tan.darkened(0.1), 3.5)
	for sx in [-1, 1]:
		Art.blob(ci, Vector2(sx * 18, -10), 14, 8, tan.darkened(0.15), 3.0)
	var body := Art.ellipse(c, r, r, 48)
	Art.shape(ci, body, tan, 4.0, 0.12)
	if puffed:
		for i in 14:
			var a := TAU * i / 14.0
			var b := c + Vector2(cos(a), sin(a)) * r
			Art.shape(ci, PackedVector2Array([b + Vector2(cos(a + 1.6), sin(a + 1.6)) * 6, b + Vector2(cos(a), sin(a)) * 16,
				b + Vector2(cos(a - 1.6), sin(a - 1.6)) * 6]), tan.darkened(0.2), 2.5)
	# Blue sailor dress on the lower half
	var band := PackedVector2Array([c + Vector2(-200, r * 0.1), c + Vector2(200, r * 0.1), c + Vector2(200, 200), c + Vector2(-200, 200)])
	for poly in Geometry2D.intersect_polygons(body, band):
		Art.shape(ci, poly, Color("4a78d0"), 3.5)
	Art.shape(ci, PackedVector2Array([c + Vector2(-16, r * 0.1), c + Vector2(16, r * 0.1), c + Vector2(0, r * 0.4)]), Color.WHITE, 2.5)
	var raise := p._arm_raise()
	for sx in [-1, 1]:
		var fin := c + Vector2(sx * (r + 4), r * 0.05 - (raise.y if sx > 0 else raise.x) * 14.0)
		Art.blob(ci, fin, 14, 8, tan.darkened(0.08), 3.0, 0.0, sx * 0.5)
	# Sailor hat
	Art.shape(ci, Art.rrect(Rect2(c + Vector2(-26, -r - 14), Vector2(52, 18)), 6), Color("4a78d0"), 3.5)
	Art.shape(ci, Art.rrect(Rect2(c + Vector2(-30, -r + 0), Vector2(60, 8)), 3), Color.WHITE, 3.0)
	for sx in [-1, 1]:
		p._eye(c + Vector2(sx * 20, -r * 0.35), 13, 15, 6, Color("3d8fe0"), sx, 0.0, tan, Color.WHITE, 3)
	p._mouth(c + Vector2(0, -r * 0.02), 26, 0, Color("b3202f"))
	Art.stroke(ci, Art.curve(c + Vector2(-13, -r * 0.02), c + Vector2(0, -r * 0.1), c + Vector2(13, -r * 0.02), 6), 5.0, Color("e6452f"))


static func _whale(p: Puppet) -> void:
	var ci := p.ci
	var grey := Color("8fa7c4")
	var raise := p._arm_raise()
	# Tail fluke behind
	var tail := PackedVector2Array([Vector2(-90, -40), Vector2(-150, -90), Vector2(-170, -60), Vector2(-120, -30)])
	Art.shape(ci, Art.smooth(tail, 4), grey.darkened(0.1), 3.5)
	var body := Art.smooth(PackedVector2Array([Vector2(0, -330), Vector2(80, -300), Vector2(108, -200), Vector2(100, -60),
		Vector2(60, -4), Vector2(-60, -4), Vector2(-100, -60), Vector2(-108, -200), Vector2(-80, -300)]), 7)
	Art.shape(ci, body, grey, 4.5, 0.12, Vector2(-16, -12))
	var belly := Art.smooth(PackedVector2Array([Vector2(0, -170), Vector2(60, -120), Vector2(56, -30), Vector2(0, -10),
		Vector2(-56, -30), Vector2(-60, -120)]), 6)
	Art.shape(ci, belly, Color("e9eef4"), 3.0)
	# Cheerleader top
	var band := PackedVector2Array([Vector2(-200, -175), Vector2(200, -175), Vector2(200, -130), Vector2(-200, -130)])
	for poly in Geometry2D.intersect_polygons(body, band):
		Art.shape(ci, poly, Color("e6452f"), 3.5)
	for sx in [-1, 1]:
		var fin := Vector2(sx * 104, -150 - (raise.y if sx > 0 else raise.x) * 20.0)
		Art.blob(ci, fin, 30, 14, grey.darkened(0.08), 3.5, 0.0, sx * 0.6)
	# Blonde ponytails from the top
	for sx in [-1, 1]:
		Art.blob(ci, Vector2(sx * 30, -338), 12, 26, Color("f4d24e"), 3.0, 0.0, sx * 0.5)
	for sx in [-1, 1]:
		p._eye(Vector2(sx * 34, -246), 15, 18, 7, Color("3d8fe0"), sx, 0.0, grey, Color.WHITE, 3)
	p._mouth(Vector2(0, -196), 80, 2)


static func _snail(p: Puppet) -> void:
	var ci := p.ci
	var body_col := Color("7ec7d8")
	var slide := sin(p._walk_phase) * 3.0
	var foot := Art.smooth(PackedVector2Array([Vector2(-62, -4), Vector2(56 + slide, -6), Vector2(66 + slide, -22), Vector2(40, -40),
		Vector2(-50, -26)]), 6)
	Art.shape(ci, foot, body_col, 3.5, 0.12)
	# Eye stalks
	for k in 2:
		var base := Vector2(44 + k * 10, -32)
		var tip := base + Vector2(6 + k * 6, -58)
		Art.limb(ci, Art.curve(base, base + Vector2(0, -30), tip, 8), 6, body_col)
		p._eye(tip, 9, 9, 0, Color(0, 0, 0, 0), 1 if k else -1, 0.0, body_col)
	# Spiral shell
	var sc := Vector2(-8, -72)
	Art.blob(ci, sc, 46, 44, Color("f2a1b4"), 4.0, 0.12)
	var spiral := PackedVector2Array()
	for i in 40:
		var a := i * 0.4
		spiral.append(sc + Vector2(cos(a), sin(a)) * (36.0 - i * 0.85))
	Art.stroke(ci, spiral, 3.0, Color("b8566e"))
	p._mouth(Vector2(54, -14), 12, 0)


static func _lobster(p: Puppet) -> void:
	var ci := p.ci
	var red := Color("d9472f")
	var raise := p._arm_raise()
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx)
		Art.limb(ci, PackedVector2Array([Vector2(sx * 18, -116), Vector2(sx * 22 + sw, -6)]), 12, red)
	p._claw(Vector2(-58, -236), -1, raise.x, red)
	Art.shape(ci, Art.rrect(Rect2(-38, -128, 76, 32), 8), Color("3d8fe0"), 3.5)
	var chest := PackedVector2Array([Vector2(-70, -270), Vector2(70, -270), Vector2(40, -118), Vector2(-40, -118)])
	Art.shape(ci, Art.smooth(chest, 4), red, 4.0, 0.15)
	Art.stroke(ci, PackedVector2Array([Vector2(0, -258), Vector2(0, -150)]), 3.0, red.darkened(0.35))
	for sx in [-1, 1]:
		Art.stroke(ci, Art.curve(Vector2(sx * 6, -215), Vector2(sx * 30, -205), Vector2(sx * 48, -224), 8), 3.0, red.darkened(0.35))
	var hc := Vector2(0, -298)
	for sx in [-1, 1]:
		Art.stroke(ci, Art.curve(hc + Vector2(sx * 8, -20), hc + Vector2(sx * 30, -60), hc + Vector2(sx * 70, -66), 10), 3.0, red.darkened(0.2))
	Art.blob(ci, hc, 34, 30, red, 4.0, 0.12)
	# Sunglasses
	Art.shape(ci, Art.rrect(Rect2(hc + Vector2(-30, -12), Vector2(60, 16)), 6), Color("1d1d22"), 3.0)
	Art.stroke(ci, PackedVector2Array([hc + Vector2(-20, -9), hc + Vector2(-10, -9)]), 2.0, Color(1, 1, 1, 0.6))
	p._mouth(hc + Vector2(0, 16), 26, 2)
	p._claw(Vector2(58, -236), 1, raise.y, red)


# ------------------------------------------------------------- animals --

static func _dog(p: Puppet) -> void:
	var ci := p.ci
	var white := Color("f4f2ec")
	var raise := p._arm_raise()
	# Tail
	Art.limb(ci, Art.curve(Vector2(-26, -50), Vector2(-48, -60 + sin(p._t * 8.0) * 6.0), Vector2(-52, -84), 8), 7, white)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.6
		Art.limb(ci, PackedVector2Array([Vector2(sx * 14, -40), Vector2(sx * 15 + sw, -8)]), 13, white)
		Art.blob(ci, Vector2(sx * 15 + sw + 4, -6), 10, 6, white, 3.0)
	p._arm(Vector2(-22, -92), -1, raise.x, 34, 9, white, 7, white)
	Art.blob(ci, Vector2(0, -70), 30, 40, white, 4.0, 0.1)
	var hc := Vector2(6, -138)
	for sx in [-1, 1]:
		Art.blob(ci, hc + Vector2(sx * 30, -4), 11, 24, Color("2b2b33"), 3.0, 0.0, sx * 0.25)
	Art.blob(ci, hc, 34, 30, white, 4.0, 0.1)
	Art.blob(ci, hc + Vector2(14, 10), 20, 14, white, 3.0)
	Art.blob(ci, hc + Vector2(30, 4), 7, 5, Color("2b2b33"), 2.0)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 12 - 2, -8), 7, 9, 0, Color(0, 0, 0, 0), sx, 0.0, white)
	p._mouth(hc + Vector2(14, 20), 18, 0)
	p._arm(Vector2(22, -92), 1, raise.y, 34, 9, white, 7, white)


static func _cat(p: Puppet) -> void:
	var ci := p.ci
	var cream := Color("f3e3b4")
	var brown := Color("8a5a36")
	var raise := p._arm_raise()
	# Curly tail
	var tail := PackedVector2Array()
	for i in 12:
		var f := i / 11.0
		tail.append(Vector2(-22 - f * 40, -30 - f * 70 + sin(f * 6.0 + p._t * 2.0) * 10))
	Art.limb(ci, tail, 7, cream)
	Art.dot(ci, tail[11], 6, brown)
	for sx in [-1, 1]:
		var sw := p._leg_swing(sx) * 0.6
		var foot := Vector2(sx * 12 + sw, -8)
		Art.limb(ci, PackedVector2Array([Vector2(sx * 12, -40), foot]), 11, cream)
		Art.blob(ci, foot + Vector2(3, 2), 9, 6, brown, 3.0)
	p._arm(Vector2(-20, -82), -1, raise.x, 30, 7, cream, 6, cream)
	Art.blob(ci, Vector2(0, -62), 26, 34, cream, 4.0, 0.1)
	var hc := Vector2(0, -132)
	for sx in [-1, 1]:
		var ear := PackedVector2Array([hc + Vector2(sx * 16, -28), hc + Vector2(sx * 42, -62), hc + Vector2(sx * 44, -18)])
		Art.shape(ci, ear, cream, 3.5)
		Art.shape(ci, PackedVector2Array([hc + Vector2(sx * 24, -30), hc + Vector2(sx * 40, -52), hc + Vector2(sx * 40, -26)]), Color("2b2b33"), 0.0)
	Art.blob(ci, hc, 46, 38, cream, 4.0, 0.1)
	# Charm coin on the forehead
	Art.blob(ci, hc + Vector2(0, -30), 11, 9, Color("f2c14e"), 3.0, 0.15)
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * 15, -4), 9, 11, 0, Color(0, 0, 0, 0), sx, 0.0, cream)
		for k in 3:
			Art.stroke(ci, PackedVector2Array([hc + Vector2(sx * 22, 12 + k * 4), hc + Vector2(sx * 52, 8 + k * 7)]), 1.6)
	Art.blob(ci, hc + Vector2(0, 8), 4, 3, Color("f28cb8"), 1.5)
	p._mouth(hc + Vector2(0, 18), 22, 0)
	p._arm(Vector2(20, -82), 1, raise.y, 30, 7, cream, 6, cream)


static func _wobble(p: Puppet) -> void:
	var ci := p.ci
	var blue := Color("6fa8e6")
	# Black tail with eyes peeking out from behind
	var tc := Vector2(-46, -26)
	Art.blob(ci, tc, 22, 18, Color("2b2b33"), 3.0)
	for sx in [-1, 1]:
		Art.dot(ci, tc + Vector2(sx * 7, -3), 4, Color.WHITE)
	var bob := sin(p._t * 3.0) * 3.0
	var body := Art.smooth(PackedVector2Array([Vector2(0, -228 + bob), Vector2(48, -200), Vector2(56, -90), Vector2(46, -10),
		Vector2(-46, -10), Vector2(-56, -90), Vector2(-48, -200)]), 7)
	Art.shape(ci, body, blue, 4.0, 0.14, Vector2(-12, -10))
	# Little feet
	for sx in [-1, 1]:
		Art.blob(ci, Vector2(sx * 24, -6), 16, 7, blue.darkened(0.1), 3.0)
	# Squinty eyes, always the same
	for sx in [-1, 1]:
		Art.stroke(ci, PackedVector2Array([Vector2(sx * 10, -184), Vector2(sx * 26, -184)]), 4.0)
	p._mouth(Vector2(0, -160), 22, 0, Color("b3202f"))
	# Arms: one up in a salute
	var raise := p._arm_raise()
	p._arm(Vector2(-46, -140), -1, raise.x, 34, 9, blue, 8, blue)
	p._arm(Vector2(46, -140), 1, maxf(raise.y, 2.2), 34, 9, blue, 8, blue)
