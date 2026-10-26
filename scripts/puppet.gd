class_name Puppet
extends Node2D
## A cartoon actor drawn entirely with vector shapes. Origin is at the feet;
## local +x is the direction the character faces (the node is mirrored for left).

signal finished_move

const EMOTIONS := ["neutral", "happy", "sad", "angry", "surprised", "scared", "smug", "excited"]

var id := ""
var data: Dictionary = {}
var style := "sponge"
var facing := 1:
	set(v):
		facing = 1 if v >= 0 else -1
		scale.x = facing * size_scale
var size_scale := 1.0:
	set(v):
		size_scale = v
		scale = Vector2(facing * v, v)

var emotion := "neutral"
var talking := false
var walking := false
var held := ""

var _t := 0.0
var _talk_open := 0.0
var _talk_target := 0.0
var _talk_timer := 0.0
var _blink := 0.0
var _blink_timer := 2.0
var _walk_phase := 0.0
var _hop := 0.0
var _move_tween: Tween
var _emote_time := 0.0


func setup(char_id: String, char_data: Dictionary) -> void:
	id = char_id
	data = char_data
	style = String(char_data.get("style", "sponge"))
	_t = randf() * 10.0
	_blink_timer = randf_range(1.0, 3.0)


func set_emotion(e: String) -> void:
	e = e.to_lower().strip_edges()
	if e == "" or not EMOTIONS.has(e):
		e = "neutral"
	emotion = e
	_emote_time = 0.0
	if e in ["surprised", "excited", "scared"]:
		hop(22.0 if e != "scared" else 12.0)


func hop(height: float = 40.0, dur: float = 0.45) -> void:
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void: _hop = v, 0.0, 1.0, dur)
	tw.tween_callback(func() -> void: _hop = 0.0)
	set_meta("hop_h", height)


func walk_to(x: float, speed: float = 240.0) -> float:
	var dist := absf(x - position.x)
	if dist < 2.0:
		finished_move.emit()
		return 0.0
	facing = 1 if x > position.x else -1
	walking = true
	var dur := dist / speed
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "position:x", x, dur)
	_move_tween.tween_callback(func() -> void:
		walking = false
		finished_move.emit())
	return dur


func _process(delta: float) -> void:
	_t += delta
	_emote_time += delta
	# Blinking
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink = 1.0
		_blink_timer = randf_range(1.8, 4.5)
	_blink = maxf(0.0, _blink - delta * 7.0)
	# Lip flap
	if talking:
		_talk_timer -= delta
		if _talk_timer <= 0.0:
			_talk_target = 0.0 if _talk_target > 0.3 and randf() < 0.55 else randf_range(0.45, 1.0)
			_talk_timer = randf_range(0.06, 0.13)
	else:
		_talk_target = 0.0
	_talk_open = move_toward(_talk_open, _talk_target, delta * 9.0)
	if walking:
		_walk_phase += delta * 10.0
	else:
		_walk_phase = move_toward(_walk_phase, roundf(_walk_phase / PI) * PI, delta * 6.0)
	queue_redraw()


# ---------------------------------------------------------------- drawing --

func _draw() -> void:
	# Ground shadow (not affected by the hop)
	var w: float = data.get("width", 70.0)
	var hop_h: float = get_meta("hop_h", 40.0)
	var lift := sin(_hop * PI) * hop_h
	draw_colored_polygon(Art.ellipse(Vector2(0, 2), w * (1.0 - lift / 300.0), 12, 24), Color(0, 0, 0, 0.22))
	var bob := sin(_t * 2.4) * 1.6
	if walking:
		bob = -absf(sin(_walk_phase)) * 7.0
	var jitter := Vector2.ZERO
	if emotion == "scared":
		jitter = Vector2(randf_range(-1.5, 1.5), 0)
	var sq := 1.0 + sin(_t * 2.4) * 0.008
	if talking:
		sq += _talk_open * 0.012
	draw_set_transform(Vector2(0, bob - lift) + jitter, 0.0, Vector2(1.0 / sq, sq))
	match style:
		"sponge": _draw_sponge()
		"starfish": _draw_starfish()
		"squid": _draw_squid()
		"crab": _draw_crab()
		"squirrel": _draw_squirrel()
	draw_set_transform(Vector2.ZERO)


## Arm raise amounts for (back, front) arms, 0 = hanging, ~1.5 = horizontal.
func _arm_raise() -> Vector2:
	var back := 0.15 + sin(_t * 1.7) * 0.04
	var front := 0.15 + sin(_t * 1.9 + 1.0) * 0.04
	if walking:
		back = 0.25 + sin(_walk_phase) * 0.35
		front = 0.25 - sin(_walk_phase) * 0.35
	if talking:
		front += 0.35 + absf(sin(_t * 3.3)) * 0.5
	match emotion:
		"excited", "surprised":
			back = 2.4 + sin(_t * 9.0) * 0.2
			front = 2.4 + cos(_t * 9.0) * 0.2
		"angry":
			back = 0.9
			front = 0.9 + absf(sin(_t * 6.0)) * 0.4
		"sad":
			back = 0.05
			front = 0.05
		"scared":
			back = 1.9
			front = 1.9
	if held != "":
		front = 1.25
	return Vector2(back, front)


func _eye_params() -> Dictionary:
	var p := {"lid": 0.08, "tilt": 0.0, "scale": 1.0, "pupil": 1.0, "look": Vector2(0.25, 0)}
	match emotion:
		"happy", "excited":
			p.lid = 0.0
			p.scale = 1.05
		"sad":
			p.lid = 0.35
			p.tilt = -0.45
			p.look = Vector2(0.15, 0.35)
		"angry":
			p.lid = 0.4
			p.tilt = 0.6
		"surprised":
			p.lid = 0.0
			p.scale = 1.18
			p.pupil = 0.7
		"scared":
			p.lid = 0.0
			p.scale = 1.12
			p.pupil = 0.55
			p.look = Vector2(sin(_t * 7.0) * 0.4, 0)
		"smug":
			p.lid = 0.48
			p.tilt = 0.15
	return p


## side: -1 for the eye nearer x<0, +1 for x>0 (used to mirror the lid tilt).
func _eye(c: Vector2, rx: float, ry: float, iris_r: float, iris_col: Color, side: int, base_lid: float = 0.0,
		lid_col: Color = Color.WHITE, sclera: Color = Color.WHITE, lashes: int = 0) -> void:
	var p := _eye_params()
	rx *= p.scale
	ry *= p.scale
	var pts := Art.ellipse(c, rx, ry, 32)
	Art.fill(self, pts, sclera)
	var look: Vector2 = p.look
	var ic := c + Vector2(look.x * rx * 0.5, look.y * ry * 0.5)
	var pupil_r: float = (iris_r * 0.48 if iris_r > 0.0 else minf(rx, ry) * 0.36) * p.pupil
	if iris_r > 0.0 and iris_col.a > 0.0:
		Art.dot(self, ic, iris_r, iris_col)
		Art.outline(self, Art.ellipse(ic, iris_r, iris_r, 20), 2.0)
	var hl_r := iris_r if iris_r > 0.0 else pupil_r * 1.6
	Art.dot(self, ic, pupil_r, Art.INK)
	Art.dot(self, ic + Vector2(-hl_r * 0.3, -hl_r * 0.35), hl_r * 0.22, Color(1, 1, 1, 0.9))
	var lid := clampf(maxf(maxf(p.lid, base_lid), _blink), 0.0, 1.0)
	if lid > 0.01:
		var base_y := c.y - ry + lid * 2.0 * ry
		var tilt: float = p.tilt * ry
		# Inner corner is toward x = 0.
		var y_inner := base_y + tilt
		var y_outer := base_y - tilt * 0.5
		var yl := y_outer if side < 0 else y_inner
		var yr := y_inner if side < 0 else y_outer
		var cover := PackedVector2Array([c + Vector2(-rx - 4, -ry - 6), c + Vector2(rx + 4, -ry - 6),
			Vector2(c.x + rx + 4, yr), Vector2(c.x - rx - 4, yl)])
		for poly in Geometry2D.intersect_polygons(pts, cover):
			Art.fill(self, poly, lid_col)
		var edge := Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([Vector2(c.x - rx - 4, yl), Vector2(c.x + rx + 4, yr)]), pts)
		for e in edge:
			Art.stroke(self, e, 3.0)
	Art.outline(self, pts, 3.0)
	if lashes > 0 and lid < 0.6:
		for i in lashes:
			var a := -PI / 2 + (float(i) - (lashes - 1) / 2.0) * 0.45 + side * 0.15
			var s := c + Vector2(cos(a) * rx, sin(a) * ry)
			Art.stroke(self, PackedVector2Array([s, s + Vector2(cos(a), sin(a)) * 9.0]), 3.0)


func _brow(c: Vector2, half_w: float, side: int, thick: float = 4.0, color: Color = Art.INK) -> void:
	var tilt := 0.0
	var lift := 0.0
	match emotion:
		"angry": tilt = 0.5
		"sad": tilt = -0.45
		"surprised", "scared": lift = -8.0
		"smug": tilt = 0.2
	var inner := c + Vector2(-side * half_w, lift + tilt * half_w)
	var outer := c + Vector2(side * half_w, lift - tilt * half_w * 0.4)
	var mid := (inner + outer) * 0.5 + Vector2(0, -4)
	Art.limb(self, Art.curve(inner, mid, outer, 8), thick, color, 0.0)


func _mouth_kind() -> String:
	match emotion:
		"happy", "excited": return "grin"
		"sad": return "frown"
		"angry": return "grit"
		"surprised": return "o"
		"scared": return "wobble"
		"smug": return "smirk"
	return "smile"


## Draws a mouth centered on c. teeth: 0 none, 1 buck teeth, 2 a row of teeth.
func _mouth(c: Vector2, w: float, teeth: int = 0, inside: Color = Color(0.36, 0.04, 0.1)) -> void:
	var kind := _mouth_kind()
	var hw := w * 0.5
	var open := _talk_open
	if kind == "grin":
		open = maxf(open, 0.45)
	elif kind == "o":
		open = maxf(open, 0.55)
	if open > 0.06:
		var corner := 0.0
		match kind:
			"grin", "smile", "smirk": corner = -w * 0.08
			"frown", "wobble": corner = w * 0.08
		var depth := w * 0.55 * open
		var top_mid := Vector2(0, -w * 0.02 if kind != "frown" else -w * 0.08)
		var pts := PackedVector2Array()
		var l := c + Vector2(-hw * (0.7 if kind == "o" else 1.0), corner)
		var r := c + Vector2(hw * (0.7 if kind == "o" else 1.0), corner)
		pts.append_array(Art.curve(l, c + top_mid, r, 12))
		var bot := Art.curve(r, c + Vector2(0, depth + corner * 0.5), l, 14)
		bot.remove_at(0)
		bot.remove_at(bot.size() - 1)
		pts.append_array(bot)
		Art.fill(self, pts, inside)
		# Tongue
		var tongue := Art.ellipse(c + Vector2(0, depth * 0.78), hw * 0.5, depth * 0.3, 20)
		for poly in Geometry2D.intersect_polygons(tongue, pts):
			Art.fill(self, poly, Color(0.93, 0.42, 0.5))
		if teeth == 1:
			for sx in [-1, 1]:
				var tr := Rect2(c + Vector2(sx * 1.5 - (w * 0.13 if sx < 0 else 0.0), top_mid.y - 1), Vector2(w * 0.13, w * 0.15))
				var tp := Art.rrect(tr, 2)
				for poly in Geometry2D.intersect_polygons(tp, pts):
					Art.fill(self, poly, Color.WHITE)
				Art.outline(self, tp, 2.0)
		elif teeth == 2:
			var band := PackedVector2Array([c + Vector2(-hw - 4, top_mid.y - 8), c + Vector2(hw + 4, top_mid.y - 8),
				c + Vector2(hw + 4, top_mid.y + w * 0.1), c + Vector2(-hw - 4, top_mid.y + w * 0.1)])
			for poly in Geometry2D.intersect_polygons(band, pts):
				Art.fill(self, poly, Color.WHITE)
				Art.outline(self, poly, 1.5)
		Art.outline(self, pts, 3.0)
		return
	match kind:
		"smile", "grin":
			Art.stroke(self, Art.curve(c + Vector2(-hw, -w * 0.1), c + Vector2(0, w * 0.22), c + Vector2(hw, -w * 0.1)), 3.5)
			for sx in [-1, 1]:
				var e := c + Vector2(sx * hw, -w * 0.1)
				Art.stroke(self, PackedVector2Array([e + Vector2(-sx * 4, -5), e + Vector2(sx * 4, 4)]), 3.0)
		"frown":
			Art.stroke(self, Art.curve(c + Vector2(-hw * 0.8, w * 0.1), c + Vector2(0, -w * 0.12), c + Vector2(hw * 0.8, w * 0.1)), 3.5)
		"smirk":
			Art.stroke(self, Art.curve(c + Vector2(-hw * 0.7, 0), c + Vector2(hw * 0.1, w * 0.08), c + Vector2(hw, -w * 0.15)), 3.5)
		"wobble":
			var pts := PackedVector2Array()
			for i in 9:
				pts.append(c + Vector2(lerpf(-hw * 0.8, hw * 0.8, i / 8.0), (3.0 if i % 2 == 0 else -3.0) + sin(_t * 20.0) * 1.5))
			Art.stroke(self, pts, 3.0)
		"grit":
			var r := Rect2(c + Vector2(-hw * 0.75, -w * 0.08), Vector2(hw * 1.5, w * 0.18))
			var rp := Art.rrect(r, 4)
			Art.fill(self, rp, Color.WHITE)
			Art.stroke(self, PackedVector2Array([Vector2(r.position.x, r.get_center().y), Vector2(r.end.x, r.get_center().y)]), 2.0)
			for i in range(1, 5):
				var x := lerpf(r.position.x, r.end.x, i / 5.0)
				Art.stroke(self, PackedVector2Array([Vector2(x, r.position.y), Vector2(x, r.end.y)]), 2.0)
			Art.outline(self, rp, 3.0)
	if teeth == 1 and kind in ["smile", "grin", "smirk"]:
		for sx in [-1, 1]:
			var tr := Rect2(c + Vector2(sx * 1.5 - (w * 0.12 if sx < 0 else 0.0), w * 0.1), Vector2(w * 0.12, w * 0.14))
			var tp := Art.rrect(tr, 2)
			Art.fill(self, tp, Color.WHITE)
			Art.outline(self, tp, 2.0)


## Returns the hand position. raise: 0 hanging down, PI/2 horizontal, PI straight up.
func _arm(shoulder: Vector2, side: int, raise: float, length: float, width: float, color: Color,
		hand_r: float, hand_col: Color, sleeve_col: Color = Color(0, 0, 0, 0), sleeve_r: float = 0.0) -> Vector2:
	var a := 0.22 + raise
	var dir := Vector2(side * sin(a), cos(a))
	var elbow := shoulder + dir * length * 0.5 + Vector2(side * 5.0, -2.0).rotated(-side * raise * 0.3)
	var hand := shoulder + dir * length
	Art.limb(self, Art.curve(shoulder, elbow, hand, 10), width, color)
	if sleeve_r > 0.0:
		Art.blob(self, shoulder + dir * sleeve_r * 0.4, sleeve_r, sleeve_r * 0.85, sleeve_col, 3.0, 0.0, a * side)
	Art.blob(self, hand, hand_r, hand_r, hand_col, 3.0)
	if side > 0 and held != "":
		var up := Vector2(-dir.y, dir.x)
		if up.y > 0.0:
			up = -up
		_draw_prop(hand, up)
	return hand


## Draws the held prop at `hand`, pointing along `up`.
func _draw_prop(hand: Vector2, up: Vector2) -> void:
	var ang := up.angle() + PI / 2
	var xf := Transform2D(ang, hand)
	match held:
		"spatula", "golden_spatula":
			var gold := Color(1.0, 0.82, 0.2)
			Art.limb(self, PackedVector2Array([xf * Vector2(0, 10), xf * Vector2(0, -36)]), 7, Color(0.55, 0.32, 0.15))
			var head := PackedVector2Array()
			for p in Art.rrect(Rect2(-14, -70, 28, 36), 5):
				head.append(xf * p)
			Art.shape(self, head, gold, 3.0)
			for i in 3:
				var x := -7.0 + i * 7.0
				Art.stroke(self, PackedVector2Array([xf * Vector2(x, -64), xf * Vector2(x, -42)]), 2.5, gold.darkened(0.4))
			var sp := xf * Vector2(18, -72)
			var s := 5.0 + sin(_t * 8.0) * 2.0
			Art.stroke(self, PackedVector2Array([sp + Vector2(-s, 0), sp + Vector2(s, 0)]), 2.5, Color.WHITE)
			Art.stroke(self, PackedVector2Array([sp + Vector2(0, -s), sp + Vector2(0, s)]), 2.5, Color.WHITE)
		"clarinet":
			Art.limb(self, PackedVector2Array([xf * Vector2(0, 30), xf * Vector2(0, -50)]), 9, Color(0.12, 0.12, 0.14))
			var bell := PackedVector2Array()
			for p in [Vector2(-5, 26), Vector2(5, 26), Vector2(12, 44), Vector2(-12, 44)]:
				bell.append(xf * p)
			Art.shape(self, bell, Color(0.15, 0.15, 0.17), 3.0)
			for i in 4:
				Art.dot(self, xf * Vector2(0, -35 + i * 14), 2.5, Color(0.85, 0.85, 0.9))
		"detector":
			var box := PackedVector2Array()
			for p in Art.rrect(Rect2(-20, -40, 40, 34), 6):
				box.append(xf * p)
			Art.shape(self, box, Color(0.7, 0.72, 0.75), 3.0, 0.2)
			Art.stroke(self, PackedVector2Array([xf * Vector2(10, -40), xf * Vector2(18, -72)]), 3.0)
			var blink_on := fmod(_t * 3.0, 1.0) < 0.5
			Art.dot(self, xf * Vector2(18, -74), 6, Color(1, 0.15, 0.1) if blink_on else Color(0.45, 0.05, 0.05))
			Art.dot(self, xf * Vector2(-6, -24), 7, Color(0.2, 0.9, 0.4))
		"net":
			Art.limb(self, PackedVector2Array([xf * Vector2(0, 20), xf * Vector2(0, -80)]), 5, Color(0.6, 0.42, 0.22))
			var ring := Art.ellipse(xf * Vector2(0, -105), 24, 24, 24)
			Art.fill(self, ring, Color(1, 1, 1, 0.35))
			for i in 5:
				var x := -18.0 + i * 9.0
				Art.stroke(self, PackedVector2Array([xf * Vector2(x, -122), xf * Vector2(x, -88)]), 1.5, Color(1, 1, 1, 0.8))
			Art.outline(self, ring, 4.0, Color(0.6, 0.42, 0.22))
		"patty":
			var c := xf * Vector2(0, -20)
			Art.blob(self, c + Vector2(0, -6), 26, 12, Color(0.95, 0.72, 0.35), 3.0, 0.15)
			Art.blob(self, c + Vector2(0, 4), 27, 6, Color(0.45, 0.25, 0.12), 3.0)
			Art.blob(self, c + Vector2(0, 0), 28, 3, Color(0.4, 0.8, 0.3), 2.0)
			Art.blob(self, c + Vector2(0, 11), 25, 7, Color(0.95, 0.72, 0.35), 3.0)
		"money":
			var bill := PackedVector2Array()
			for p in Art.rrect(Rect2(-24, -36, 48, 26), 3):
				bill.append(xf * p)
			Art.shape(self, bill, Color(0.55, 0.85, 0.5), 3.0)
			Art.text(self, ThemeDB.fallback_font, xf * Vector2(-6, -16), "$", 18, Color(0.15, 0.45, 0.15), 0, HORIZONTAL_ALIGNMENT_LEFT)


func _leg_swing(side: int) -> float:
	return sin(_walk_phase + (0.0 if side > 0 else PI)) * 12.0


# ------------------------------------------------------------- characters --

func _draw_sponge() -> void:
	var yel := Color("f6df4c")
	var brown := Color("8a5a2b")
	var raise := _arm_raise()
	# Back arm
	_arm(Vector2(-64, -112), -1, raise.x, 58, 6, yel, 8, yel, Color.WHITE, 13)
	# Legs, socks and shoes
	for side in [-1, 1]:
		var sw := _leg_swing(side)
		var hip := Vector2(side * 24, -60)
		var foot := Vector2(side * 24 + sw, -12 - maxf(0.0, -cos(_walk_phase + (0.0 if side > 0 else PI))) * 6.0 * float(walking))
		Art.limb(self, PackedVector2Array([hip, foot]), 7, yel)
		var sock_top := hip.lerp(foot, 0.45)
		Art.limb(self, PackedVector2Array([sock_top, foot]), 12, Color.WHITE)
		for i in 2:
			var s := sock_top.lerp(foot, 0.15 + i * 0.22)
			Art.stroke(self, PackedVector2Array([s + Vector2(-6, 0), s + Vector2(6, 0)]), 3.0, Color("d8352a") if i == 0 else Color("2f6fcf"))
		Art.blob(self, foot + Vector2(8, 4), 19, 10, Art.INK, 2.0)
		Art.dot(self, foot + Vector2(14, 0), 3.5, Color(1, 1, 1, 0.7))
	# Shorts
	for side in [-1, 1]:
		Art.shape(self, Art.rrect(Rect2(side * 24 - 13, -66, 26, 14), 3), brown, 3.0)
	Art.shape(self, Art.rrect(Rect2(-64, -96, 128, 36), 4), brown, 3.5, 0.15)
	Art.stroke(self, PackedVector2Array([Vector2(-62, -86), Vector2(62, -86)]), 4.0)
	for i in 6:
		var x := -50.0 + i * 20.0
		Art.stroke(self, PackedVector2Array([Vector2(x, -86), Vector2(x + 8, -86)]), 3.0, Color(0.9, 0.9, 0.9))
	# Shirt and tie
	Art.shape(self, PackedVector2Array([Vector2(-66, -110), Vector2(66, -110), Vector2(64, -95), Vector2(-64, -95)]), Color.WHITE, 3.5)
	Art.shape(self, PackedVector2Array([Vector2(0, -108), Vector2(9, -99), Vector2(0, -74), Vector2(-9, -99)]), Color("d8352a"), 3.0)
	# Body
	var body := PackedVector2Array()
	var steps := 14
	for i in steps:
		var x := lerpf(-72, 72, float(i) / steps)
		body.append(Vector2(x, -250 + sin(x * 0.11 + 0.6) * 4.0))
	for i in steps:
		var y := lerpf(-250, -108, float(i) / steps)
		body.append(Vector2(72 + sin(y * 0.13) * 3.5, y))
	for i in steps:
		var x := lerpf(72, -72, float(i) / steps)
		body.append(Vector2(x, -108 + sin(x * 0.09) * 2.0))
	for i in steps:
		var y := lerpf(-108, -250, float(i) / steps)
		body.append(Vector2(-72 + sin(y * 0.12 + 1.0) * 3.5, y))
	Art.shape(self, body, yel, 4.5, 0.12, Vector2(-12, -10))
	var hole := Color("bfae32")
	for h in [[-50, -230, 8, 10], [44, -228, 10, 7], [54, -150, 7, 10], [-56, -135, 9, 8], [32, -122, 6, 6],
			[-24, -122, 5, 6], [2, -240, 5, 4], [-60, -185, 5, 7], [60, -195, 6, 5]]:
		draw_colored_polygon(Art.ellipse(Vector2(h[0], h[1]), h[2], h[3], 16), hole)
	# Face
	_eye(Vector2(-25, -196), 24, 27, 11, Color("3d8fe0"), -1, 0.0, yel, Color.WHITE, 3)
	_eye(Vector2(25, -196), 24, 27, 11, Color("3d8fe0"), 1, 0.0, yel, Color.WHITE, 3)
	Art.limb(self, Art.curve(Vector2(2, -176), Vector2(12, -180), Vector2(22, -174), 6), 9, yel)
	for side in [-1, 1]:
		var ch := Vector2(side * 46, -160)
		Art.dot(self, ch, 11, Color(0.97, 0.55, 0.45, 0.9))
		for f in [Vector2(-4, -2), Vector2(3, -4), Vector2(1, 4)]:
			Art.dot(self, ch + f, 1.6, Color(0.6, 0.25, 0.15))
	_mouth(Vector2(0, -150), 74, 1)
	# Front arm
	_arm(Vector2(64, -112), 1, raise.y, 58, 6, yel, 8, yel, Color.WHITE, 13)


func _draw_starfish() -> void:
	var pink := Color("f7a1b4")
	var raise := _arm_raise()
	var lw := _leg_swing(-1)
	var rw := _leg_swing(1)
	var ar := -raise.y * 40.0 + 40.0 * 0.15
	var al := -raise.x * 40.0 + 40.0 * 0.15
	var ctrl := PackedVector2Array([
		Vector2(0, -252), Vector2(30, -190), Vector2(104, -168 + ar), Vector2(48, -128),
		Vector2(62 + rw, -6), Vector2(0, -60), Vector2(-62 + lw, -6), Vector2(-48, -128),
		Vector2(-104, -168 + al), Vector2(-30, -190)])
	var star := Art.smooth(ctrl, 7)
	Art.shape(self, star, pink, 4.5, 0.12, Vector2(-14, -10))
	# Spots
	for s in [Vector2(-20, -225), Vector2(14, -140), Vector2(-70, -160), Vector2(78, -165), Vector2(-28, -120)]:
		Art.dot(self, s, 2.5, pink.darkened(0.25))
	# Shorts clipped to the star
	var band := PackedVector2Array([Vector2(-140, -108), Vector2(140, -108), Vector2(140, -36), Vector2(-140, -36)])
	var green := Color("8fcf4c")
	for poly in Geometry2D.intersect_polygons(star, band):
		Art.shape(self, poly, green, 3.5, 0.12)
		for fp in [Vector2(-30, -92), Vector2(8, -80), Vector2(34, -96), Vector2(-46, -58), Vector2(46, -54), Vector2(-12, -100)]:
			if Geometry2D.is_point_in_polygon(fp, poly):
				for k in 4:
					Art.dot(self, fp + Vector2(5, 0).rotated(k * PI / 2), 3.5, Color("9c5fd6"))
				Art.dot(self, fp, 2.5, Color("f5d63b"))
	# Face
	_eye(Vector2(-14, -200), 12, 17, 0, Color(0, 0, 0, 0), -1, 0.0, pink)
	_eye(Vector2(14, -200), 12, 17, 0, Color(0, 0, 0, 0), 1, 0.0, pink)
	_brow(Vector2(-15, -224), 12, -1, 5.0)
	_brow(Vector2(15, -224), 12, 1, 5.0)
	_mouth(Vector2(0, -166), 58, 0)
	Art.stroke(self, Art.curve(Vector2(-4, -116), Vector2(0, -112), Vector2(4, -116), 4), 2.5)
	# Held prop in the right arm tip
	if held != "":
		_draw_prop(Vector2(96, -164 + ar), Vector2(0.25, -1.0).normalized())


func _draw_squid() -> void:
	var skin := Color("a4d4c8")
	var shirt := Color("a26838")
	var raise := _arm_raise()
	_arm(Vector2(-33, -118), -1, raise.x, 64, 7, skin, 7, skin)
	# Tentacle legs
	for i in 4:
		var x := -24.0 + i * 16.0
		var sw := sin(_walk_phase + i * PI * 0.5) * 9.0 if walking else 0.0
		var top := Vector2(x, -62)
		var foot := Vector2(x * 1.7 + sw, -8)
		var tip := foot + Vector2(10.0 if x > 0 else -10.0, 0)
		Art.limb(self, Art.curve(top, Vector2(x * 1.2 - 6, -34), foot, 10) + PackedVector2Array([tip]), 12, skin)
	# Shirt
	var torso := Art.smooth(PackedVector2Array([Vector2(-30, -128), Vector2(30, -128), Vector2(42, -60), Vector2(0, -54), Vector2(-42, -60)]), 4)
	Art.shape(self, torso, shirt, 4.0, 0.15)
	Art.stroke(self, PackedVector2Array([Vector2(-8, -126), Vector2(0, -112), Vector2(8, -126)]), 3.0)
	# Head
	var head := Art.smooth(PackedVector2Array([Vector2(-15, -128), Vector2(-48, -168), Vector2(-57, -222), Vector2(-36, -268),
		Vector2(0, -280), Vector2(36, -268), Vector2(57, -222), Vector2(48, -168), Vector2(15, -128)]), 6)
	Art.shape(self, head, skin, 4.5, 0.14, Vector2(-12, -10))
	Art.stroke(self, Art.curve(Vector2(-30, -255), Vector2(-40, -240), Vector2(-42, -225), 6), 2.0, skin.darkened(0.3))
	# Eyes (droopy, bored)
	_eye(Vector2(-20, -212), 18, 15, 5, Color("b3202a"), -1, 0.45, skin, Color("f6f0c2"))
	_eye(Vector2(20, -212), 18, 15, 5, Color("b3202a"), 1, 0.45, skin, Color("f6f0c2"))
	_mouth(Vector2(4, -150), 30, 0)
	# Nose
	var droop := sin(_t * 1.3) * 2.0
	var nose := Art.smooth(PackedVector2Array([Vector2(-6, -206), Vector2(8, -206), Vector2(18, -178 + droop),
		Vector2(12, -156 + droop), Vector2(0, -158 + droop), Vector2(-4, -180)]), 5)
	Art.shape(self, nose, skin, 4.0, 0.15)
	_arm(Vector2(33, -118), 1, raise.y, 64, 7, skin, 7, skin)


func _draw_crab() -> void:
	var red := Color("e6452f")
	var raise := _arm_raise()
	# Legs
	for side in [-1, 1]:
		var sw := _leg_swing(side)
		Art.limb(self, PackedVector2Array([Vector2(side * 26, -50), Vector2(side * 30 + sw, -4)]), 11, red)
		Art.shape(self, PackedVector2Array([Vector2(side * 30 + sw - 6, -6), Vector2(side * 30 + sw + 6, -6), Vector2(side * 30 + sw + side * 3, 4)]), red, 2.5)
	# Back claw
	_claw(Vector2(-72, -112), -1, raise.x, red)
	# Eye stalks
	var sway := sin(_t * 1.8) * 3.0
	for side in [-1, 1]:
		Art.limb(self, Art.curve(Vector2(side * 16, -176), Vector2(side * 18, -205), Vector2(side * 24 + sway, -232), 8), 8, red)
	# Body
	var body := Art.smooth(PackedVector2Array([Vector2(-82, -100), Vector2(-70, -152), Vector2(-36, -182), Vector2(0, -188),
		Vector2(36, -182), Vector2(70, -152), Vector2(82, -100), Vector2(66, -56), Vector2(0, -42), Vector2(-66, -56)]), 6)
	Art.shape(self, body, red, 4.5, 0.12, Vector2(-14, -10))
	var shirt_band := PackedVector2Array([Vector2(-120, -104), Vector2(-40, -104), Vector2(0, -88), Vector2(40, -104), Vector2(120, -104), Vector2(120, 0), Vector2(-120, 0)])
	for poly in Geometry2D.intersect_polygons(body, shirt_band):
		Art.shape(self, poly, Color("74b9e8"), 3.5, 0.1)
	var belt := PackedVector2Array([Vector2(-120, -70), Vector2(120, -70), Vector2(120, -58), Vector2(-120, -58)])
	for poly in Geometry2D.intersect_polygons(body, belt):
		Art.shape(self, poly, Color("4a3020"), 3.0)
	Art.shape(self, Art.rrect(Rect2(-10, -72, 20, 16), 3), Color("e8c040"), 3.0)
	# Eyes on stalks
	for side in [-1, 1]:
		var ec := Vector2(side * 24 + sway, -240)
		_eye(ec, 15, 15, 0, Color(0, 0, 0, 0), side, 0.0, red)
		_brow(ec + Vector2(0, -20), 12, side, 6.0)
	_mouth(Vector2(0, -142), 80, 2)
	_claw(Vector2(72, -112), 1, raise.y, red)


func _claw(shoulder: Vector2, side: int, raise: float, red: Color) -> void:
	var a := -0.35 - raise * 0.6
	var dir := Vector2(side * cos(a), sin(a))
	var wrist := shoulder + dir * 46.0 + Vector2(0, 10)
	Art.limb(self, Art.curve(shoulder, shoulder + dir * 22 + Vector2(0, 14), wrist, 8), 12, red)
	var snap := 0.25 + (_talk_open * 0.6 if talking else 0.0) + (absf(sin(_t * 8.0)) * 0.5 if emotion == "angry" else 0.0)
	var base_ang := dir.angle()
	var xf := Transform2D(base_ang, Vector2(1, side), 0.0, wrist)
	var upper := PackedVector2Array()
	for p in Art.smooth(PackedVector2Array([Vector2(0, -4), Vector2(18, -22), Vector2(46, -20), Vector2(56, -6), Vector2(28, -4)]), 5):
		upper.append(xf * p.rotated(-snap))
	var lower := PackedVector2Array()
	for p in Art.smooth(PackedVector2Array([Vector2(0, 4), Vector2(18, 18), Vector2(42, 14), Vector2(26, 4)]), 5):
		lower.append(xf * p.rotated(snap * 0.6))
	Art.shape(self, lower, red.darkened(0.08), 3.5)
	Art.shape(self, upper, red, 3.5, 0.1)
	Art.blob(self, wrist, 13, 13, red, 3.5)
	if side > 0 and held != "":
		_draw_prop(wrist + dir * 20.0, Vector2(0.2, -1.0).normalized())


func _draw_squirrel() -> void:
	var suit := Color("f2f2ee")
	var fur := Color("b26b3c")
	var muzzle := Color("ecd0a6")
	var raise := _arm_raise()
	# Tail (in its suit sleeve)
	var wag := sin(_t * 2.0) * 6.0
	var tail := Art.smooth(PackedVector2Array([Vector2(-40, -76), Vector2(-92, -96), Vector2(-112 + wag, -170), Vector2(-86 + wag, -222),
		Vector2(-58 + wag, -206), Vector2(-66, -150), Vector2(-46, -112)]), 6)
	Art.shape(self, tail, suit, 4.0, 0.12)
	_arm(Vector2(-46, -148), -1, raise.x, 62, 20, suit, 13, suit)
	# Legs and boots
	for side in [-1, 1]:
		var sw := _leg_swing(side)
		Art.limb(self, PackedVector2Array([Vector2(side * 22, -72), Vector2(side * 22 + sw, -18)]), 26, suit)
		Art.blob(self, Vector2(side * 22 + sw + 6, -8), 20, 11, Color("9aa3ad"), 3.0, 0.15)
	# Torso
	Art.shape(self, Art.rrect(Rect2(-50, -166, 100, 104), 30), suit, 4.0, 0.12)
	# Acorn badge
	Art.blob(self, Vector2(22, -118), 8, 9, Color("8a5530"), 2.5)
	Art.shape(self, Art.rrect(Rect2(13, -132, 18, 8), 3), Color("5c8a2f"), 2.5)
	Art.stroke(self, PackedVector2Array([Vector2(-34, -82), Vector2(34, -82)]), 3.0, Color(0.7, 0.7, 0.72))
	# Collar ring
	Art.shape(self, Art.rrect(Rect2(-46, -176, 92, 16), 7), Color("b9c1c9"), 3.5)
	# Head
	var hc := Vector2(0, -218)
	for side in [-1, 1]:
		Art.blob(self, hc + Vector2(side * 28, -30), 11, 14, fur, 3.0, 0.0, side * 0.3)
		Art.dot(self, hc + Vector2(side * 28, -29), 5, muzzle)
	Art.blob(self, hc, 42, 37, fur, 4.0, 0.12)
	Art.blob(self, hc + Vector2(0, 14), 30, 19, muzzle, 0.0)
	_eye(hc + Vector2(-15, -8), 11, 14, 6, Color("3a2416"), -1, 0.0, fur, Color.WHITE, 2)
	_eye(hc + Vector2(15, -8), 11, 14, 6, Color("3a2416"), 1, 0.0, fur, Color.WHITE, 2)
	Art.blob(self, hc + Vector2(0, 7), 5, 4, Color("3a2416"), 0.0)
	_mouth(hc + Vector2(0, 18), 30, 1)
	# Glass helmet
	var glass := Art.ellipse(hc + Vector2(0, -4), 66, 64, 48)
	Art.fill(self, glass, Color(0.75, 0.92, 1.0, 0.28))
	draw_arc(hc + Vector2(-4, -8), 52, PI * 1.05, PI * 1.45, 12, Color(1, 1, 1, 0.85), 6.0, true)
	draw_arc(hc + Vector2(-4, -8), 52, PI * 1.55, PI * 1.62, 4, Color(1, 1, 1, 0.85), 6.0, true)
	Art.outline(self, glass, 4.0, Color("4d5966"))
	# Flower on top
	var fc := hc + Vector2(0, -98)
	Art.stroke(self, PackedVector2Array([hc + Vector2(0, -68), fc]), 4.0, Color("3f8f3a"))
	for k in 5:
		Art.blob(self, fc + Vector2(0, -11).rotated(k * TAU / 5 + sin(_t) * 0.2), 9, 9, Color("c56bd8"), 2.5)
	Art.blob(self, fc, 6, 6, Color("f5d63b"), 2.5)
	_arm(Vector2(46, -148), 1, raise.y, 62, 20, suit, 13, suit)
