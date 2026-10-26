class_name HumanRig
extends RefCounted
## A configurable cartoon human, so new people are a dictionary of settings
## instead of a whole drawing function. Feet are at (0, 0).
##
## Common keys (all optional):
##   size: "kid" | "baby" | "adult" | "teen"   body proportions
##   skin, top, sleeve (colors); sleeves: "short" | "long" | "none"
##   torso_w: half-width of the body; belly: extra roundness
##   bottom: "pants" | "shorts" | "skirt" | "diaper" | "dress"; bottom_col
##   legs: leg colour (default skin, or bottom_col for pants); sock; shoe
##   head: Vector2 radii; head_shape: "round" | "long" | "wide"
##   hair: "none" | "crew" | "spiky" | "bob" | "long" | "pigtails" | "bun" |
##         "fringe" | "curly" | "ponytail" | "tuft" | "slick" | "wild" | "big_wave"
##   hair_col; glasses: true; eye_iris: Color; lashes: int; base_lid
##   nose: "dot" | "big" | "long"; ears: true
##   extra: Callable(p, hc) drawn after the face (hats, bows, badges...)
##   torso_extra: Callable(p) drawn on the body

const SIZES := {
	"baby": {"hip": -34.0, "shoulder": -80.0, "head_y": -124.0, "head": Vector2(44, 42), "leg_w": 13.0, "arm": 34.0, "torso_w": 28.0},
	"kid": {"hip": -62.0, "shoulder": -126.0, "head_y": -180.0, "head": Vector2(38, 40), "leg_w": 13.0, "arm": 52.0, "torso_w": 29.0},
	"teen": {"hip": -92.0, "shoulder": -178.0, "head_y": -228.0, "head": Vector2(32, 36), "leg_w": 13.0, "arm": 70.0, "torso_w": 28.0},
	"adult": {"hip": -104.0, "shoulder": -196.0, "head_y": -250.0, "head": Vector2(33, 38), "leg_w": 15.0, "arm": 76.0, "torso_w": 33.0},
}


static func draw(p: Puppet, c: Dictionary) -> void:
	var ci := p.ci
	var dims: Dictionary = SIZES[c.get("size", "kid")]
	var skin: Color = c.get("skin", Puppet.SKIN)
	var top: Color = c.get("top", Color("6fb8e6"))
	var hip: float = dims.hip
	var sh: float = dims.shoulder
	var tw: float = c.get("torso_w", dims.torso_w)
	var hc := Vector2(0, c.get("head_y", dims.head_y))
	var hr: Vector2 = c.get("head", dims.head)
	var raise := p._arm_raise()
	var arm_len: float = c.get("arm", dims.arm)
	var sleeves: String = c.get("sleeves", "short")
	var sleeve_col: Color = c.get("sleeve", top)
	var arm_col: Color = sleeve_col if sleeves == "long" else skin
	var bottom: String = c.get("bottom", "pants")
	var bottom_col: Color = c.get("bottom_col", Color("3d5aa8"))

	_hair_back(p, c, hc, hr)
	# Back arm
	p._arm(Vector2(-tw + 3, sh + 8), -1, raise.x, arm_len, c.get("arm_w", 8.0), arm_col, 7, skin,
		sleeve_col, 11.0 if sleeves == "short" else 0.0)
	# Legs
	var leg_col: Color = c.get("legs", bottom_col if bottom == "pants" else skin)
	p._human_legs(hip + 4, -10, c.get("leg_sep", tw * 0.42), c.get("leg_w", dims.leg_w), leg_col,
		c.get("shoe", Color("2e2a35")), c.get("sock", Color(0, 0, 0, 0)), 0.5)
	# Lower garment
	match bottom:
		"shorts":
			Art.shape(ci, Art.rrect(Rect2(-tw - 2, hip - 10, tw * 2 + 4, 30), 6), bottom_col, 3.5, 0.12)
		"skirt", "dress":
			var flare: float = c.get("flare", 14.0)
			Art.shape(ci, PackedVector2Array([Vector2(-tw, hip - 12), Vector2(tw, hip - 12), Vector2(tw + flare, hip + 22),
				Vector2(-tw - flare, hip + 22)]), bottom_col if bottom == "skirt" else top, 3.5, 0.12)
		"diaper":
			Art.shape(ci, Art.rrect(Rect2(-tw - 4, hip - 10, tw * 2 + 8, 30), 12), Color("f6f6f2"), 3.5, 0.1)
			Art.dot(ci, Vector2(-tw + 2, hip - 2), 3.5, Color("9cc8ee"))
			Art.dot(ci, Vector2(tw - 2, hip - 2), 3.5, Color("9cc8ee"))
	# Torso
	var torso := Art.rrect(Rect2(-tw, sh, tw * 2, hip - sh + 6), c.get("torso_round", 12.0))
	if c.get("belly", 0.0) > 0.0:
		var b: float = c.belly
		torso = Art.smooth(PackedVector2Array([Vector2(-tw, sh), Vector2(tw, sh), Vector2(tw + b, (sh + hip) * 0.5),
			Vector2(tw * 0.9, hip + 6), Vector2(-tw * 0.9, hip + 6), Vector2(-tw - b, (sh + hip) * 0.5)]), 5)
	Art.shape(ci, torso, top, 4.0, 0.14)
	if c.has("torso_extra"):
		c.torso_extra.call(p)
	# Neck and ears
	Art.shape(ci, Art.rrect(Rect2(-6, hc.y + hr.y - 6, 12, sh - (hc.y + hr.y) + 10), 4), skin, 3.0)
	if c.get("ears", true):
		for sx in [-1, 1]:
			Art.blob(ci, hc + Vector2(sx * hr.x * 0.98, 4), 7, 10, skin, 3.0)
	# Head
	var head := _head_shape(c.get("head_shape", "round"), hc, hr)
	Art.shape(ci, head, skin, 4.0, 0.1, Vector2(-hr.x * 0.3, -hr.y * 0.2))
	_hair_front(p, c, hc, hr, head)
	# Face
	var ex: float = c.get("eye_x", hr.x * 0.36)
	var ey: float = c.get("eye_y", -hr.y * 0.12)
	var er: Vector2 = c.get("eye", Vector2(7, 9))
	var iris: Color = c.get("eye_iris", Color(0, 0, 0, 0))
	for sx in [-1, 1]:
		p._eye(hc + Vector2(sx * ex, ey), er.x, er.y, 3.5 if iris.a > 0 else 0.0, iris, sx, c.get("base_lid", 0.0), skin,
			Color.WHITE, c.get("lashes", 0))
		if c.get("glasses", false):
			ci.draw_arc(hc + Vector2(sx * ex, ey), er.y + 4, 0, TAU, 24, Art.INK, 3.0)
	if c.get("glasses", false):
		Art.stroke(ci, PackedVector2Array([hc + Vector2(-ex + er.y + 3, ey), hc + Vector2(ex - er.y - 3, ey)]), 3.0)
	if c.get("brows", true):
		p._brows(hc.y + ey - er.y - 7, ex, er.x + 1, c.get("brow_w", 3.0), c.get("brow_col", Art.INK))
	match c.get("nose", "dot"):
		"dot":
			Art.stroke(ci, Art.curve(hc + Vector2(0, ey + 8), hc + Vector2(6, ey + 14), hc + Vector2(0, ey + 17), 6), 3.0)
		"big":
			Art.blob(ci, hc + Vector2(5, ey + 16), 9, 10, skin, 3.0, 0.15)
		"long":
			Art.shape(ci, PackedVector2Array([hc + Vector2(-3, ey + 4), hc + Vector2(16, ey + 20), hc + Vector2(-2, ey + 22)]), skin, 3.0)
	p._mouth(hc + Vector2(0, hr.y * 0.55), c.get("mouth_w", hr.x * 0.75), c.get("teeth", 0))
	if c.has("extra"):
		c.extra.call(p, hc)
	# Front arm
	p._arm(Vector2(tw - 3, sh + 8), 1, raise.y, arm_len, c.get("arm_w", 8.0), arm_col, 7, skin,
		sleeve_col, 11.0 if sleeves == "short" else 0.0)


static func _head_shape(kind: String, hc: Vector2, hr: Vector2) -> PackedVector2Array:
	match kind:
		"long":
			return Art.smooth(PackedVector2Array([hc + Vector2(0, -hr.y), hc + Vector2(hr.x, -hr.y * 0.5), hc + Vector2(hr.x * 0.95, hr.y * 0.5),
				hc + Vector2(hr.x * 0.5, hr.y * 1.05), hc + Vector2(-hr.x * 0.5, hr.y * 1.05), hc + Vector2(-hr.x * 0.95, hr.y * 0.5),
				hc + Vector2(-hr.x, -hr.y * 0.5)]), 6)
		"wide":
			return Art.ellipse(hc, hr.x * 1.15, hr.y * 0.92, 40)
	return Art.ellipse(hc, hr.x, hr.y, 40)


## Hair that sits behind the head (long hair, pigtails, buns, bobs).
static func _hair_back(p: Puppet, c: Dictionary, hc: Vector2, hr: Vector2) -> void:
	var ci := p.ci
	var col: Color = c.get("hair_col", Color("3a2416"))
	match c.get("hair", "crew"):
		"bob":
			Art.shape(ci, Art.rrect(Rect2(hc.x - hr.x - 8, hc.y - hr.y - 6, hr.x * 2 + 16, hr.y * 1.75), 20), col, 3.5)
		"long":
			Art.shape(ci, Art.rrect(Rect2(hc.x - hr.x - 9, hc.y - hr.y - 6, hr.x * 2 + 18, hr.y * 2.6), 22), col, 3.5, 0.1)
		"big_wave":
			# A huge swoop of hair curving out behind (Jessee-style)
			var pts := Art.smooth(PackedVector2Array([hc + Vector2(-hr.x * 0.6, -hr.y * 1.1), hc + Vector2(-hr.x * 2.6, -hr.y * 0.6),
				hc + Vector2(-hr.x * 3.3, hr.y * 1.2), hc + Vector2(-hr.x * 2.6, hr.y * 3.0), hc + Vector2(-hr.x * 1.6, hr.y * 2.2),
				hc + Vector2(-hr.x * 1.9, hr.y * 0.9), hc + Vector2(-hr.x * 0.9, hr.y * 0.6)]), 6)
			Art.shape(ci, pts, col, 4.0, 0.12)
		"pigtails":
			for sx in [-1, 1]:
				Art.blob(ci, hc + Vector2(sx * (hr.x + 14), hr.y * 0.1), 18, 12, col, 3.5, 0.1, sx * 0.5)
		"ponytail":
			Art.blob(ci, hc + Vector2(-hr.x - 10, hr.y * 0.2), 14, 26, col, 3.5, 0.1, 0.4)
		"bun":
			Art.blob(ci, hc + Vector2(0, -hr.y - 6), 14, 12, col, 3.5)


## Hair on top of the head.
static func _hair_front(p: Puppet, c: Dictionary, hc: Vector2, hr: Vector2, head: PackedVector2Array) -> void:
	var ci := p.ci
	var col: Color = c.get("hair_col", Color("3a2416"))
	var kind: String = c.get("hair", "crew")
	var cap_y: float = c.get("hairline", -0.35)  # fraction of the head height
	var cap := func(y_frac: float) -> void:
		var band := PackedVector2Array([hc + Vector2(-hr.x * 2, -hr.y * 2), hc + Vector2(hr.x * 2, -hr.y * 2),
			hc + Vector2(hr.x * 2, hr.y * y_frac), hc + Vector2(-hr.x * 2, hr.y * y_frac)])
		for poly in Geometry2D.intersect_polygons(head, band):
			Art.fill(ci, poly, col)
		Art.outline(ci, head, 4.0)
	match kind:
		"crew", "bob", "long", "pigtails", "ponytail", "bun", "big_wave":
			cap.call(cap_y)
		"spiky":
			cap.call(cap_y)
			for i in 5:
				var x := lerpf(-hr.x * 0.7, hr.x * 0.7, i / 4.0)
				var base_y := hc.y - sqrt(maxf(hr.y * hr.y * (1.0 - x * x / (hr.x * hr.x)), 0.0)) + 4.0
				Art.shape(ci, PackedVector2Array([Vector2(x - 8, base_y), Vector2(x + 2, base_y - 18), Vector2(x + 9, base_y)]), col, 3.0)
		"slick":
			cap.call(cap_y)
			Art.stroke(ci, Art.curve(hc + Vector2(-hr.x * 0.7, -hr.y * 0.6), hc + Vector2(0, -hr.y * 0.9), hc + Vector2(hr.x * 0.8, -hr.y * 0.5), 8), 2.5, col.lightened(0.3))
		"fringe":
			# Bald on top, hair round the sides
			for sx in [-1, 1]:
				Art.blob(ci, hc + Vector2(sx * hr.x * 0.85, -hr.y * 0.15), 9, 15, col, 3.0)
		"curly", "wild":
			var n := 7 if kind == "curly" else 9
			for i in n:
				var a := PI + PI * (i + 0.5) / n
				var r := (hr.x * 0.95) if kind == "curly" else (hr.x * 1.1)
				var bump := hc + Vector2(cos(a) * r, sin(a) * hr.y * 0.95)
				var s := 13.0 if kind == "curly" else 16.0 + (i % 2) * 6.0
				Art.blob(ci, bump, s, s, col, 3.0)
		"tuft":
			# A few hairs sprouting from a bald-ish head
			for i in c.get("tuft_n", 3):
				var x: float = (i - (c.get("tuft_n", 3) - 1) / 2.0) * 6.0
				Art.stroke(ci, Art.curve(hc + Vector2(x, -hr.y + 2), hc + Vector2(x - 6, -hr.y - 14), hc + Vector2(x + 4, -hr.y - 22), 8), 3.0, col)
