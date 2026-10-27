class_name Puppet
extends Node2D
## A cartoon actor drawn entirely with vector shapes. Origin is at the feet;
## local +x is the direction the character faces (the node is mirrored for left).
##
## The body is drawn by a "rig" into the puppet's own offscreen texture, which is
## re-rendered only while something in the drawing changes (at most DRAW_FPS, like
## hand-drawn Flash animation "on twos"). On screen each puppet is one textured quad,
## moved every frame for the smooth bob/hop/squash. Rendering the ~150 vector shapes
## every frame instead is far too slow in the browser.

signal finished_move

const EMOTIONS := ["neutral", "happy", "sad", "angry", "surprised", "scared", "smug", "excited", "nervous", "shy"]
const DRAW_FPS := 15.0
## Area (in puppet space, feet at 0,0) captured into the texture, and its resolution.
const BOUNDS := Rect2(-200, -365, 400, 400)
const BAKE_SCALE := 2.0

static var _shadow_tex: GradientTexture2D
static var _portraits := {}  # character id -> ImageTexture
static var _portraits_busy := 0

var id := ""
var data: Dictionary = {}
var style := "sponge"
var facing := 1:
	set(v):
		var f := 1 if v >= 0 else -1
		if f != facing:
			facing = f
			_redraw_now()  # writing on clothes is drawn un-mirrored
		scale.x = facing * size_scale
var size_scale := 1.0:
	set(v):
		size_scale = v
		scale = Vector2(facing * v, v)

var emotion := "neutral"
var talking := false
var walking := false
var held := "":
	set(v):
		held = v
		_redraw_now()
## The CanvasItem the drawing helpers currently draw into (the rig).
var ci: CanvasItem

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
var _rig: _Rig
var _vp: SubViewport
var _display: _Display
var _redraw_t := 0.0
var _lift := 0.0
var _was_animating := true


class _Rig:
	extends Node2D
	var puppet: Puppet

	func _draw() -> void:
		puppet.ci = self
		draw_set_transform(-BOUNDS.position * BAKE_SCALE, 0.0, Vector2.ONE * BAKE_SCALE)
		Art.antialias = false
		puppet._draw_body()
		Art.antialias = true


class _Display:
	extends Node2D
	var tex: Texture2D

	func _draw() -> void:
		draw_texture_rect(tex, BOUNDS, false)


func _init() -> void:
	_vp = SubViewport.new()
	_vp.size = Vector2i(BOUNDS.size * BAKE_SCALE)
	_vp.disable_3d = true
	_vp.transparent_bg = true
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	_rig = _Rig.new()
	_rig.puppet = self
	_vp.add_child(_rig)
	add_child(_vp)
	_display = _Display.new()
	_display.tex = _vp.get_texture()
	# The offscreen render holds premultiplied colour; blend it as such so
	# translucent parts (Sandy's helmet) don't come out dark.
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	_display.material = mat
	add_child(_display)
	_redraw_t = randf() / DRAW_FPS  # stagger redraws between puppets
	if _shadow_tex == null:
		_shadow_tex = GradientTexture2D.new()
		_shadow_tex.fill = GradientTexture2D.FILL_RADIAL
		_shadow_tex.fill_from = Vector2(0.5, 0.5)
		_shadow_tex.fill_to = Vector2(1.0, 0.5)
		_shadow_tex.width = 64
		_shadow_tex.height = 64
		var g := Gradient.new()
		g.set_color(0, Color(0, 0, 0, 0.24))
		g.set_color(1, Color(0, 0, 0, 0))
		g.add_point(0.8, Color(0, 0, 0, 0.2))
		_shadow_tex.gradient = g


## Renders a small full-body picture of a character (cached). `host` is any node
## in the tree to attach the temporary puppet to. The picture holds premultiplied
## colour, like the puppet's own texture.
static func make_portrait(host: Node, char_id: String) -> Texture2D:
	while _portraits_busy >= 4:
		await RenderingServer.frame_post_draw
		if not is_instance_valid(host):
			return null
	if _portraits.has(char_id):
		return _portraits[char_id]
	_portraits_busy += 1
	var p := Puppet.new()
	p.visible = false
	p.setup(char_id, Game.characters.get(char_id, {}))
	p._blink_timer = 10.0
	host.add_child(p)
	p.set_process(false)
	p._redraw_now()
	await RenderingServer.frame_post_draw
	_portraits_busy -= 1
	if not is_instance_valid(p):
		return null
	var img := p._vp.get_texture().get_image()
	p.queue_free()
	# Trim the empty margins of the capture area, then shrink.
	var k := BAKE_SCALE
	img = img.get_region(Rect2i(int(40 * k), int(5 * k), int(320 * k), int(390 * k)))
	img.resize(160, 195, Image.INTERPOLATE_BILINEAR)
	var tex := ImageTexture.create_from_image(img)
	_portraits[char_id] = tex
	return tex


func _redraw_now() -> void:
	if _rig:
		_rig.queue_redraw()
		_vp.render_target_update_mode = SubViewport.UPDATE_ONCE


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
	_redraw_now()
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
	# Smooth per-frame body motion via the rig transform.
	var hop_h: float = get_meta("hop_h", 40.0)
	var lift := sin(_hop * PI) * hop_h
	var bob := sin(_t * 2.4) * 1.6
	if walking:
		bob = -absf(sin(_walk_phase)) * 7.0
	var jitter := randf_range(-1.5, 1.5) if emotion == "scared" else (randf_range(-0.6, 0.6) if emotion == "nervous" else 0.0)
	var sq := 1.0 + sin(_t * 2.4) * 0.008 + (_talk_open * 0.012 if talking else 0.0)
	_display.position = Vector2(jitter, bob - lift)
	_display.scale = Vector2(1.0 / sq, sq)
	if absf(lift - _lift) > 0.01:
		_lift = lift
		queue_redraw()
	# Throttled redraw of the actual drawing, and only while something in it moves.
	# (Every redraw re-uploads all the shapes to the GPU, which is slow on the web.)
	var animating := _is_animating()
	_redraw_t -= delta
	if _redraw_t <= 0.0:
		_redraw_t = fmod(_redraw_t, 1.0 / DRAW_FPS) + 1.0 / DRAW_FPS
		if animating or _was_animating:
			_redraw_now()
		_was_animating = animating


func _is_animating() -> bool:
	return talking or walking or _talk_open > 0.01 or _blink > 0.0 or absf(sin(_walk_phase)) > 0.01 \
		or emotion in ["excited", "surprised", "angry", "nervous"] or held in ["golden_spatula", "detector"]


# ---------------------------------------------------------------- drawing --

func _draw() -> void:
	# Ground shadow (shrinks during a hop)
	var w: float = data.get("width", 70.0) * (1.0 - _lift / 300.0) * 1.15
	draw_texture_rect(_shadow_tex, Rect2(-w, -13, w * 2.0, 28), false)


func _draw_body() -> void:
	match style:
		"sponge": _draw_sponge()
		"starfish": _draw_starfish()
		"squid": _draw_squid()
		"crab": _draw_crab()
		"squirrel": _draw_squirrel()
		"arnold": _draw_arnold()
		"helga": _draw_helga()
		"gerald": _draw_gerald()
		"grandpa": _draw_grandpa()
		"phoebe": _draw_phoebe()
		_: CastExtra.draw(self, style)


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
		"nervous":
			# Wringing hands in front
			back = 0.55 + sin(_t * 5.0) * 0.08
			front = 0.55 - sin(_t * 5.0) * 0.08
		"shy":
			back = 0.1
			front = 0.2 + sin(_t * 1.3) * 0.05
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
		"nervous":
			p.lid = 0.05
			p.tilt = -0.3
			p.scale = 1.06
			p.pupil = 0.65
			# Eyes darting side to side
			p.look = Vector2(0.45 if fmod(_t, 1.6) < 0.8 else -0.45, 0.05)
		"shy":
			p.lid = 0.38
			p.tilt = -0.25
			p.look = Vector2(0.3, 0.55)
	return p


## side: -1 for the eye nearer x<0, +1 for x>0 (used to mirror the lid tilt).
func _eye(c: Vector2, rx: float, ry: float, iris_r: float, iris_col: Color, side: int, base_lid: float = 0.0,
		lid_col: Color = Color.WHITE, sclera: Color = Color.WHITE, lashes: int = 0) -> void:
	var p := _eye_params()
	rx *= p.scale
	ry *= p.scale
	var pts := Art.ellipse(c, rx, ry, 32)
	Art.fill(ci, pts, sclera)
	var look: Vector2 = p.look
	var ic := c + Vector2(look.x * rx * 0.5, look.y * ry * 0.5)
	var pupil_r: float = (iris_r * 0.48 if iris_r > 0.0 else minf(rx, ry) * 0.36) * p.pupil
	if iris_r > 0.0 and iris_col.a > 0.0:
		Art.dot(ci, ic, iris_r, iris_col)
		Art.outline(ci, Art.ellipse(ic, iris_r, iris_r, 20), 2.0)
	var hl_r := iris_r if iris_r > 0.0 else pupil_r * 1.6
	Art.dot(ci, ic, pupil_r, Art.INK)
	Art.dot(ci, ic + Vector2(-hl_r * 0.3, -hl_r * 0.35), hl_r * 0.22, Color(1, 1, 1, 0.9))
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
			Art.fill(ci, poly, lid_col)
		var edge := Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([Vector2(c.x - rx - 4, yl), Vector2(c.x + rx + 4, yr)]), pts)
		for e in edge:
			Art.stroke(ci, e, 3.0)
	Art.outline(ci, pts, 3.0)
	# Emotion extras drawn around the eyes, so every character gets them.
	if emotion == "shy":
		Art.dot(ci, c + Vector2(side * rx * 0.55, ry * 1.45), rx * 0.62, Color(0.98, 0.45, 0.55, 0.55))
	elif emotion == "nervous" and side > 0:
		var drop := c + Vector2(rx * 1.35, -ry * 0.6)
		var tear := PackedVector2Array([drop + Vector2(0, -10), drop + Vector2(5.5, 1), drop + Vector2(4, 6), drop + Vector2(0, 8),
			drop + Vector2(-4, 6), drop + Vector2(-5.5, 1)])
		Art.shape(ci, tear, Color(0.6, 0.85, 1.0), 2.5)
	if lashes > 0 and lid < 0.6:
		for i in lashes:
			var a := -PI / 2 + (float(i) - (lashes - 1) / 2.0) * 0.45 + side * 0.15
			var s := c + Vector2(cos(a) * rx, sin(a) * ry)
			Art.stroke(ci, PackedVector2Array([s, s + Vector2(cos(a), sin(a)) * 9.0]), 3.0)


func _brow(c: Vector2, half_w: float, side: int, thick: float = 4.0, color: Color = Art.INK) -> void:
	var tilt := 0.0
	var lift := 0.0
	match emotion:
		"angry": tilt = 0.5
		"sad": tilt = -0.45
		"surprised", "scared": lift = -8.0
		"smug": tilt = 0.2
		"nervous":
			tilt = -0.5
			lift = -4.0
		"shy": tilt = -0.3
	var inner := c + Vector2(-side * half_w, lift + tilt * half_w)
	var outer := c + Vector2(side * half_w, lift - tilt * half_w * 0.4)
	var mid := (inner + outer) * 0.5 + Vector2(0, -4)
	Art.limb(ci, Art.curve(inner, mid, outer, 8), thick, color, 0.0)


func _mouth_kind() -> String:
	match emotion:
		"happy", "excited": return "grin"
		"sad": return "frown"
		"angry": return "grit"
		"surprised": return "o"
		"scared": return "wobble"
		"smug": return "smirk"
		"nervous": return "grimace"
		"shy": return "small"
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
		Art.fill(ci, pts, inside)
		# Tongue
		var tongue := Art.ellipse(c + Vector2(0, depth * 0.78), hw * 0.5, depth * 0.3, 20)
		for poly in Geometry2D.intersect_polygons(tongue, pts):
			Art.fill(ci, poly, Color(0.93, 0.42, 0.5))
		if teeth == 1:
			for sx in [-1, 1]:
				var tr := Rect2(c + Vector2(sx * 1.5 - (w * 0.13 if sx < 0 else 0.0), top_mid.y - 1), Vector2(w * 0.13, w * 0.15))
				var tp := Art.rrect(tr, 2)
				for poly in Geometry2D.intersect_polygons(tp, pts):
					Art.fill(ci, poly, Color.WHITE)
				Art.outline(ci, tp, 2.0)
		elif teeth == 2:
			var band := PackedVector2Array([c + Vector2(-hw - 4, top_mid.y - 8), c + Vector2(hw + 4, top_mid.y - 8),
				c + Vector2(hw + 4, top_mid.y + w * 0.1), c + Vector2(-hw - 4, top_mid.y + w * 0.1)])
			for poly in Geometry2D.intersect_polygons(band, pts):
				Art.fill(ci, poly, Color.WHITE)
				Art.outline(ci, poly, 1.5)
		Art.outline(ci, pts, 3.0)
		return
	match kind:
		"smile", "grin":
			Art.stroke(ci, Art.curve(c + Vector2(-hw, -w * 0.1), c + Vector2(0, w * 0.22), c + Vector2(hw, -w * 0.1)), 3.5)
			for sx in [-1, 1]:
				var e := c + Vector2(sx * hw, -w * 0.1)
				Art.stroke(ci, PackedVector2Array([e + Vector2(-sx * 4, -5), e + Vector2(sx * 4, 4)]), 3.0)
		"frown":
			Art.stroke(ci, Art.curve(c + Vector2(-hw * 0.8, w * 0.1), c + Vector2(0, -w * 0.12), c + Vector2(hw * 0.8, w * 0.1)), 3.5)
		"smirk":
			Art.stroke(ci, Art.curve(c + Vector2(-hw * 0.7, 0), c + Vector2(hw * 0.1, w * 0.08), c + Vector2(hw, -w * 0.15)), 3.5)
		"wobble":
			var pts := PackedVector2Array()
			for i in 9:
				pts.append(c + Vector2(lerpf(-hw * 0.8, hw * 0.8, i / 8.0), (3.0 if i % 2 == 0 else -3.0) + sin(_t * 20.0) * 1.5))
			Art.stroke(ci, pts, 3.0)
		"small":
			Art.stroke(ci, Art.curve(c + Vector2(-hw * 0.4, -w * 0.02), c + Vector2(0, w * 0.1), c + Vector2(hw * 0.4, -w * 0.02)), 3.0)
		"grit", "grimace":
			var gw := 0.75 if kind == "grit" else 0.6
			var r := Rect2(c + Vector2(-hw * gw, -w * 0.08), Vector2(hw * gw * 2.0, w * 0.18))
			var rp := Art.rrect(r, 4)
			Art.fill(ci, rp, Color.WHITE)
			Art.stroke(ci, PackedVector2Array([Vector2(r.position.x, r.get_center().y), Vector2(r.end.x, r.get_center().y)]), 2.0)
			for i in range(1, 5):
				var x := lerpf(r.position.x, r.end.x, i / 5.0)
				Art.stroke(ci, PackedVector2Array([Vector2(x, r.position.y), Vector2(x, r.end.y)]), 2.0)
			Art.outline(ci, rp, 3.0)
	if teeth == 1 and kind in ["smile", "grin", "smirk"]:
		for sx in [-1, 1]:
			var tr := Rect2(c + Vector2(sx * 1.5 - (w * 0.12 if sx < 0 else 0.0), w * 0.1), Vector2(w * 0.12, w * 0.14))
			var tp := Art.rrect(tr, 2)
			Art.fill(ci, tp, Color.WHITE)
			Art.outline(ci, tp, 2.0)


## Returns the hand position. raise: 0 hanging down, PI/2 horizontal, PI straight up.
func _arm(shoulder: Vector2, side: int, raise: float, length: float, width: float, color: Color,
		hand_r: float, hand_col: Color, sleeve_col: Color = Color(0, 0, 0, 0), sleeve_r: float = 0.0) -> Vector2:
	var a := 0.22 + raise
	var dir := Vector2(side * sin(a), cos(a))
	var elbow := shoulder + dir * length * 0.5 + Vector2(side * 5.0, -2.0).rotated(-side * raise * 0.3)
	var hand := shoulder + dir * length
	Art.limb(ci, Art.curve(shoulder, elbow, hand, 10), width, color)
	if sleeve_r > 0.0:
		Art.blob(ci, shoulder + dir * sleeve_r * 0.4, sleeve_r, sleeve_r * 0.85, sleeve_col, 3.0, 0.0, a * side)
	Art.blob(ci, hand, hand_r, hand_r, hand_col, 3.0)
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
			Art.limb(ci, PackedVector2Array([xf * Vector2(0, 10), xf * Vector2(0, -36)]), 7, Color(0.55, 0.32, 0.15))
			var head := PackedVector2Array()
			for p in Art.rrect(Rect2(-14, -70, 28, 36), 5):
				head.append(xf * p)
			Art.shape(ci, head, gold, 3.0)
			for i in 3:
				var x := -7.0 + i * 7.0
				Art.stroke(ci, PackedVector2Array([xf * Vector2(x, -64), xf * Vector2(x, -42)]), 2.5, gold.darkened(0.4))
			var sp := xf * Vector2(18, -72)
			var s := 5.0 + sin(_t * 8.0) * 2.0
			Art.stroke(ci, PackedVector2Array([sp + Vector2(-s, 0), sp + Vector2(s, 0)]), 2.5, Color.WHITE)
			Art.stroke(ci, PackedVector2Array([sp + Vector2(0, -s), sp + Vector2(0, s)]), 2.5, Color.WHITE)
		"clarinet":
			Art.limb(ci, PackedVector2Array([xf * Vector2(0, 30), xf * Vector2(0, -50)]), 9, Color(0.12, 0.12, 0.14))
			var bell := PackedVector2Array()
			for p in [Vector2(-5, 26), Vector2(5, 26), Vector2(12, 44), Vector2(-12, 44)]:
				bell.append(xf * p)
			Art.shape(ci, bell, Color(0.15, 0.15, 0.17), 3.0)
			for i in 4:
				Art.dot(ci, xf * Vector2(0, -35 + i * 14), 2.5, Color(0.85, 0.85, 0.9))
		"detector":
			var box := PackedVector2Array()
			for p in Art.rrect(Rect2(-20, -40, 40, 34), 6):
				box.append(xf * p)
			Art.shape(ci, box, Color(0.7, 0.72, 0.75), 3.0, 0.2)
			Art.stroke(ci, PackedVector2Array([xf * Vector2(10, -40), xf * Vector2(18, -72)]), 3.0)
			var blink_on := fmod(_t * 3.0, 1.0) < 0.5
			Art.dot(ci, xf * Vector2(18, -74), 6, Color(1, 0.15, 0.1) if blink_on else Color(0.45, 0.05, 0.05))
			Art.dot(ci, xf * Vector2(-6, -24), 7, Color(0.2, 0.9, 0.4))
		"net":
			Art.limb(ci, PackedVector2Array([xf * Vector2(0, 20), xf * Vector2(0, -80)]), 5, Color(0.6, 0.42, 0.22))
			var ring := Art.ellipse(xf * Vector2(0, -105), 24, 24, 24)
			Art.fill(ci, ring, Color(1, 1, 1, 0.35))
			for i in 5:
				var x := -18.0 + i * 9.0
				Art.stroke(ci, PackedVector2Array([xf * Vector2(x, -122), xf * Vector2(x, -88)]), 1.5, Color(1, 1, 1, 0.8))
			Art.outline(ci, ring, 4.0, Color(0.6, 0.42, 0.22))
		"patty":
			var c := xf * Vector2(0, -20)
			Art.blob(ci, c + Vector2(0, -6), 26, 12, Color(0.95, 0.72, 0.35), 3.0, 0.15)
			Art.blob(ci, c + Vector2(0, 4), 27, 6, Color(0.45, 0.25, 0.12), 3.0)
			Art.blob(ci, c + Vector2(0, 0), 28, 3, Color(0.4, 0.8, 0.3), 2.0)
			Art.blob(ci, c + Vector2(0, 11), 25, 7, Color(0.95, 0.72, 0.35), 3.0)
		"money":
			var bill := PackedVector2Array()
			for p in Art.rrect(Rect2(-24, -36, 48, 26), 3):
				bill.append(xf * p)
			Art.shape(ci, bill, Color(0.55, 0.85, 0.5), 3.0)
			Art.text(ci, ThemeDB.fallback_font, xf * Vector2(-6, -16), "$", 18, Color(0.15, 0.45, 0.15), 0, HORIZONTAL_ALIGNMENT_LEFT)
		"locket":
			var c := xf * Vector2(0, -22)
			Art.stroke(ci, PackedVector2Array([xf * Vector2(-4, 6), xf * Vector2(-10, -6), c + Vector2(-3, -12)]), 2.0, Color("c9a13a"))
			Art.shape(ci, Art.heart(c, 15.0), Color("f2c14e"), 3.0, 0.15)
			Art.shape(ci, Art.heart(c + Vector2(0, 1), 9.0), Color("f28cb8"), 2.0)
		"ice_cream":
			var cone := PackedVector2Array([xf * Vector2(-12, -14), xf * Vector2(12, -14), xf * Vector2(0, 14)])
			Art.shape(ci, cone, Color("e3a95c"), 3.0)
			Art.stroke(ci, PackedVector2Array([xf * Vector2(-6, -8), xf * Vector2(4, 4)]), 2.0, Color("b07a3a"))
			Art.blob(ci, xf * Vector2(0, -22), 15, 12, Color("f7a7c4"), 3.0, 0.1)
			Art.blob(ci, xf * Vector2(0, -40), 13, 11, Color("7a4a2a"), 3.0, 0.1)
			Art.dot(ci, xf * Vector2(0, -54), 5, Color("d8352a"))
		"fishing_rod":
			var tip := xf * Vector2(10, -150)
			Art.limb(ci, PackedVector2Array([xf * Vector2(0, 20), tip]), 5, Color("8a5a2b"))
			var bob := tip + Vector2(46, 60 + sin(_t * 3.0) * 4.0)
			Art.stroke(ci, Art.curve(tip, tip + Vector2(40, 0), bob, 8), 1.5, Color(1, 1, 1, 0.9))
			Art.blob(ci, bob, 6, 6, Color("e6452f"), 2.0)
		"beeper":
			var box := PackedVector2Array()
			for p in Art.rrect(Rect2(-14, -30, 28, 20), 4):
				box.append(xf * p)
			Art.shape(ci, box, Color("2b2b33"), 3.0)
			var scr := PackedVector2Array()
			for p in Art.rrect(Rect2(-9, -26, 18, 8), 2):
				scr.append(xf * p)
			Art.fill(ci, scr, Color("9ee66e"))


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
		Art.limb(ci, PackedVector2Array([hip, foot]), 7, yel)
		var sock_top := hip.lerp(foot, 0.45)
		Art.limb(ci, PackedVector2Array([sock_top, foot]), 12, Color.WHITE)
		for i in 2:
			var s := sock_top.lerp(foot, 0.15 + i * 0.22)
			Art.stroke(ci, PackedVector2Array([s + Vector2(-6, 0), s + Vector2(6, 0)]), 3.0, Color("d8352a") if i == 0 else Color("2f6fcf"))
		Art.blob(ci, foot + Vector2(8, 4), 19, 10, Art.INK, 2.0)
		Art.dot(ci, foot + Vector2(14, 0), 3.5, Color(1, 1, 1, 0.7))
	# Shorts
	for side in [-1, 1]:
		Art.shape(ci, Art.rrect(Rect2(side * 24 - 13, -66, 26, 14), 3), brown, 3.0)
	Art.shape(ci, Art.rrect(Rect2(-64, -96, 128, 36), 4), brown, 3.5, 0.15)
	Art.stroke(ci, PackedVector2Array([Vector2(-62, -86), Vector2(62, -86)]), 4.0)
	for i in 6:
		var x := -50.0 + i * 20.0
		Art.stroke(ci, PackedVector2Array([Vector2(x, -86), Vector2(x + 8, -86)]), 3.0, Color(0.9, 0.9, 0.9))
	# Shirt and tie
	Art.shape(ci, PackedVector2Array([Vector2(-66, -110), Vector2(66, -110), Vector2(64, -95), Vector2(-64, -95)]), Color.WHITE, 3.5)
	Art.shape(ci, PackedVector2Array([Vector2(0, -108), Vector2(9, -99), Vector2(0, -74), Vector2(-9, -99)]), Color("d8352a"), 3.0)
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
	Art.shape(ci, body, yel, 4.5, 0.12, Vector2(-12, -10))
	var hole := Color("bfae32")
	for h in [[-50, -230, 8, 10], [44, -228, 10, 7], [54, -150, 7, 10], [-56, -135, 9, 8], [32, -122, 6, 6],
			[-24, -122, 5, 6], [2, -240, 5, 4], [-60, -185, 5, 7], [60, -195, 6, 5]]:
		ci.draw_colored_polygon(Art.ellipse(Vector2(h[0], h[1]), h[2], h[3], 16), hole)
	# Face
	_eye(Vector2(-25, -196), 24, 27, 11, Color("3d8fe0"), -1, 0.0, yel, Color.WHITE, 3)
	_eye(Vector2(25, -196), 24, 27, 11, Color("3d8fe0"), 1, 0.0, yel, Color.WHITE, 3)
	Art.limb(ci, Art.curve(Vector2(2, -176), Vector2(12, -180), Vector2(22, -174), 6), 9, yel)
	for side in [-1, 1]:
		var ch := Vector2(side * 46, -160)
		Art.dot(ci, ch, 11, Color(0.97, 0.55, 0.45, 0.9))
		for f in [Vector2(-4, -2), Vector2(3, -4), Vector2(1, 4)]:
			Art.dot(ci, ch + f, 1.6, Color(0.6, 0.25, 0.15))
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
	Art.shape(ci, star, pink, 4.5, 0.12, Vector2(-14, -10))
	# Spots
	for s in [Vector2(-20, -225), Vector2(14, -140), Vector2(-70, -160), Vector2(78, -165), Vector2(-28, -120)]:
		Art.dot(ci, s, 2.5, pink.darkened(0.25))
	# Shorts clipped to the star
	var band := PackedVector2Array([Vector2(-140, -108), Vector2(140, -108), Vector2(140, -36), Vector2(-140, -36)])
	var green := Color("8fcf4c")
	for poly in Geometry2D.intersect_polygons(star, band):
		Art.shape(ci, poly, green, 3.5, 0.12)
		for fp in [Vector2(-30, -92), Vector2(8, -80), Vector2(34, -96), Vector2(-46, -58), Vector2(46, -54), Vector2(-12, -100)]:
			if Geometry2D.is_point_in_polygon(fp, poly):
				for k in 4:
					Art.dot(ci, fp + Vector2(5, 0).rotated(k * PI / 2), 3.5, Color("9c5fd6"))
				Art.dot(ci, fp, 2.5, Color("f5d63b"))
	# Face
	_eye(Vector2(-14, -200), 12, 17, 0, Color(0, 0, 0, 0), -1, 0.0, pink)
	_eye(Vector2(14, -200), 12, 17, 0, Color(0, 0, 0, 0), 1, 0.0, pink)
	_brow(Vector2(-15, -224), 12, -1, 5.0)
	_brow(Vector2(15, -224), 12, 1, 5.0)
	_mouth(Vector2(0, -166), 58, 0)
	Art.stroke(ci, Art.curve(Vector2(-4, -116), Vector2(0, -112), Vector2(4, -116), 4), 2.5)
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
		Art.limb(ci, Art.curve(top, Vector2(x * 1.2 - 6, -34), foot, 10) + PackedVector2Array([tip]), 12, skin)
	# Shirt
	var torso := Art.smooth(PackedVector2Array([Vector2(-30, -128), Vector2(30, -128), Vector2(42, -60), Vector2(0, -54), Vector2(-42, -60)]), 4)
	Art.shape(ci, torso, shirt, 4.0, 0.15)
	Art.stroke(ci, PackedVector2Array([Vector2(-8, -126), Vector2(0, -112), Vector2(8, -126)]), 3.0)
	# Head
	var head := Art.smooth(PackedVector2Array([Vector2(-15, -128), Vector2(-48, -168), Vector2(-57, -222), Vector2(-36, -268),
		Vector2(0, -280), Vector2(36, -268), Vector2(57, -222), Vector2(48, -168), Vector2(15, -128)]), 6)
	Art.shape(ci, head, skin, 4.5, 0.14, Vector2(-12, -10))
	Art.stroke(ci, Art.curve(Vector2(-30, -255), Vector2(-40, -240), Vector2(-42, -225), 6), 2.0, skin.darkened(0.3))
	# Eyes (droopy, bored)
	_eye(Vector2(-20, -212), 18, 15, 5, Color("b3202a"), -1, 0.45, skin, Color("f6f0c2"))
	_eye(Vector2(20, -212), 18, 15, 5, Color("b3202a"), 1, 0.45, skin, Color("f6f0c2"))
	_mouth(Vector2(4, -150), 30, 0)
	# Nose
	var droop := sin(_t * 1.3) * 2.0
	var nose := Art.smooth(PackedVector2Array([Vector2(-6, -206), Vector2(8, -206), Vector2(18, -178 + droop),
		Vector2(12, -156 + droop), Vector2(0, -158 + droop), Vector2(-4, -180)]), 5)
	Art.shape(ci, nose, skin, 4.0, 0.15)
	_arm(Vector2(33, -118), 1, raise.y, 64, 7, skin, 7, skin)


func _draw_crab() -> void:
	var red := Color("e6452f")
	var raise := _arm_raise()
	# Legs
	for side in [-1, 1]:
		var sw := _leg_swing(side)
		Art.limb(ci, PackedVector2Array([Vector2(side * 26, -50), Vector2(side * 30 + sw, -4)]), 11, red)
		Art.shape(ci, PackedVector2Array([Vector2(side * 30 + sw - 6, -6), Vector2(side * 30 + sw + 6, -6), Vector2(side * 30 + sw + side * 3, 4)]), red, 2.5)
	# Back claw
	_claw(Vector2(-72, -112), -1, raise.x, red)
	# Eye stalks
	var sway := sin(_t * 1.8) * 3.0
	for side in [-1, 1]:
		Art.limb(ci, Art.curve(Vector2(side * 16, -176), Vector2(side * 18, -205), Vector2(side * 24 + sway, -232), 8), 8, red)
	# Body
	var body := Art.smooth(PackedVector2Array([Vector2(-82, -100), Vector2(-70, -152), Vector2(-36, -182), Vector2(0, -188),
		Vector2(36, -182), Vector2(70, -152), Vector2(82, -100), Vector2(66, -56), Vector2(0, -42), Vector2(-66, -56)]), 6)
	Art.shape(ci, body, red, 4.5, 0.12, Vector2(-14, -10))
	var shirt_band := PackedVector2Array([Vector2(-120, -104), Vector2(-40, -104), Vector2(0, -88), Vector2(40, -104), Vector2(120, -104), Vector2(120, 0), Vector2(-120, 0)])
	for poly in Geometry2D.intersect_polygons(body, shirt_band):
		Art.shape(ci, poly, Color("74b9e8"), 3.5, 0.1)
	var belt := PackedVector2Array([Vector2(-120, -70), Vector2(120, -70), Vector2(120, -58), Vector2(-120, -58)])
	for poly in Geometry2D.intersect_polygons(body, belt):
		Art.shape(ci, poly, Color("4a3020"), 3.0)
	Art.shape(ci, Art.rrect(Rect2(-10, -72, 20, 16), 3), Color("e8c040"), 3.0)
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
	Art.limb(ci, Art.curve(shoulder, shoulder + dir * 22 + Vector2(0, 14), wrist, 8), 12, red)
	var snap := 0.25 + (_talk_open * 0.6 if talking else 0.0) + (absf(sin(_t * 8.0)) * 0.5 if emotion == "angry" else 0.0)
	var base_ang := dir.angle()
	var xf := Transform2D(base_ang, Vector2(1, side), 0.0, wrist)
	var upper := PackedVector2Array()
	for p in Art.smooth(PackedVector2Array([Vector2(0, -4), Vector2(18, -22), Vector2(46, -20), Vector2(56, -6), Vector2(28, -4)]), 5):
		upper.append(xf * p.rotated(-snap))
	var lower := PackedVector2Array()
	for p in Art.smooth(PackedVector2Array([Vector2(0, 4), Vector2(18, 18), Vector2(42, 14), Vector2(26, 4)]), 5):
		lower.append(xf * p.rotated(snap * 0.6))
	Art.shape(ci, lower, red.darkened(0.08), 3.5)
	Art.shape(ci, upper, red, 3.5, 0.1)
	Art.blob(ci, wrist, 13, 13, red, 3.5)
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
	Art.shape(ci, tail, suit, 4.0, 0.12)
	_arm(Vector2(-46, -148), -1, raise.x, 62, 20, suit, 13, suit)
	# Legs and boots
	for side in [-1, 1]:
		var sw := _leg_swing(side)
		Art.limb(ci, PackedVector2Array([Vector2(side * 22, -72), Vector2(side * 22 + sw, -18)]), 26, suit)
		Art.blob(ci, Vector2(side * 22 + sw + 6, -8), 20, 11, Color("9aa3ad"), 3.0, 0.15)
	# Torso
	Art.shape(ci, Art.rrect(Rect2(-50, -166, 100, 104), 30), suit, 4.0, 0.12)
	# Acorn badge
	Art.blob(ci, Vector2(22, -118), 8, 9, Color("8a5530"), 2.5)
	Art.shape(ci, Art.rrect(Rect2(13, -132, 18, 8), 3), Color("5c8a2f"), 2.5)
	Art.stroke(ci, PackedVector2Array([Vector2(-34, -82), Vector2(34, -82)]), 3.0, Color(0.7, 0.7, 0.72))
	# Collar ring
	Art.shape(ci, Art.rrect(Rect2(-46, -176, 92, 16), 7), Color("b9c1c9"), 3.5)
	# Head
	var hc := Vector2(0, -218)
	for side in [-1, 1]:
		Art.blob(ci, hc + Vector2(side * 28, -30), 11, 14, fur, 3.0, 0.0, side * 0.3)
		Art.dot(ci, hc + Vector2(side * 28, -29), 5, muzzle)
	Art.blob(ci, hc, 42, 37, fur, 4.0, 0.12)
	Art.blob(ci, hc + Vector2(0, 14), 30, 19, muzzle, 0.0)
	_eye(hc + Vector2(-15, -8), 11, 14, 6, Color("3a2416"), -1, 0.0, fur, Color.WHITE, 2)
	_eye(hc + Vector2(15, -8), 11, 14, 6, Color("3a2416"), 1, 0.0, fur, Color.WHITE, 2)
	Art.blob(ci, hc + Vector2(0, 7), 5, 4, Color("3a2416"), 0.0)
	_mouth(hc + Vector2(0, 18), 30, 1)
	# Glass helmet
	var glass := Art.ellipse(hc + Vector2(0, -4), 66, 64, 48)
	Art.fill(ci, glass, Color(0.75, 0.92, 1.0, 0.28))
	ci.draw_arc(hc + Vector2(-4, -8), 52, PI * 1.05, PI * 1.45, 12, Color(1, 1, 1, 0.85), 6.0, true)
	ci.draw_arc(hc + Vector2(-4, -8), 52, PI * 1.55, PI * 1.62, 4, Color(1, 1, 1, 0.85), 6.0, true)
	Art.outline(ci, glass, 4.0, Color("4d5966"))
	# Flower on top
	var fc := hc + Vector2(0, -98)
	Art.stroke(ci, PackedVector2Array([hc + Vector2(0, -68), fc]), 4.0, Color("3f8f3a"))
	for k in 5:
		Art.blob(ci, fc + Vector2(0, -11).rotated(k * TAU / 5 + sin(_t) * 0.2), 9, 9, Color("c56bd8"), 2.5)
	Art.blob(ci, fc, 6, 6, Color("f5d63b"), 2.5)
	_arm(Vector2(46, -148), 1, raise.y, 62, 20, suit, 13, suit)


# ------------------------------------------------------------ human kids --
# Shared pieces for the Hey Arnold! cast.

const SKIN := Color("f6d2b0")


## Two legs with optional socks, plus shoes. Drawn back-to-front before the torso.
func _human_legs(hip_y: float, foot_y: float, sep: float, width: float, leg_col: Color, shoe: Color,
		sock: Color = Color(0, 0, 0, 0), sock_frac: float = 0.45) -> void:
	for side in [-1, 1]:
		var sw := _leg_swing(side)
		var lift := maxf(0.0, -cos(_walk_phase + (0.0 if side > 0 else PI))) * 6.0 * float(walking)
		var hip := Vector2(side * sep, hip_y)
		var foot := Vector2(side * sep + sw * 0.8, foot_y - lift)
		Art.limb(ci, PackedVector2Array([hip, foot]), width, leg_col)
		if sock.a > 0.0:
			Art.limb(ci, PackedVector2Array([hip.lerp(foot, 1.0 - sock_frac), foot]), width + 2.0, sock)
		Art.blob(ci, foot + Vector2(7, 4), width * 0.55 + 7.0, 8.5, shoe, 3.0, 0.15)
		Art.dot(ci, foot + Vector2(12, 1), 2.5, Color(1, 1, 1, 0.5))


## A simple face-on eyebrow pair that follows the emotion.
func _brows(y: float, x: float, half_w: float, thick: float, color: Color = Art.INK) -> void:
	_brow(Vector2(-x, y), half_w, -1, thick, color)
	_brow(Vector2(x, y), half_w, 1, thick, color)


func _draw_arnold() -> void:
	var sweater := Color("72b85a")
	var raise := _arm_raise()
	_arm(Vector2(-28, -122), -1, raise.x, 52, 9, sweater, 8, SKIN)
	_human_legs(-64, -10, 13, 16, Color("6f8fd6"), Color("3a3340"))
	# Plaid shirt tails sticking out under the sweater, like a little kilt
	var kilt := PackedVector2Array([Vector2(-32, -78), Vector2(32, -78), Vector2(36, -56), Vector2(-36, -56)])
	Art.shape(ci, kilt, Color("cc4a3e"), 3.0)
	for x in [-22, -6, 10, 26]:
		Art.stroke(ci, PackedVector2Array([Vector2(x, -77), Vector2(x * 1.08, -57)]), 3.0, Color("3c5fb8"))
	Art.stroke(ci, PackedVector2Array([Vector2(-34, -67), Vector2(34, -67)]), 3.0, Color("3c5fb8"))
	# Sweater
	Art.shape(ci, Art.rrect(Rect2(-30, -132, 60, 60), 14), sweater, 4.0, 0.15)
	Art.stroke(ci, PackedVector2Array([Vector2(-26, -80), Vector2(26, -80)]), 3.0, sweater.darkened(0.3))
	Art.shape(ci, Art.rrect(Rect2(-7, -146, 14, 18), 4), SKIN, 3.0)
	# Football head with ears
	for sx in [-1, 1]:
		Art.blob(ci, Vector2(sx * 74, -166), 8, 11, SKIN, 3.0)
	var head := Art.smooth(PackedVector2Array([Vector2(-94, -184), Vector2(-66, -213), Vector2(0, -229), Vector2(66, -213),
		Vector2(94, -184), Vector2(64, -152), Vector2(0, -138), Vector2(-64, -152)]), 7)
	Art.shape(ci, head, SKIN, 4.0, 0.1, Vector2(-14, -8))
	# Blond hair tuft and the tiny blue cap
	var tuft := PackedVector2Array([Vector2(-26, -222), Vector2(-20, -238), Vector2(-10, -226), Vector2(-2, -242),
		Vector2(6, -227), Vector2(16, -240), Vector2(22, -224)])
	Art.shape(ci, tuft, Color("f2d34b"), 3.0)
	Art.shape(ci, Art.rrect(Rect2(-12, -251, 24, 15), 6), Color("4a78d0"), 3.0)
	Art.stroke(ci, PackedVector2Array([Vector2(-16, -237), Vector2(16, -237)]), 4.0)
	# Face
	_eye(Vector2(-30, -190), 10, 13, 0, Color(0, 0, 0, 0), -1, 0.0, SKIN)
	_eye(Vector2(30, -190), 10, 13, 0, Color(0, 0, 0, 0), 1, 0.0, SKIN)
	_brows(-210, 30, 9, 3.0)
	Art.stroke(ci, Art.curve(Vector2(0, -180), Vector2(8, -172), Vector2(0, -168), 6), 3.0)
	_mouth(Vector2(0, -156), 34, 0)
	_arm(Vector2(28, -122), 1, raise.y, 52, 9, sweater, 8, SKIN)


func _draw_helga() -> void:
	var pink := Color("f28cb8")
	var hair := Color("f4d24e")
	var raise := _arm_raise()
	_arm(Vector2(-25, -122), -1, raise.x, 50, 7, SKIN, 7, SKIN, Color.WHITE, 11)
	_human_legs(-48, -10, 12, 10, SKIN, Color("26222c"), Color.WHITE, 0.5)
	# Dress over a white shirt
	var dress := PackedVector2Array([Vector2(-24, -130), Vector2(24, -130), Vector2(44, -44), Vector2(-44, -44)])
	Art.shape(ci, dress, pink, 4.0, 0.15)
	for sx in [-1, 1]:
		Art.shape(ci, PackedVector2Array([Vector2(0, -132), Vector2(sx * 16, -134), Vector2(sx * 10, -118)]), Color.WHITE, 3.0)
	Art.shape(ci, Art.rrect(Rect2(-6, -144, 12, 14), 4), SKIN, 3.0)
	# Pigtails behind the head
	for sx in [-1, 1]:
		Art.blob(ci, Vector2(sx * 50, -168), 25, 11, hair, 3.5, 0.1, sx * 0.35)
	var hc := Vector2(0, -176)
	var head := Art.ellipse(hc, 40, 42, 40)
	Art.shape(ci, head, SKIN, 4.0, 0.1)
	var cap := PackedVector2Array([hc + Vector2(-60, -60), hc + Vector2(60, -60), hc + Vector2(60, -22), hc + Vector2(30, -31),
		hc + Vector2(0, -27), hc + Vector2(-30, -31), hc + Vector2(-60, -22)])
	for poly in Geometry2D.intersect_polygons(head, cap):
		Art.fill(ci, poly, hair)
	Art.outline(ci, head, 4.0)
	# Big pink bow
	var bc := hc + Vector2(0, -44)
	for sx in [-1, 1]:
		var loop := PackedVector2Array([bc, bc + Vector2(sx * 34, -18), bc + Vector2(sx * 38, 6), bc + Vector2(sx * 6, 6)])
		Art.shape(ci, Art.smooth(loop, 4), Color("ef5a9a"), 3.5, 0.12)
	Art.blob(ci, bc + Vector2(0, -2), 8, 8, Color("ef5a9a"), 3.0)
	# The famous unibrow: always a little scowly
	var dip := 6.0
	match emotion:
		"happy", "excited": dip = -3.0
		"sad", "scared", "nervous", "shy": dip = -9.0
		"angry": dip = 11.0
		"surprised": dip = -6.0
	var by := hc.y - 19.0 - (5.0 if emotion in ["surprised", "scared"] else 0.0)
	Art.limb(ci, Art.curve(Vector2(-28, by - 2), Vector2(0, by + dip * 1.1), Vector2(28, by - 2), 10), 6.0, Art.INK, 0.0)
	_eye(hc + Vector2(-14, -6), 8, 10, 4, Color("3d6fd0"), -1, 0.0, SKIN)
	_eye(hc + Vector2(14, -6), 8, 10, 4, Color("3d6fd0"), 1, 0.0, SKIN)
	Art.stroke(ci, Art.curve(hc + Vector2(1, 2), hc + Vector2(7, 9), hc + Vector2(1, 12), 6), 3.0)
	_mouth(hc + Vector2(0, 22), 26, 0)
	_arm(Vector2(25, -122), 1, raise.y, 50, 7, SKIN, 7, SKIN, Color.WHITE, 11)


func _draw_gerald() -> void:
	var skin := Color("8d5b3e")
	var jersey := Color("d9473a")
	var raise := _arm_raise()
	_arm(Vector2(-30, -128), -1, raise.x, 56, 9, skin, 8, skin, jersey, 12)
	_human_legs(-66, -10, 14, 17, Color("3b4e8c"), Color("f2f2f2"))
	Art.shape(ci, Art.rrect(Rect2(-32, -138, 64, 76), 14), jersey, 4.0, 0.15)
	# The node is mirrored when facing left; flip the number back so it never reads "EE".
	ci.draw_set_transform(-BOUNDS.position * BAKE_SCALE, 0.0, Vector2(BAKE_SCALE * facing, BAKE_SCALE))
	Art.text(ci, UiKit.TITLE_FONT, Vector2(-32, -90), "33", 26, Color.WHITE, 5, HORIZONTAL_ALIGNMENT_CENTER, 64)
	ci.draw_set_transform(-BOUNDS.position * BAKE_SCALE, 0.0, Vector2.ONE * BAKE_SCALE)
	Art.shape(ci, Art.rrect(Rect2(-7, -152, 14, 18), 4), skin, 3.0)
	# The tower of hair
	var hair := Art.rrect(Rect2(-36, -328, 72, 150), 34)
	Art.shape(ci, hair, Color("2b211c"), 4.0, 0.2, Vector2(-10, -8))
	for sx in [-1, 1]:
		Art.blob(ci, Vector2(sx * 38, -178), 7, 10, skin, 3.0)
	var hc := Vector2(0, -182)
	Art.shape(ci, Art.ellipse(hc, 38, 40, 36), skin, 4.0, 0.12)
	_eye(hc + Vector2(-14, -8), 9, 10, 0, Color(0, 0, 0, 0), -1, 0.35, skin)
	_eye(hc + Vector2(14, -8), 9, 10, 0, Color(0, 0, 0, 0), 1, 0.35, skin)
	_brows(hc.y - 24, 14, 8, 3.5)
	Art.stroke(ci, Art.curve(hc + Vector2(-6, 8), hc + Vector2(0, 13), hc + Vector2(6, 8), 6), 3.0)
	_mouth(hc + Vector2(0, 24), 30, 2, Color(0.3, 0.05, 0.08))
	_arm(Vector2(30, -128), 1, raise.y, 56, 9, skin, 8, skin, jersey, 12)


func _draw_grandpa() -> void:
	var skin := Color("f2c9a5")
	var shirt := Color("f3f0e6")
	var raise := _arm_raise()
	_arm(Vector2(-30, -196), -1, raise.x, 74, 8, skin, 8, skin)
	_human_legs(-112, -10, 13, 15, Color("7f8591"), Color("6b4428"))
	# Undershirt, trousers top and belt
	Art.shape(ci, PackedVector2Array([Vector2(-36, -126), Vector2(36, -126), Vector2(34, -104), Vector2(-34, -104)]), Color("7f8591"), 3.5)
	var tank := PackedVector2Array([Vector2(-22, -208), Vector2(-12, -208), Vector2(-6, -196), Vector2(6, -196), Vector2(12, -208),
		Vector2(22, -208), Vector2(34, -186), Vector2(36, -122), Vector2(-36, -122), Vector2(-34, -186)])
	Art.shape(ci, tank, shirt, 4.0, 0.1)
	Art.stroke(ci, PackedVector2Array([Vector2(-36, -124), Vector2(36, -124)]), 6.0, Color("5a3a26"))
	Art.shape(ci, Art.rrect(Rect2(-6, -230, 12, 26), 4), skin, 3.0)
	# Long head, big ears, white fringe of hair
	var hc := Vector2(0, -258)
	for sx in [-1, 1]:
		Art.blob(ci, hc + Vector2(sx * 33, 4), 9, 14, skin, 3.0)
	Art.shape(ci, Art.ellipse(hc, 32, 42, 36), skin, 4.0, 0.12)
	for sx in [-1, 1]:
		Art.blob(ci, hc + Vector2(sx * 27, -10), 9, 13, Color("eeeeee"), 3.0)
	for i in 3:
		Art.stroke(ci, Art.curve(hc + Vector2(-14, -28 + i * 6), hc + Vector2(0, -31 + i * 6), hc + Vector2(14, -28 + i * 6), 6), 2.0, skin.darkened(0.3))
	_eye(hc + Vector2(-12, -6), 6, 7, 0, Color(0, 0, 0, 0), -1, 0.25, skin)
	_eye(hc + Vector2(12, -6), 6, 7, 0, Color(0, 0, 0, 0), 1, 0.25, skin)
	_brows(hc.y - 18, 12, 9, 6.0, Color("eeeeee"))
	_mouth(hc + Vector2(4, 30), 26, 0)
	Art.blob(ci, hc + Vector2(8, 12), 11, 13, skin, 3.5, 0.15)
	_arm(Vector2(30, -196), 1, raise.y, 74, 8, skin, 8, skin)


func _draw_phoebe() -> void:
	var top := Color("9cc8ee")
	var hair := Color("1d1d2a")
	var raise := _arm_raise()
	_arm(Vector2(-22, -110), -1, raise.x, 44, 7, SKIN, 7, SKIN, top, 10)
	_human_legs(-44, -10, 10, 9, SKIN, Color("26222c"), Color.WHITE, 0.5)
	Art.shape(ci, PackedVector2Array([Vector2(-24, -72), Vector2(24, -72), Vector2(34, -40), Vector2(-34, -40)]), Color("34508f"), 3.5, 0.12)
	Art.shape(ci, Art.rrect(Rect2(-23, -120, 46, 52), 12), top, 4.0, 0.12)
	Art.shape(ci, Art.rrect(Rect2(-6, -132, 12, 14), 4), SKIN, 3.0)
	var hc := Vector2(0, -162)
	# Hair: bob behind, bun on top
	Art.shape(ci, Art.rrect(Rect2(-40, -196, 80, 56), 20), hair, 3.5)
	Art.blob(ci, hc + Vector2(0, -42), 14, 13, hair, 3.5)
	Art.shape(ci, Art.rrect(Rect2(-8, -199, 16, 7), 3), Color("e2593a"), 2.5)
	var head := Art.ellipse(hc, 34, 36, 36)
	Art.shape(ci, head, SKIN, 4.0, 0.1)
	var bangs := PackedVector2Array([hc + Vector2(-50, -50), hc + Vector2(50, -50), hc + Vector2(50, -14), hc + Vector2(-50, -14)])
	for poly in Geometry2D.intersect_polygons(head, bangs):
		Art.fill(ci, poly, hair)
	Art.outline(ci, head, 4.0)
	# Eyes behind big round glasses
	for sx in [-1, 1]:
		_eye(hc + Vector2(sx * 13, 2), 6, 7, 0, Color(0, 0, 0, 0), sx, 0.0, SKIN)
		ci.draw_arc(hc + Vector2(sx * 13, 2), 12, 0, TAU, 24, Art.INK, 3.5)
	Art.stroke(ci, PackedVector2Array([hc + Vector2(-2, 1), hc + Vector2(2, 1)]), 3.0)
	_brows(hc.y - 16, 13, 6, 2.5)
	_mouth(hc + Vector2(0, 22), 18, 0)
	_arm(Vector2(22, -110), 1, raise.y, 44, 7, SKIN, 7, SKIN, top, 10)
