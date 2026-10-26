class_name Backdrop
extends Node2D
## Procedurally drawn location sets (1280x720 stage).
##
## The static set is drawn once into an offscreen texture (redrawing thousands of
## outlines every frame is far too slow in the browser); only the few moving bits
## (bubbles, seaweed, light rays, jellyfish...) are redrawn each frame.

const W := 1280.0
const H := 720.0
const GROUND := 640.0
const PAD := 80.0
## Resolution of the baked set relative to the stage, so close-ups stay crisp.
const BAKE_SCALE := 1.5
## The moving scenery is redrawn at this rate (bubbles move every frame).
const FX_FPS := 15.0

static var _bubble_tex: ImageTexture

var location := "pineapple_house"
var sign_font: Font = preload("res://assets/fonts/LuckiestGuy-Regular.ttf")
## The CanvasItem the drawing helpers currently draw into.
var ci: CanvasItem

var _t := 0.0
var _bubbles: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()
var _vp: SubViewport
var _set_layer: _Layer
var _fx_layer: _Layer
var _bubble_layer: _Layer
var _fx_t := 0.0
var _baked := false
var _sky_bottom := Color("8fd6ee")
var _goo := PackedVector2Array()


class _Layer:
	extends Node2D
	var target: Backdrop
	var fn: StringName

	func _draw() -> void:
		target.ci = self
		target.call(fn)


func _init() -> void:
	_vp = SubViewport.new()
	_vp.size = Vector2i(ceili((W + PAD * 2.0) * BAKE_SCALE), ceili((H + PAD * 2.0) * BAKE_SCALE))
	_vp.disable_3d = true
	_vp.transparent_bg = false
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_set_layer = _Layer.new()
	_set_layer.target = self
	_set_layer.fn = &"_draw_set"
	_vp.add_child(_set_layer)
	add_child(_vp)
	_fx_layer = _Layer.new()
	_fx_layer.target = self
	_fx_layer.fn = &"_draw_fx"
	add_child(_fx_layer)
	_bubble_layer = _Layer.new()
	_bubble_layer.target = self
	_bubble_layer.fn = &"_draw_bubbles"
	add_child(_bubble_layer)
	if _bubble_tex == null:
		_bubble_tex = _make_bubble_texture()


## A bubble drawn once into a texture: textured quads are batched and nearly free,
## while polygons/arcs cost a GPU buffer upload each time they're redrawn.
static func _make_bubble_texture() -> ImageTexture:
	var n := 64
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c := Vector2(n, n) * 0.5
	for y in n:
		for x in n:
			var p := Vector2(x + 0.5, y + 0.5)
			var d := p.distance_to(c) / (n * 0.5)
			var ring := clampf(1.0 - absf(d - 0.88) / 0.08, 0.0, 1.0) * 0.75
			var hl := clampf(1.0 - p.distance_to(c + Vector2(-0.35, -0.35) * n * 0.5) / (n * 0.13), 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, maxf(ring, minf(hl * 2.0, 0.8))))
	return ImageTexture.create_from_image(img)


func set_location(id: String) -> void:
	location = id
	_rng.seed = hash(id)
	_bubbles.clear()
	var count := 6 if id == "krusty_kitchen" else 16
	for i in count:
		_bubbles.append(_new_bubble(true))
	_baked = false
	_set_layer.queue_redraw()
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	RenderingServer.frame_post_draw.connect(_on_baked, CONNECT_ONE_SHOT)
	queue_redraw()


func _on_baked() -> void:
	_baked = true
	queue_redraw()


func _new_bubble(anywhere: bool) -> Dictionary:
	return {
		"x": randf_range(-PAD, W + PAD),
		"y": randf_range(0, H) if anywhere else H + 20.0,
		"r": randf_range(3.0, 11.0),
		"speed": randf_range(30.0, 75.0),
		"phase": randf() * TAU,
	}


func _process(delta: float) -> void:
	_t += delta
	for b in _bubbles:
		b.y -= b.speed * delta
		if b.y < -20.0:
			b.merge(_new_bubble(false), true)
	_bubble_layer.queue_redraw()
	_fx_t -= delta
	if _fx_t <= 0.0:
		_fx_t = fmod(_fx_t, 1.0 / FX_FPS) + 1.0 / FX_FPS
		_fx_layer.queue_redraw()


func _draw() -> void:
	if _baked:
		draw_texture_rect(_vp.get_texture(), Rect2(-PAD, -PAD, W + PAD * 2.0, H + PAD * 2.0), false)
	else:
		draw_rect(Rect2(-PAD, -PAD, W + PAD * 2.0, H + PAD * 2.0), _sky_bottom)


func _draw_set() -> void:
	ci.draw_set_transform(Vector2(PAD, PAD) * BAKE_SCALE, 0.0, Vector2.ONE * BAKE_SCALE)
	match location:
		"pineapple_house": _pineapple_house()
		"pat_rock": _pat_rock()
		"squidwerd_house": _squidwerd_house()
		"krusty_crab": _krusty_crab()
		"krusty_kitchen": _krusty_kitchen()
		"treedome": _treedome()
		"jellyfish_fields": _jellyfish_fields()
		"goo_lagoon": _goo_lagoon()
		"chum_bucket": _chum_bucket()
		"boating_school": _boating_school()
		_: _sea_sky()


## Everything that moves. Drawn on top of the baked set every frame, so keep it light.
func _draw_fx() -> void:
	if location != "krusty_kitchen":
		for i in 5:
			var x := 120.0 + i * 260.0 + sin(_t * 0.4 + i) * 30.0
			var ray := PackedVector2Array([Vector2(x - 30, -PAD), Vector2(x + 40, -PAD), Vector2(x + 160, 560), Vector2(x + 30, 560)])
			ci.draw_colored_polygon(ray, Color(1, 1, 1, 0.06))
	match location:
		"pineapple_house":
			_seaweed(120, 600, 120)
			_seaweed(1180, 610, 150, Color("4cb04f"))
		"pat_rock":
			_seaweed(1250, 615, 110)
			_weathervane()
		"squidwerd_house":
			_seaweed(160, 610, 90, Color("3d9a4a"))
		"krusty_crab":
			_seaweed(80, 620, 130)
			_seaweed(1230, 620, 100, Color("4cb04f"))
		"krusty_kitchen":
			_steam()
		"treedome":
			_seaweed(80, 630, 120)
		"jellyfish_fields":
			for i in 7:
				var base := Vector2(100 + i * 180, 120 + (i % 3) * 90)
				var c := base + Vector2(sin(_t * 0.6 + i * 1.7) * 60.0, sin(_t * 1.2 + i) * 25.0)
				_jellyfish(c, 0.8 + (i % 2) * 0.3)
		"goo_lagoon":
			_goo_waves()
		"chum_bucket":
			var flicker := 0.5 + 0.5 * absf(sin(_t * 9.0)) * float(fmod(_t, 3.0) > 0.4)
			Art.dot(ci, Vector2(640, 200), 10, Color(0.6, 1.0, 0.4, flicker))
		"boating_school":
			_seaweed(1220, 625, 110)
			var beam := PackedVector2Array([Vector2(160, 312), Vector2(160 + cos(_t) * 400, 290 + sin(_t) * 60), Vector2(160 + cos(_t) * 400, 340 + sin(_t) * 60)])
			ci.draw_colored_polygon(beam, Color(1, 1, 0.7, 0.18))


# ---------------------------------------------------------------- shared --

func _sea_sky(top: Color = Color("2f7fd0"), bottom: Color = Color("8fd6ee"), flowers: bool = true) -> void:
	_sky_bottom = bottom
	Art.gradient_rect(ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), top, bottom)
	if flowers:
		var cols := [Color(0.85, 0.95, 1.0, 0.55), Color(0.75, 1.0, 0.85, 0.5), Color(1.0, 0.9, 0.98, 0.5), Color(0.98, 1.0, 0.8, 0.5)]
		var spots := [Vector2(90, 90), Vector2(330, 60), Vector2(560, 130), Vector2(820, 70), Vector2(1060, 120), Vector2(1220, 40),
			Vector2(200, 230), Vector2(980, 250), Vector2(700, 20)]
		for i in spots.size():
			Art.sky_flower(ci, spots[i], 38.0 + (i % 3) * 12.0, cols[i % cols.size()], i)


func _sand(top_y: float = 560.0, color: Color = Color("f1dc9b"), hills: float = 14.0) -> void:
	var pts := PackedVector2Array()
	var n := 24
	for i in n + 1:
		var x := lerpf(-PAD, W + PAD, float(i) / n)
		pts.append(Vector2(x, top_y + sin(x * 0.006 + 1.3) * hills + sin(x * 0.017) * hills * 0.4))
	pts.append(Vector2(W + PAD, H + PAD))
	pts.append(Vector2(-PAD, H + PAD))
	ci.draw_colored_polygon(pts, color)
	var edge := pts.slice(0, n + 1)
	Art.stroke(ci, edge, 4.0)
	_rng.seed = hash(location) + 7
	for i in 60:
		var p := Vector2(_rng.randf_range(-PAD, W + PAD), _rng.randf_range(top_y + 25, H + 20))
		Art.dot(ci, p, _rng.randf_range(1.5, 3.5), color.darkened(0.15))
	for i in 6:
		var p := Vector2(_rng.randf_range(0, W), _rng.randf_range(top_y + 40, H - 10))
		Art.blob(ci, p, _rng.randf_range(10, 18), _rng.randf_range(6, 9), color.darkened(0.25), 3.0)


## Swaying seaweed, as one tapered polygon per blade (cheap to redraw).
func _seaweed(x: float, base_y: float, h: float, color: Color = Color("3fa34d"), blades: int = 3) -> void:
	for b in blades:
		var bx := x + (b - blades / 2.0) * 12.0
		var hw := (10.0 - b) * 0.5 + 3.0
		var left := PackedVector2Array()
		var right := PackedVector2Array()
		for i in 9:
			var f := i / 8.0
			var c := Vector2(bx + sin(_t * 1.6 + f * 3.0 + b) * 14.0 * f, base_y - f * h * (0.8 + 0.2 * b / blades))
			var w := hw * (1.0 - f * 0.55)
			left.append(c + Vector2(-w, 0))
			right.append(c + Vector2(w, 0))
		right.reverse()
		var blade := left + right
		ci.draw_colored_polygon(blade, color.lightened(b * 0.08))
		blade.append(blade[0])
		ci.draw_polyline(blade, Art.INK, 3.0)


func _coral(c: Vector2, s: float, color: Color) -> void:
	var branches := [[0.0, 1.0], [-0.6, 0.7], [0.55, 0.75], [-0.25, 0.5], [0.3, 0.45]]
	for br in branches:
		var a: float = br[0]
		var tip := c + Vector2(sin(a) * 60.0 * s, -cos(a) * 90.0 * br[1] * s)
		Art.limb(ci, Art.curve(c, c.lerp(tip, 0.5) + Vector2(a * 10, 0), tip, 8), 12.0 * s, color)


func _draw_bubbles() -> void:
	for b in _bubbles:
		var c := Vector2(b.x + sin(_t * 2.0 + b.phase) * 6.0, b.y)
		var r: float = b.r + 1.0
		ci.draw_texture_rect(_bubble_tex, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false, Color(1, 1, 1, 0.85))


func _sign(r: Rect2, label: String, bg: Color, fg: Color, size: int = 40) -> void:
	Art.shape(ci, Art.rrect(r, 10), bg, 4.0, 0.12)
	var lines := label.split("\n")
	var y0 := r.get_center().y - (lines.size() - 1) * size * 0.5 + size * 0.36
	for i in lines.size():
		Art.text(ci, sign_font, Vector2(r.position.x, y0 + i * size), lines[i], size, fg, 8, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)


func _door(r: Rect2, color: Color, round_top: bool = true) -> void:
	var pts := PackedVector2Array()
	if round_top:
		pts.append_array(Art.arc_pts(Vector2(r.get_center().x, r.position.y + r.size.x / 2), r.size.x / 2, r.size.x / 2, PI, TAU, 14))
		pts.append(r.end)
		pts.append(Vector2(r.position.x, r.end.y))
	else:
		pts = Art.rrect(r, 6)
	Art.shape(ci, pts, color, 4.0, 0.15)


func _porthole(c: Vector2, r: float, frame: Color = Color("8a96a3"), glass: Color = Color("bfe6f5")) -> void:
	Art.blob(ci, c, r + 8, r + 8, frame, 4.0)
	Art.blob(ci, c, r, r, glass, 3.0)
	ci.draw_arc(c, r * 0.65, PI * 1.1, PI * 1.5, 8, Color(1, 1, 1, 0.8), 4.0, true)


# ------------------------------------------------------------- locations --

func _pineapple_house() -> void:
	_sea_sky()
	# Distant neighbours
	Art.shape(ci, Art.smooth(PackedVector2Array([Vector2(1010, 560), Vector2(1030, 470), Vector2(1100, 440), Vector2(1170, 470), Vector2(1190, 560)]), 5), Color("8d6b4f").lerp(Color("8fd6ee"), 0.45), 3.0)
	Art.shape(ci, Art.rrect(Rect2(40, 400, 110, 170), 20), Color("7a8ea0").lerp(Color("8fd6ee"), 0.45), 3.0)
	_sand()
	# Leaves
	var lc := Vector2(560, 200)
	for i in 7:
		var a := -PI / 2 + (i - 3) * 0.32 
		var tip := lc + Vector2(cos(a), sin(a)) * (170.0 - absf(i - 3) * 18.0)
		var side := Vector2(-sin(a), cos(a)) * 20.0
		var leaf := PackedVector2Array([lc + side, lc.lerp(tip, 0.5) + side * 1.2, tip, lc.lerp(tip, 0.5) - side * 1.2, lc - side])
		Art.shape(ci, Art.smooth(leaf, 4), Color("4fae3c").darkened(0.08 * (i % 2)), 4.0, 0.1)
	# Pineapple body
	var body := Art.smooth(PackedVector2Array([Vector2(560, 210), Vector2(690, 260), Vector2(730, 420), Vector2(690, 570),
		Vector2(560, 600), Vector2(430, 570), Vector2(390, 420), Vector2(430, 260)]), 6)
	Art.shape(ci, body, Color("f39a2b"), 5.0, 0.15, Vector2(-30, -20))
	# Cross-hatch skin clipped to the body
	for i in range(-6, 8):
		var x0 := 400.0 + i * 60.0
		for seg in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([Vector2(x0, 200), Vector2(x0 + 260, 620)]), body):
			Art.stroke(ci, seg, 3.0, Color("b8661a"))
		for seg in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([Vector2(x0 + 260, 200), Vector2(x0, 620)]), body):
			Art.stroke(ci, seg, 3.0, Color("b8661a"))
	Art.outline(ci, body, 5.0)
	_porthole(Vector2(480, 330), 36)
	_porthole(Vector2(640, 430), 30)
	_door(Rect2(520, 470, 90, 125), Color("6f8fa8"))
	Art.blob(ci, Vector2(596, 540), 6, 6, Color("e8c040"), 2.5)
	# Mailbox
	Art.limb(ci, PackedVector2Array([Vector2(830, 600), Vector2(830, 500)]), 8, Color("7a5230"))
	Art.shape(ci, Art.rrect(Rect2(800, 470, 64, 40), 14), Color("6aa7d8"), 4.0, 0.15)


func _pat_rock() -> void:
	_sea_sky(Color("3a86d3"), Color("9adbf0"))
	_sand(570)
	_coral(Vector2(180, 610), 1.0, Color("f27aa0"))
	# The rock
	var rock := Art.smooth(PackedVector2Array([Vector2(420, 600), Vector2(440, 470), Vector2(560, 390), Vector2(700, 380),
		Vector2(830, 440), Vector2(880, 600)]), 6)
	Art.shape(ci, rock, Color("8d6b4f"), 5.0, 0.18, Vector2(-30, -26))
	for s in [Vector2(560, 470), Vector2(720, 450), Vector2(800, 540), Vector2(500, 550)]:
		Art.stroke(ci, Art.curve(s, s + Vector2(20, -10), s + Vector2(40, 4), 6), 3.0, Color("5c4330"))
	Art.text(ci, sign_font, Vector2(980, 560), "PAT LIVES HERE (PROBABLY)", 16, Color.WHITE, 4, HORIZONTAL_ALIGNMENT_CENTER, 220)
	Art.limb(ci, PackedVector2Array([Vector2(1090, 640), Vector2(1090, 575)]), 6, Color("7a5230"))
	Art.shape(ci, Art.rrect(Rect2(975, 530, 230, 44), 6), Color("c79a5b"), 3.5)
	Art.text(ci, sign_font, Vector2(975, 562), "PAT'S ROCK", 26, Color.WHITE, 5, HORIZONTAL_ALIGNMENT_CENTER, 230)


func _squidwerd_house() -> void:
	_sea_sky(Color("2e78c8"), Color("88cfe8"))
	_sand(565, Color("ead593"))
	var stone := Color("4f6f8f")
	# Head
	var head := Art.smooth(PackedVector2Array([Vector2(470, 600), Vector2(455, 330), Vector2(470, 190), Vector2(560, 150),
		Vector2(700, 160), Vector2(760, 230), Vector2(770, 600)]), 4)
	Art.shape(ci, head, stone, 5.0, 0.18, Vector2(-30, -20))
	# Brow, eyes, nose
	Art.shape(ci, Art.rrect(Rect2(470, 250, 290, 38), 14), stone.lightened(0.12), 4.0)
	for x in [530, 690]:
		_porthole(Vector2(x, 330), 30, Color("2f4559"), Color("ffe9a8"))
	var nose := PackedVector2Array([Vector2(605, 290), Vector2(640, 290), Vector2(680, 450), Vector2(565, 450)])
	Art.shape(ci, nose, stone.lightened(0.06), 4.0, 0.15)
	_door(Rect2(570, 480, 110, 120), Color("6b4b33"))
	Art.blob(ci, Vector2(660, 545), 6, 6, Color("e8c040"), 2.5)
	# Ears
	for x in [450, 780]:
		Art.shape(ci, Art.rrect(Rect2(x - 18, 290, 36, 130), 14), stone.darkened(0.05), 4.0)
	# Sculpture garden
	Art.limb(ci, PackedVector2Array([Vector2(960, 605), Vector2(960, 520)]), 14, Color("8a96a3"))
	Art.blob(ci, Vector2(960, 495), 34, 30, Color("a4d4c8"), 4.0, 0.15)
	Art.text(ci, sign_font, Vector2(900, 470), "ART", 22, Color("ffe08a"), 4, HORIZONTAL_ALIGNMENT_CENTER, 120)


func _krusty_crab() -> void:
	_sea_sky()
	_sand(575)
	var wood := Color("b07a45")
	# Lobster-trap building
	var body := Rect2(330, 300, 620, 300)
	Art.shape(ci, Art.rrect(body, 30), wood, 5.0, 0.12)
	for i in 7:
		var y := 330.0 + i * 40.0
		Art.stroke(ci, PackedVector2Array([Vector2(body.position.x + 8, y), Vector2(body.end.x - 8, y)]), 3.0, wood.darkened(0.35))
	# Trap netting roof
	var roof := Art.smooth(PackedVector2Array([Vector2(340, 310), Vector2(400, 200), Vector2(640, 160), Vector2(880, 200), Vector2(940, 310)]), 5)
	Art.fill(ci, roof, Color(0.35, 0.25, 0.15, 0.25))
	for i in 13:
		var x := 340.0 + i * 50.0
		for seg in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([Vector2(x, 140), Vector2(x, 320)]), roof):
			Art.stroke(ci, seg, 3.0, Color("6b4b33"))
	for i in 4:
		var y := 190.0 + i * 32.0
		for seg in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([Vector2(300, y), Vector2(980, y)]), roof):
			Art.stroke(ci, seg, 3.0, Color("6b4b33"))
	Art.outline(ci, roof, 5.0)
	for x in [420, 860]:
		_porthole(Vector2(x, 430), 38)
	_door(Rect2(580, 440, 120, 160), Color("6f8fa8"), false)
	Art.stroke(ci, PackedVector2Array([Vector2(640, 444), Vector2(640, 596)]), 4.0)
	# Sign
	Art.limb(ci, PackedVector2Array([Vector2(1090, 620), Vector2(1090, 300)]), 14, Color("8a5a2b"))
	_sign(Rect2(970, 210, 240, 110), "KRUSTY\nCRAB", Color("e6452f"), Color("ffe08a"), 30)
	Art.text(ci, sign_font, Vector2(330, 290), "THE KRUSTY CRAB", 34, Color("ffe08a"), 8, HORIZONTAL_ALIGNMENT_CENTER, 620)


func _krusty_kitchen() -> void:
	# Tiled wall
	Art.gradient_rect(ci, Rect2(-PAD, -PAD, W + PAD * 2, H + PAD * 2), Color("e9e2c8"), Color("d7cfae"))
	for i in 30:
		var x := -PAD + i * 60.0
		Art.stroke(ci, PackedVector2Array([Vector2(x, -PAD), Vector2(x, 520)]), 2.0, Color(0, 0, 0, 0.08))
	for j in 12:
		Art.stroke(ci, PackedVector2Array([Vector2(-PAD, j * 50.0), Vector2(W + PAD, j * 50.0)]), 2.0, Color(0, 0, 0, 0.08))
	# Wood floor
	ci.draw_colored_polygon(PackedVector2Array([Vector2(-PAD, 540), Vector2(W + PAD, 540), Vector2(W + PAD, H + PAD), Vector2(-PAD, H + PAD)]), Color("9b6a3e"))
	for i in 12:
		var x := -PAD + i * 130.0
		Art.stroke(ci, PackedVector2Array([Vector2(x, 540), Vector2(x - 60, H + PAD)]), 3.0, Color("6b4b33"))
	Art.stroke(ci, PackedVector2Array([Vector2(-PAD, 540), Vector2(W + PAD, 540)]), 4.0)
	# Order window
	Art.shape(ci, Art.rrect(Rect2(80, 120, 300, 200), 12), Color("6b4b33"), 5.0)
	Art.gradient_rect(ci, Rect2(100, 140, 260, 160), Color("2f7fd0"), Color("8fd6ee"))
	Art.outline(ci, PackedVector2Array([Vector2(100, 140), Vector2(360, 140), Vector2(360, 300), Vector2(100, 300)]), 4.0)
	Art.text(ci, sign_font, Vector2(80, 112), "ORDER UP!", 26, Color("e6452f"), 5, HORIZONTAL_ALIGNMENT_CENTER, 300)
	# Porthole
	_porthole(Vector2(1120, 190), 50)
	# Grill
	Art.shape(ci, Art.rrect(Rect2(500, 360, 380, 200), 10), Color("5f646b"), 5.0, 0.2)
	Art.shape(ci, Art.rrect(Rect2(490, 340, 400, 40), 8), Color("3a3d42"), 4.0)
	for i in 3:
		var pc := Vector2(570 + i * 120, 352)
		Art.blob(ci, pc + Vector2(0, -6), 34, 9, Color("6b3a1e"), 3.0)
	# Hood
	var hood := PackedVector2Array([Vector2(470, 160), Vector2(910, 160), Vector2(860, 240), Vector2(520, 240)])
	Art.shape(ci, hood, Color("aab3bd"), 5.0, 0.15)
	Art.limb(ci, PackedVector2Array([Vector2(690, 160), Vector2(690, -PAD)]), 40, Color("aab3bd"))
	# Utensil rack
	Art.stroke(ci, PackedVector2Array([Vector2(960, 330), Vector2(1200, 330)]), 6.0, Color("6b4b33"))
	for i in 4:
		var x := 990.0 + i * 60.0
		Art.limb(ci, PackedVector2Array([Vector2(x, 334), Vector2(x, 400)]), 5, Color("8a96a3"))
		Art.shape(ci, Art.rrect(Rect2(x - 12, 396, 24, 30), 4), Color("aab3bd"), 3.0)
	# Empty hook where the golden spatula belongs
	Art.text(ci, sign_font, Vector2(960, 470), "GOLDEN SPATULA HOOK", 16, Color("e8c040"), 4, HORIZONTAL_ALIGNMENT_CENTER, 260)


func _treedome() -> void:
	_sea_sky(Color("2878c4"), Color("86cfe9"))
	_sand(590)
	var dc := Vector2(640, 600)
	var dome := Art.arc_pts(dc, 520, 520, PI, TAU, 40)
	# Inside: air, grass, tree
	Art.fill(ci, dome, Color("bfe9ff"))
	var grass := PackedVector2Array([Vector2(120, 600), Vector2(1160, 600), Vector2(1160, 560), Vector2(120, 560)])
	for poly in Geometry2D.intersect_polygons(grass, dome):
		Art.fill(ci, poly, Color("7cc95a"))
	Art.limb(ci, Art.curve(Vector2(700, 600), Vector2(690, 420), Vector2(710, 300), 8), 70, Color("8a5a2b"))
	Art.limb(ci, Art.curve(Vector2(705, 380), Vector2(780, 330), Vector2(840, 300), 6), 22, Color("8a5a2b"))
	Art.limb(ci, Art.curve(Vector2(700, 400), Vector2(620, 350), Vector2(560, 330), 6), 20, Color("8a5a2b"))
	for p in [Vector2(700, 230), Vector2(590, 290), Vector2(830, 270), Vector2(760, 190), Vector2(640, 200), Vector2(880, 330), Vector2(530, 340)]:
		Art.blob(ci, p, 80, 64, Color("53a83e"), 4.0, 0.12)
	for a in [Vector2(610, 330), Vector2(760, 250), Vector2(860, 360)]:
		Art.blob(ci, a, 9, 11, Color("8a5530"), 2.5)
	# Picnic table
	Art.shape(ci, Art.rrect(Rect2(300, 500, 160, 18), 4), Color("c48a4f"), 3.5)
	for x in [315, 430]:
		Art.limb(ci, PackedVector2Array([Vector2(x, 518), Vector2(x, 590)]), 8, Color("a26838"))
	# Glass
	Art.fill(ci, dome, Color(1, 1, 1, 0.08))
	ci.draw_arc(dc, 480, PI * 1.15, PI * 1.38, 20, Color(1, 1, 1, 0.6), 10.0, true)
	ci.draw_arc(dc, 520, PI, TAU, 60, Color("5d6f80"), 10.0, true)
	for i in 7:
		var a := PI + PI * (i + 1) / 8.0
		Art.stroke(ci, PackedVector2Array([dc + Vector2(cos(a), sin(a)) * 520, dc + Vector2(cos(a), sin(a)) * 505]), 6.0, Color("5d6f80"))
	# Airlock door
	Art.shape(ci, Art.rrect(Rect2(1110, 470, 60, 130), 10), Color("8a96a3"), 4.0, 0.15)
	Art.blob(ci, Vector2(1140, 520), 16, 16, Color("e8c040"), 3.0)


func _jellyfish_fields() -> void:
	_sea_sky(Color("3a8ed8"), Color("a6e2f2"))
	# Rolling green hills
	for layer in 2:
		var pts := PackedVector2Array()
		var y0 := 470.0 + layer * 70.0
		for i in 25:
			var x := lerpf(-PAD, W + PAD, i / 24.0)
			pts.append(Vector2(x, y0 + sin(x * 0.008 + layer * 2.0) * 40.0))
		pts.append(Vector2(W + PAD, H + PAD))
		pts.append(Vector2(-PAD, H + PAD))
		var col := Color("6cc06a") if layer == 0 else Color("86d175")
		ci.draw_colored_polygon(pts, col)
		Art.stroke(ci, pts.slice(0, 25), 4.0)
	_coral(Vector2(150, 620), 1.1, Color("f2bd4b"))
	_coral(Vector2(1120, 600), 0.9, Color("ef6fa0"))
	_coral(Vector2(950, 640), 0.6, Color("9d6ae0"))


func _jellyfish(c: Vector2, s: float) -> void:
	var pulse := 1.0 + sin(_t * 4.0 + c.x * 0.01) * 0.08
	for k in 4:
		var x := c.x - 16 * s + k * 11 * s
		var pts := PackedVector2Array()
		for j in 7:
			var f := j / 6.0
			pts.append(Vector2(x + sin(_t * 3.0 + f * 4.0 + k) * 5.0 * s, c.y + 10 * s + f * 46.0 * s))
		Art.stroke(ci, pts, 3.0, Color("d86fb0"))
	var bell := Art.arc_pts(c, 32 * s * pulse, 28 * s / pulse, PI, TAU, 18)
	bell.append(c + Vector2(28 * s, 10 * s))
	bell.append(c + Vector2(-28 * s, 10 * s))
	Art.shape(ci, bell, Color(1.0, 0.68, 0.86, 0.9), 3.5, 0.1)
	Art.dot(ci, c + Vector2(-10 * s, -12 * s), 5 * s, Color(1, 1, 1, 0.6))


func _goo_lagoon() -> void:
	_sea_sky(Color("3e93dc"), Color("b3e6f5"))
	_sand(520, Color("f4e2a8"), 10.0)
	# The goo
	var goo := Art.smooth(PackedVector2Array([Vector2(-PAD, 470), Vector2(400, 450), Vector2(560, 500), Vector2(480, 560), Vector2(-PAD, 590)]), 6)
	Art.shape(ci, goo, Color("63c3a5"), 4.0)
	_goo = goo
	# Umbrellas
	for u in [[760, Color("e6452f")], [1030, Color("3d8fe0")]]:
		var x: float = u[0]
		Art.limb(ci, PackedVector2Array([Vector2(x, 600), Vector2(x - 10, 400)]), 6, Color("eeeeee"))
		var top := Art.arc_pts(Vector2(x - 10, 410), 100, 50, PI, TAU, 18)
		Art.shape(ci, top, u[1], 4.0, 0.15)
		for k in 3:
			var a := PI + PI * (k + 1) / 4.0
			Art.stroke(ci, PackedVector2Array([Vector2(x - 10, 360), Vector2(x - 10, 410) + Vector2(cos(a) * 100, sin(a) * 50 + 50)]), 3.0)
	# Lifeguard tower
	for x in [1150, 1230]:
		Art.limb(ci, PackedVector2Array([Vector2(x, 600), Vector2(x + (20 if x < 1200 else -20), 400)]), 10, Color("c48a4f"))
	Art.shape(ci, Art.rrect(Rect2(1140, 340, 110, 70), 8), Color("f2f2ee"), 4.0, 0.12)
	Art.text(ci, sign_font, Vector2(1140, 385), "GUARD", 22, Color("e6452f"), 4, HORIZONTAL_ALIGNMENT_CENTER, 110)
	# Towel
	Art.shape(ci, PackedVector2Array([Vector2(560, 650), Vector2(720, 630), Vector2(740, 680), Vector2(580, 700)]), Color("f5d63b"), 3.5)
	Art.text(ci, sign_font, Vector2(200, 430), "GOO LAGOON", 40, Color("ffe08a"), 8, HORIZONTAL_ALIGNMENT_CENTER, 300)


func _chum_bucket() -> void:
	_sea_sky(Color("1f4f86"), Color("5f8fb5"), false)
	_sand(580, Color("cdbb86"))
	# Bucket building
	var bucket := PackedVector2Array([Vector2(440, 240), Vector2(840, 240), Vector2(800, 600), Vector2(480, 600)])
	Art.shape(ci, bucket, Color("8b97a2"), 5.0, 0.2, Vector2(-30, 0))
	for y in [300, 520]:
		var t0 := inverse_lerp(240, 600, y)
		var x0 := lerpf(440, 480, t0)
		var x1 := lerpf(840, 800, t0)
		Art.shape(ci, Art.rrect(Rect2(x0 - 6, y - 12, x1 - x0 + 12, 24), 6), Color("6d7883"), 4.0)
	Art.shape(ci, Art.ellipse(Vector2(640, 240), 200, 26), Color("5d6872"), 5.0)
	# Handle
	ci.draw_arc(Vector2(640, 250), 230, PI * 1.08, PI * 1.92, 40, Art.INK, 16.0, true)
	ci.draw_arc(Vector2(640, 250), 230, PI * 1.08, PI * 1.92, 40, Color("9aa5b0"), 9.0, true)
	_sign(Rect2(520, 360, 240, 70), "CHUM BUCKET", Color("2f3640"), Color("9ae66e"), 28)
	_door(Rect2(590, 470, 100, 130), Color("3a3d42"), false)
	Art.shape(ci, Art.rrect(Rect2(600, 440, 80, 26), 4), Color("f2f2ee"), 3.0)
	Art.text(ci, sign_font, Vector2(600, 460), "CLOSED", 18, Color("e6452f"), 0, HORIZONTAL_ALIGNMENT_CENTER, 80)
	# Gloomy rocks
	for p in [Vector2(160, 600), Vector2(1100, 610)]:
		Art.blob(ci, p, 110, 60, Color("4c5560"), 4.0, 0.2)


func _boating_school() -> void:
	_sea_sky(Color("3486d6"), Color("9bdcf0"))
	_sand(585)
	var wall := Color("eef1f5")
	# School building
	Art.shape(ci, Art.rrect(Rect2(260, 300, 700, 300), 16), wall, 5.0, 0.1)
	var roof := PackedVector2Array([Vector2(230, 310), Vector2(610, 190), Vector2(990, 310)])
	Art.shape(ci, roof, Color("e6452f"), 5.0, 0.15)
	for x in [340, 480, 740, 880]:
		_porthole(Vector2(x, 420), 34)
	_door(Rect2(560, 450, 100, 150), Color("3d8fe0"))
	_sign(Rect2(430, 320, 360, 64), "BOATING SCHOOL", Color("1f5fa8"), Color.WHITE, 30)
	# Anchor emblem
	var ac := Vector2(610, 255)
	Art.stroke(ci, PackedVector2Array([ac + Vector2(0, -22), ac + Vector2(0, 22)]), 5.0, Color("e8c040"))
	ci.draw_arc(ac + Vector2(0, 6), 18, 0.2, PI - 0.2, 10, Color("e8c040"), 5.0, true)
	Art.blob(ci, ac + Vector2(0, -26), 6, 6, Color("e8c040"), 2.5)
	# Traffic cones
	for x in [1010, 1080, 1150]:
		var cone := PackedVector2Array([Vector2(x, 560), Vector2(x + 18, 620), Vector2(x - 18, 620)])
		Art.shape(ci, cone, Color("f28a2b"), 3.5)
		Art.stroke(ci, PackedVector2Array([Vector2(x - 10, 595), Vector2(x + 10, 595)]), 5.0, Color.WHITE)
	# Lighthouse
	Art.shape(ci, PackedVector2Array([Vector2(120, 600), Vector2(140, 330), Vector2(180, 330), Vector2(200, 600)]), Color("f2f2ee"), 4.0)
	for y in [400, 480, 560]:
		Art.stroke(ci, PackedVector2Array([Vector2(130, y), Vector2(190, y)]), 12.0, Color("e6452f"))
	Art.shape(ci, Art.rrect(Rect2(128, 290, 64, 44), 8), Color("ffe08a"), 4.0)


# ------------------------------------------------------------ moving bits --

func _weathervane() -> void:
	Art.limb(ci, PackedVector2Array([Vector2(660, 384), Vector2(660, 300)]), 5, Color("6d6d6d"))
	var xf := Transform2D(sin(_t * 0.7) * 0.6, Vector2(660, 300))
	var arrow := PackedVector2Array([xf * Vector2(-40, -4), xf * Vector2(28, -4), xf * Vector2(28, -12), xf * Vector2(46, 0),
		xf * Vector2(28, 12), xf * Vector2(28, 4), xf * Vector2(-40, 4)])
	Art.shape(ci, arrow, Color("d24a3a"), 3.0)
	Art.blob(ci, Vector2(660, 300), 6, 6, Color("e8c040"), 2.5)


func _steam() -> void:
	for i in 3:
		var pc := Vector2(570 + i * 120, 352)
		for k in 3:
			var sx := pc.x - 16 + k * 16
			var steam := PackedVector2Array()
			for s in 6:
				var f := s / 5.0
				steam.append(Vector2(sx + sin(_t * 3.0 + f * 5.0 + k) * 6.0, pc.y - 14 - f * 50.0))
			Art.stroke(ci, steam, 3.0, Color(1, 1, 1, 0.45))


func _goo_waves() -> void:
	for i in 4:
		var y := 480.0 + i * 25.0
		var wave := PackedVector2Array()
		for k in 8:
			wave.append(Vector2(-40 + k * 50.0 + sin(_t * 2.0 + k + i) * 6.0, y + sin(_t * 2.0 + k) * 3.0))
		for seg in Geometry2D.intersect_polyline_with_polygon(wave, _goo):
			Art.stroke(ci, seg, 3.0, Color(1, 1, 1, 0.5))
