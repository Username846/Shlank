class_name Props
## Everything a character can hold (HOLD who prop): the ids, the editor categories and the drawings.
## Drawings use a local frame: the hand is at (0, 0) and "up" (away from the arm) is -y.

const CATEGORIES := [
	["Food", ["patty", "burger", "hot_dog", "pizza", "sandwich", "taco", "cake", "cupcake", "pie", "cookie", "donut",
		"bread", "pretzel", "cheese", "apple", "banana", "strawberry", "watermelon", "carrot", "potato", "mushroom",
		"egg", "fish", "chicken", "candy", "lollipop", "cotton_candy", "candy_cane", "popcorn", "ice_cream"]],
	["Drinks", ["milkshake", "lemonade", "smoothie", "tropical_drink", "juice_box", "soda_can", "baby_bottle", "bottle",
		"coffee", "mug", "teacup", "ketchup", "sauce"]],
	["Kitchen", ["spatula", "golden_spatula", "fork", "spoon", "ladle", "whisk", "rolling_pin", "frying_pan", "bowl",
		"plate", "tray", "jar", "coffee_can"]],
	["Tools", ["hammer", "wrench", "screwdriver", "plunger", "shovel", "rake", "broom", "mop", "bucket", "watering_can",
		"spray_bottle", "paintbrush", "tape", "rope", "flashlight", "lantern", "magnifying_glass", "grabber", "key",
		"toolbox"]],
	["Music", ["clarinet", "guitar", "violin", "trumpet", "drumsticks", "tambourine", "maracas", "triangle", "bell",
		"whistle", "microphone", "megaphone"]],
	["Gadgets", ["phone", "walkie_talkie", "remote", "game_controller", "camera", "binoculars", "laser_pointer",
		"detector", "beeper", "dragon_radar", "vacuum", "calculator", "alarm_clock", "light_bulb", "test_tube", "beaker"]],
	["Paper & Books", ["book", "notebook", "journal", "comic_book", "newspaper", "letter", "envelope", "map",
		"treasure_map", "scroll", "poem", "contract", "receipt", "tickets", "clipboard", "sign", "painting",
		"picture_frame", "pen", "pencil", "crayon", "marker", "package", "gift", "box"]],
	["Treasure", ["money", "coin", "money_bag", "gem", "crystal", "locket", "necklace", "ring", "crown", "trophy",
		"medal", "keychain", "golden_poke_ball", "moon_stone", "dragon_ball"]],
	["Sports & Toys", ["ball", "beach_ball", "baseball", "baseball_bat", "baseball_glove", "football", "basketball",
		"dodgeball", "tennis_racket", "foam_finger", "balloon", "kite", "yo_yo", "teddy_bear", "doll", "rubber_duck",
		"bubble_wand", "jump_rope", "fishing_rod", "net"]],
	["Adventure", ["sword", "spear", "shield", "bow", "wand", "star_wand", "staff", "orb", "potion", "poke_ball",
		"torch", "skull", "magic_lamp"]],
	["Everyday", ["toothbrush", "comb", "hand_mirror", "perfume", "sunscreen", "soap", "towel", "pillow", "blanket",
		"umbrella", "suitcase", "purse", "sack", "paper_bag", "basket", "candle", "scarf", "glasses"]],
	["Nature", ["flower", "rose", "bouquet", "potted_plant", "leaf", "pinecone", "seashell", "rock", "bone", "worm",
		"feather", "acorn"]],
]
## Props whose drawing moves, so the puppet keeps redrawing while one is held.
const ANIMATED := ["golden_spatula", "detector", "fishing_rod", "candle", "torch", "lantern", "wand", "star_wand", "orb",
	"crystal", "bubble_wand", "light_bulb"]

static var _ci: CanvasItem
static var _xf: Transform2D
static var _t := 0.0
## How many props have been drawn (lets tools check that every character can hold things).
static var draw_count := 0


## Every prop id, in category order.
static func ids() -> Array:
	var out := []
	for c in CATEGORIES:
		out.append_array(c[1])
	return out


static func has(id: String) -> bool:
	return id in ids()


static func category_of(id: String) -> String:
	for c in CATEGORIES:
		if id in c[1]:
			return c[0]
	return ""


static func label(id: String) -> String:
	if id in ["", "none"]:
		return "Nothing"
	return id.replace("poke_ball", "poké_ball").replace("_", " ").capitalize()


static func animated(id: String) -> bool:
	return id in ANIMATED


# ------------------------------------------------------------- helpers --

static func _p(pts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for v in pts:
		out.append(_xf * v)
	return out


static func _tp(pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for v in pts:
		out.append(_xf * v)
	return out


static func _poly(pts: Array, col: Color, w: float = 3.0, shade: float = 0.0) -> void:
	Art.shape(_ci, _p(pts), col, w, shade)


static func _rect(x: float, y: float, w: float, h: float, col: Color, r: float = 4.0, ow: float = 3.0, shade: float = 0.0) -> void:
	Art.shape(_ci, _tp(Art.rrect(Rect2(x, y, w, h), r)), col, ow, shade)


static func _ov(x: float, y: float, rx: float, ry: float, col: Color, ow: float = 3.0, shade: float = 0.0, rot: float = 0.0) -> void:
	Art.blob(_ci, _xf * Vector2(x, y), rx, ry, col, ow, shade, _xf.get_rotation() + rot)


static func _stick(a: Vector2, b: Vector2, width: float, col: Color) -> void:
	Art.limb(_ci, _p([a, b]), width, col)


static func _line(pts: Array, w: float = 3.0, col: Color = Art.INK) -> void:
	Art.stroke(_ci, _p(pts), w, col)


static func _curve(a: Vector2, c: Vector2, b: Vector2, w: float = 3.0, col: Color = Art.INK) -> void:
	Art.stroke(_ci, _tp(Art.curve(a, c, b, 12)), w, col)


static func _dot(x: float, y: float, r: float, col: Color) -> void:
	Art.dot(_ci, _xf * Vector2(x, y), r, col)


static func _text(x: float, y: float, s: String, size: int, col: Color) -> void:
	Art.text(_ci, ThemeDB.fallback_font, _xf * Vector2(x, y), s, size, col, 0, HORIZONTAL_ALIGNMENT_LEFT)


static func _star(x: float, y: float, r: float, col: Color, ow: float = 3.0) -> void:
	Art.shape(_ci, _tp(Art.star(Vector2(x, y), r)), col, ow)


static func _sparkle(x: float, y: float, s: float) -> void:
	var c := _xf * Vector2(x, y)
	Art.stroke(_ci, PackedVector2Array([c + Vector2(-s, 0), c + Vector2(s, 0)]), 2.5, Color.WHITE)
	Art.stroke(_ci, PackedVector2Array([c + Vector2(0, -s), c + Vector2(0, s)]), 2.5, Color.WHITE)


static func _bottle(col: Color, cap: Color, label_col: Color) -> void:
	_rect(-6, -62, 12, 14, col.lightened(0.15), 3)
	_rect(-6, -66, 12, 6, cap, 2)
	_poly([Vector2(-6, -50), Vector2(6, -50), Vector2(13, -36), Vector2(13, 8), Vector2(-13, 8), Vector2(-13, -36)], col, 3, 0.15)
	_rect(-13, -24, 26, 16, label_col, 1, 2)


static func _cup(x: float, y: float, w: float, h: float, col: Color) -> void:
	_poly([Vector2(x - w / 2, y - h), Vector2(x + w / 2, y - h), Vector2(x + w * 0.4, y), Vector2(x - w * 0.4, y)], col, 3, 0.15)


static func _ball(r: float, col: Color, shade: float = 0.2) -> void:
	_ov(0, -r - 2, r, r, col, 3, shade)


static func _book(col: Color, pages: Color = Color("f6f1e1")) -> void:
	_rect(-22, -50, 44, 54, pages, 3)
	_rect(-24, -54, 44, 54, col, 3, 3, 0.15)
	_line([Vector2(-18, -54), Vector2(-18, 0)], 2.5, col.darkened(0.35))


static func _paper(col: Color = Color("fbf8ee"), w: float = 34.0, h: float = 44.0) -> void:
	_rect(-w / 2, -h - 4, w, h, col, 2)


static func _lines(x0: float, x1: float, y0: float, n: int, gap: float, col: Color = Color(0.45, 0.45, 0.5)) -> void:
	for i in n:
		_line([Vector2(x0, y0 + i * gap), Vector2(x1, y0 + i * gap)], 2.0, col)


static func _handle(length: float, col: Color = Color("8a5a2b"), width: float = 6.0) -> void:
	_stick(Vector2(0, 14), Vector2(0, -length), width, col)


# ------------------------------------------------------------- drawing --

## Draws prop `id` held at `hand`, pointing along `up`. `t` is the puppet clock for animated props.
static func draw(ci: CanvasItem, id: String, hand: Vector2, up: Vector2, t: float = 0.0) -> void:
	draw_count += 1
	_ci = ci
	_xf = Transform2D(up.angle() + PI / 2, hand)
	_t = t
	var gold := Color(1.0, 0.82, 0.2)
	var metal := Color(0.74, 0.76, 0.8)
	var wood := Color("8a5a2b")
	match id:
		# ---------------------------------------------------- food
		"patty":
			_ov(0, -26, 26, 12, Color(0.95, 0.72, 0.35), 3, 0.15)
			_ov(0, -16, 27, 6, Color(0.45, 0.25, 0.12))
			_ov(0, -20, 28, 3, Color(0.4, 0.8, 0.3), 2)
			_ov(0, -9, 25, 7, Color(0.95, 0.72, 0.35))
		"burger":
			_ov(0, -8, 24, 7, Color("e0a24f"))
			_ov(0, -16, 26, 6, Color("6b3a1e"))
			_poly([Vector2(-26, -20), Vector2(26, -20), Vector2(20, -14), Vector2(-20, -14)], Color("f2c230"), 2)
			_ov(0, -22, 27, 3, Color("58b847"), 2)
			_ov(0, -32, 25, 13, Color("e9a64e"), 3, 0.15)
			for x in [-10, 0, 10]:
				_dot(x, -38, 1.8, Color("fff2c8"))
		"hot_dog":
			_ov(0, -22, 30, 12, Color("eab062"), 3, 0.1)
			_ov(0, -26, 34, 7, Color("c8523a"), 3)
			_curve(Vector2(-24, -27), Vector2(-12, -33), Vector2(0, -27), 3, Color("f5d31c"))
			_curve(Vector2(0, -27), Vector2(12, -21), Vector2(24, -27), 3, Color("f5d31c"))
		"pizza":
			_poly([Vector2(-26, -50), Vector2(26, -50), Vector2(0, 6)], Color("f3c45a"), 3)
			_ov(0, -50, 27, 6, Color("c98a3c"))
			for c in [Vector2(-8, -38), Vector2(8, -40), Vector2(0, -22)]:
				_ov(c.x, c.y, 5, 5, Color("c43a2b"), 2)
		"sandwich":
			_poly([Vector2(-26, -10), Vector2(26, -10), Vector2(0, -44)], Color("f1d9a0"), 3)
			_line([Vector2(-22, -14), Vector2(22, -14)], 4, Color("6cc04a"))
			_line([Vector2(-18, -18), Vector2(18, -18)], 4, Color("e8526a"))
			_poly([Vector2(-26, -10), Vector2(26, -10), Vector2(26, -4), Vector2(-26, -4)], Color("e6c27e"), 3)
		"taco":
			_poly(Array(Art.arc_pts(Vector2(0, -12), 28, 26, PI, TAU, 14)), Color("6cc04a"), 2)
			_ov(-8, -30, 5, 4, Color("d9452e"), 2)
			_ov(8, -30, 5, 4, Color("f2c230"), 2)
			_poly(Array(Art.arc_pts(Vector2(0, -12), 26, 22, PI, TAU, 14)), Color("f0c45c"), 3, 0.1)
		"cake":
			_rect(-30, -6, 60, 6, Color("d9dde3"), 2)
			_rect(-24, -40, 48, 34, Color("f7c6d9"), 4, 3, 0.15)
			_rect(-24, -42, 48, 12, Color("fff5f8"), 5)
			for x in [-14, 0, 14]:
				_ov(x, -30, 4, 6, Color("fff5f8"), 0)
			_ov(0, -48, 6, 6, Color("d8352a"))
		"cupcake":
			_poly([Vector2(-16, -22), Vector2(16, -22), Vector2(11, 2), Vector2(-11, 2)], Color("e07fa6"), 3)
			_ov(0, -30, 18, 12, Color("fff3d6"), 3, 0.1)
			_ov(0, -40, 10, 8, Color("fff3d6"), 3)
			_ov(0, -50, 5, 5, Color("d8352a"))
		"pie":
			_ov(0, -18, 30, 12, Color("e8b866"), 3, 0.15)
			_ov(0, -22, 24, 7, Color("8c2f4b"), 2)
			for x in [-14, 0, 14]:
				_line([Vector2(x - 6, -27), Vector2(x + 6, -17)], 3, Color("f3cc7e"))
		"cookie":
			_ov(0, -22, 22, 22, Color("d9a35e"), 3, 0.15)
			for c in [Vector2(-8, -30), Vector2(7, -26), Vector2(-3, -14), Vector2(10, -12), Vector2(-12, -18)]:
				_dot(c.x, c.y, 3.2, Color("5a341c"))
		"donut":
			_ov(0, -24, 24, 22, Color("e0a24f"), 3)
			_ov(0, -25, 21, 18, Color("f58ab4"), 0)
			_ov(0, -24, 8, 7, Color("1a1a1a", 0.0), 3)
			for c in [Vector2(-12, -34), Vector2(10, -36), Vector2(14, -18), Vector2(-14, -16)]:
				_line([c, c + Vector2(4, 2)], 3, Color("6be0ff"))
		"bread":
			_ov(0, -22, 34, 16, Color("d99a4e"), 3, 0.15, 0.1)
			for x in [-14, 0, 14]:
				_line([Vector2(x - 4, -32), Vector2(x + 6, -16)], 3, Color("f3d29a"))
		"pretzel":
			for s in [-1, 1]:
				_ov(s * 10, -26, 12, 14, Color(0, 0, 0, 0), 7)
			_curve(Vector2(-20, -24), Vector2(0, -46), Vector2(20, -24), 9, Art.INK)
			_curve(Vector2(-20, -24), Vector2(0, -46), Vector2(20, -24), 5, Color("b5652c"))
			for s in [-1, 1]:
				Art.stroke(_ci, _tp(Art.ellipse(Vector2(s * 10, -26), 12, 14, 24)), 5, Color("b5652c"))
		"cheese":
			_poly([Vector2(-26, -4), Vector2(24, -4), Vector2(24, -26), Vector2(-26, -14)], Color("f7cf3d"), 3, 0.1)
			for c in [Vector2(-10, -10), Vector2(8, -16), Vector2(16, -8)]:
				_ov(c.x, c.y, 3.5, 3, Color("d9a91a"), 0)
		"apple":
			_ov(0, -22, 19, 18, Color("d8352a"), 3, 0.2)
			_line([Vector2(0, -38), Vector2(2, -48)], 3, Color("6b3a1e"))
			_ov(8, -46, 7, 3.5, Color("58b847"), 2, 0.0, -0.5)
		"banana":
			var outer := Art.curve(Vector2(-20, -4), Vector2(-26, -52), Vector2(14, -60), 12)
			var inner := Art.curve(Vector2(14, -60), Vector2(-12, -46), Vector2(-10, -4), 12)
			var pts := Array(outer)
			pts.append_array(Array(inner))
			_poly(pts, Color("f7d93d"), 3, 0.1)
			_dot(14, -60, 3.5, Color("5a3a1a"))
		"strawberry":
			_poly([Vector2(-16, -34), Vector2(16, -34), Vector2(10, -14), Vector2(0, -2), Vector2(-10, -14)], Color("e23b45"), 3, 0.15)
			_star(0, -36, 10, Color("58b847"), 2)
			for c in [Vector2(-7, -26), Vector2(5, -24), Vector2(-1, -14), Vector2(8, -30)]:
				_dot(c.x, c.y, 1.6, Color("ffe68a"))
		"watermelon":
			_poly(Array(Art.arc_pts(Vector2(0, -36), 30, 30, 0, PI, 14)), Color("3c8c3a"), 3)
			_poly(Array(Art.arc_pts(Vector2(0, -36), 26, 25, 0, PI, 14)), Color("f2556a"), 0)
			for x in [-12, 0, 12]:
				_dot(x, -26, 2.5, Color("2a1a1a"))
		"carrot":
			_poly([Vector2(-9, -44), Vector2(9, -44), Vector2(0, 8)], Color("f58a23"), 3, 0.1)
			for a in [-0.4, 0.0, 0.4]:
				_line([Vector2(0, -44), Vector2(sin(a) * 16, -44 - cos(a) * 16)], 4, Color("58b847"))
		"potato":
			_ov(0, -20, 22, 15, Color("c79a5b"), 3, 0.2, 0.2)
			for c in [Vector2(-8, -24), Vector2(6, -16), Vector2(10, -26)]:
				_dot(c.x, c.y, 2, Color("8c6634"))
		"mushroom":
			_rect(-8, -24, 16, 26, Color("fbf1dc"), 6)
			_poly(Array(Art.arc_pts(Vector2(0, -22), 28, 26, PI, TAU, 16)), Color("e23b2e"), 3, 0.1)
			for c in [Vector2(-12, -34), Vector2(10, -36), Vector2(0, -44)]:
				_ov(c.x, c.y, 5, 4, Color.WHITE, 0)
		"egg":
			_ov(0, -24, 16, 21, Color("fbf6ea"), 3, 0.15)
			for c in [Vector2(-6, -30), Vector2(6, -20), Vector2(-4, -14)]:
				_ov(c.x, c.y, 4, 3, Color("6cc04a"), 0)
		"fish":
			_ov(0, -22, 26, 13, Color("6aa9d9"), 3, 0.15)
			_poly([Vector2(22, -22), Vector2(38, -34), Vector2(38, -10)], Color("6aa9d9"), 3)
			_dot(-14, -25, 3, Art.INK)
		"chicken":
			_stick(Vector2(0, 8), Vector2(0, -14), 7, Color("f6ecd8"))
			_ov(0, -30, 18, 20, Color("c9782e"), 3, 0.2)
		"candy":
			_ov(0, -22, 14, 12, Color("38a3e8"), 3, 0.1)
			_poly([Vector2(-14, -22), Vector2(-28, -32), Vector2(-28, -12)], Color("38a3e8"), 3)
			_poly([Vector2(14, -22), Vector2(28, -32), Vector2(28, -12)], Color("38a3e8"), 3)
			_line([Vector2(-6, -30), Vector2(6, -14)], 3, Color.WHITE)
		"lollipop":
			_line([Vector2(0, 12), Vector2(0, -40)], 4, Color.WHITE)
			_ov(0, -56, 18, 18, Color("f04f8a"), 3)
			Art.stroke(_ci, _tp(Art.curve(Vector2(0, -56), Vector2(14, -68), Vector2(6, -46), 10)), 4, Color.WHITE)
		"cotton_candy":
			_line([Vector2(0, 12), Vector2(0, -36)], 5, Color("f4f0e6"))
			_ov(0, -56, 26, 24, Color("ff9ccd"), 3, 0.1)
			_ov(-12, -64, 12, 10, Color("ffb8dc"), 0)
		"candy_cane":
			_stick(Vector2(0, 14), Vector2(0, -40), 8, Color.WHITE)
			Art.stroke(_ci, _tp(Art.arc_pts(Vector2(12, -40), 12, 12, PI, TAU, 10)), 14, Art.INK)
			Art.stroke(_ci, _tp(Art.arc_pts(Vector2(12, -40), 12, 12, PI, TAU, 10)), 8, Color.WHITE)
			for i in 4:
				_line([Vector2(-4, 6 - i * 13), Vector2(4, 0 - i * 13)], 3, Color("e0353a"))
		"popcorn":
			for c in [Vector2(-12, -46), Vector2(0, -50), Vector2(12, -46), Vector2(-6, -40), Vector2(6, -42)]:
				_ov(c.x, c.y, 8, 7, Color("fff3c4"), 2)
			_poly([Vector2(-18, -40), Vector2(18, -40), Vector2(13, 6), Vector2(-13, 6)], Color.WHITE, 3)
			for x in [-9, 0, 9]:
				_line([Vector2(x, -38), Vector2(x * 0.75, 4)], 4, Color("e0353a"))
		"ice_cream":
			_poly([Vector2(-12, -14), Vector2(12, -14), Vector2(0, 14)], Color("e3a95c"), 3)
			_line([Vector2(-6, -8), Vector2(4, 4)], 2, Color("b07a3a"))
			_ov(0, -22, 15, 12, Color("f7a7c4"), 3, 0.1)
			_ov(0, -40, 13, 11, Color("7a4a2a"), 3, 0.1)
			_dot(0, -54, 5, Color("d8352a"))
		# ---------------------------------------------------- drinks
		"milkshake":
			_line([Vector2(4, -50), Vector2(10, -72)], 4, Color("e0353a"))
			_ov(0, -48, 15, 8, Color("fff5f8"), 3)
			_cup(0, 6, 30, 52, Color("f7c6d9"))
			_dot(0, -58, 4.5, Color("d8352a"))
		"lemonade":
			_cup(0, 6, 28, 50, Color(1.0, 0.94, 0.55, 0.9))
			_line([Vector2(4, -44), Vector2(10, -64)], 3, Color("ff7aa8"))
			_ov(-12, -42, 8, 8, Color("f7e04a"), 2)
		"smoothie":
			_cup(0, 6, 28, 46, Color("f58ab4"))
			_ov(0, -40, 14, 5, Color("ffc1d8"), 2)
			_line([Vector2(-2, -42), Vector2(-8, -64)], 3, Color("6be0ff"))
		"tropical_drink":
			_poly([Vector2(-18, -40), Vector2(18, -40), Vector2(4, -12), Vector2(-4, -12)], Color("ffa64d"), 3)
			_line([Vector2(0, -12), Vector2(0, 6)], 3, Art.INK)
			_ov(0, 6, 10, 3, Color("cfe8ff"), 2)
			_poly([Vector2(6, -40), Vector2(22, -56), Vector2(28, -40)], Color("e8526a"), 2)
			_line([Vector2(14, -40), Vector2(14, -54)], 2, Art.INK)
		"juice_box":
			_rect(-14, -40, 28, 42, Color("ffb13d"), 3, 3, 0.1)
			_ov(0, -22, 8, 8, Color("f04f2a"), 2)
			_line([Vector2(6, -40), Vector2(10, -58)], 3, Color.WHITE)
		"soda_can":
			_rect(-13, -44, 26, 46, Color("d8352a"), 5, 3, 0.15)
			_line([Vector2(-10, -26), Vector2(10, -18)], 4, Color.WHITE)
			_ov(0, -44, 12, 3, metal, 2)
		"baby_bottle":
			_ov(0, -48, 7, 9, Color("e8a46b"), 2)
			_rect(-12, -40, 24, 6, Color("6aa9d9"), 2)
			_rect(-11, -34, 22, 38, Color(1, 1, 1, 0.92), 5)
			_rect(-9, -16, 18, 18, Color("f6f1e1"), 3, 0)
		"bottle":
			_bottle(Color(0.42, 0.25, 0.12, 0.92), Color("c9a13a"), Color("f2e2b0"))
		"coffee":
			_cup(0, 6, 26, 40, Color.WHITE)
			_rect(-14, -36, 28, 6, Color("6b3a1e"), 2)
			_rect(-12, -20, 24, 12, Color("a46a3c"), 1, 0)
			for x in [-5, 5]:
				_curve(Vector2(x, -40), Vector2(x + 6, -50), Vector2(x, -60), 2, Color(1, 1, 1, 0.8))
		"mug":
			_ov(16, -20, 9, 11, Color(0, 0, 0, 0), 6)
			_ov(16, -20, 9, 11, Color(0, 0, 0, 0), 0)
			Art.stroke(_ci, _tp(Art.ellipse(Vector2(16, -20), 9, 11, 20)), 5, Color("3a7fd5"))
			_rect(-16, -40, 32, 40, Color("3a7fd5"), 5, 3, 0.15)
		"teacup":
			_ov(0, 0, 22, 5, Color.WHITE, 3)
			Art.stroke(_ci, _tp(Art.ellipse(Vector2(18, -12), 7, 7, 16)), 4, Art.INK)
			_poly(Array(Art.arc_pts(Vector2(0, -20), 18, 18, 0, PI, 12)), Color.WHITE, 3, 0.1)
			_line([Vector2(-10, -12), Vector2(10, -12)], 3, Color("6aa9d9"))
		"ketchup":
			_bottle(Color("d8352a"), Color.WHITE, Color("fbf6ea"))
		"sauce":
			_rect(-14, -52, 28, 8, Color("2a2a2a"), 3)
			_rect(-15, -46, 30, 50, Color("8c2f1f"), 7, 3, 0.15)
			_rect(-12, -32, 24, 16, Color("f2e2b0"), 3, 2)
		# ---------------------------------------------------- kitchen
		"spatula":
			_handle(36, Color("2a2a2a"))
			_rect(-13, -72, 26, 36, metal, 4, 3)
			for x in [-6, 0, 6]:
				_line([Vector2(x, -66), Vector2(x, -44)], 2.5, metal.darkened(0.35))
		"golden_spatula":
			_handle(36, Color(0.55, 0.32, 0.15), 7)
			_rect(-14, -70, 28, 36, gold, 5)
			for i in 3:
				var x := -7.0 + i * 7.0
				_line([Vector2(x, -64), Vector2(x, -42)], 2.5, gold.darkened(0.4))
			_sparkle(18, -72, 5.0 + sin(_t * 8.0) * 2.0)
		"fork":
			_handle(30, metal, 5)
			_rect(-10, -44, 20, 8, metal, 3, 2)
			for x in [-8, 0, 8]:
				_stick(Vector2(x, -42), Vector2(x, -62), 2, metal)
		"spoon":
			_handle(30, metal, 5)
			_ov(0, -48, 11, 16, metal, 3, 0.15)
		"ladle":
			_handle(48, metal, 5)
			_poly(Array(Art.arc_pts(Vector2(10, -56), 16, 14, 0, PI, 12)), metal, 3, 0.15)
		"whisk":
			_handle(20, Color("e0353a"), 7)
			for s in [-1.0, -0.5, 0.0, 0.5, 1.0]:
				_curve(Vector2(0, -20), Vector2(s * 26, -52), Vector2(0, -70), 2.5, metal.darkened(0.2))
		"rolling_pin":
			_stick(Vector2(0, 16), Vector2(0, 4), 7, wood)
			_stick(Vector2(0, -60), Vector2(0, -72), 7, wood)
			_rect(-10, -60, 20, 64, Color("e2b77a"), 8, 3, 0.15)
		"frying_pan":
			_handle(26, Color("2a2a2a"), 8)
			_ov(0, -58, 30, 30, Color("3a3a42"), 3, 0.2)
			_ov(0, -58, 22, 22, Color("55555f"), 0)
		"bowl":
			_poly(Array(Art.arc_pts(Vector2(0, -26), 28, 26, 0, PI, 14)), Color("e8f0ff"), 3, 0.15)
			_ov(0, -26, 28, 6, Color("f2c94c"), 3)
		"plate":
			_ov(0, -16, 32, 9, Color.WHITE, 3)
			_ov(0, -16, 22, 5, Color("e8eef5"), 2)
		"tray":
			_line([Vector2(0, 8), Vector2(0, -6)], 4, Art.INK)
			_rect(-40, -12, 80, 8, metal, 3, 3)
			_ov(-16, -24, 10, 10, Color("e8526a"), 2)
			_cup(16, -12, 16, 24, Color.WHITE)
		"jar":
			_rect(-15, -54, 30, 10, Color("d8352a"), 3)
			_rect(-17, -46, 34, 48, Color(0.8, 0.92, 1.0, 0.85), 8, 3)
			_rect(-13, -30, 26, 28, Color("e6a33a"), 6, 0)
		"coffee_can":
			_rect(-17, -48, 34, 50, Color("b33a2a"), 3, 3, 0.15)
			_ov(0, -48, 16, 4, metal, 2)
			_rect(-17, -32, 34, 14, Color("f2e2b0"), 1, 2)
		# ---------------------------------------------------- tools
		"hammer":
			_handle(46, wood, 7)
			_rect(-24, -66, 48, 22, Color("6a6f78"), 3, 3, 0.15)
		"wrench":
			_stick(Vector2(0, 14), Vector2(0, -44), 8, metal)
			_ov(0, -54, 14, 12, metal, 3)
			_rect(-5, -70, 10, 16, Color(0, 0, 0, 0), 2, 0)
			_poly([Vector2(-5, -66), Vector2(5, -66), Vector2(5, -50), Vector2(-5, -50)], Color("e9eef5"), 0)
		"screwdriver":
			_stick(Vector2(0, -24), Vector2(0, -62), 4, metal)
			_rect(-8, -26, 16, 38, Color("e0353a"), 6, 3, 0.15)
		"plunger":
			_handle(56, wood, 6)
			_poly(Array(Art.arc_pts(Vector2(0, -56), 22, 24, PI, TAU, 14)), Color("d8352a"), 3, 0.15)
		"shovel":
			_handle(56, wood, 6)
			_rect(-6, 10, 12, 10, Color("2a2a2a"), 3)
			_poly([Vector2(-16, -56), Vector2(16, -56), Vector2(16, -82), Vector2(0, -98), Vector2(-16, -82)], metal, 3, 0.15)
		"rake":
			_handle(80, wood, 5)
			_rect(-26, -88, 52, 8, metal, 2)
			for i in 6:
				_line([Vector2(-22 + i * 9, -88), Vector2(-22 + i * 9, -100)], 3, metal.darkened(0.3))
		"broom":
			_handle(64, wood, 5)
			_poly([Vector2(-8, -64), Vector2(8, -64), Vector2(20, -104), Vector2(-20, -104)], Color("e8c25a"), 3, 0.15)
			_line([Vector2(-10, -70), Vector2(10, -70)], 4, Color("c4392a"))
		"mop":
			_handle(64, Color("6aa9d9"), 5)
			for i in 7:
				var x := -18.0 + i * 6.0
				_curve(Vector2(x * 0.4, -64), Vector2(x, -82), Vector2(x * 1.2, -100), 5, Color("f2efe4"))
		"bucket":
			_poly([Vector2(-22, -36), Vector2(22, -36), Vector2(16, 0), Vector2(-16, 0)], Color("6aa9d9"), 3, 0.15)
			_ov(0, -36, 22, 5, Color("3a7fd5"), 3)
			_curve(Vector2(-22, -34), Vector2(0, -80), Vector2(22, -34), 3, Art.INK)
		"watering_can":
			_poly([Vector2(16, -30), Vector2(44, -54), Vector2(48, -50), Vector2(20, -20)], Color("58b847"), 3)
			_rect(-22, -40, 40, 40, Color("58b847"), 6, 3, 0.15)
			Art.stroke(_ci, _tp(Art.arc_pts(Vector2(-2, -40), 14, 14, PI, TAU, 10)), 5, Art.INK)
		"spray_bottle":
			_rect(-12, -40, 24, 44, Color("6be0ff"), 6, 3, 0.1)
			_rect(-8, -52, 16, 12, Color.WHITE, 2)
			_poly([Vector2(-8, -52), Vector2(14, -54), Vector2(14, -60), Vector2(-8, -62)], Color.WHITE, 3)
			_line([Vector2(-4, -50), Vector2(-14, -40)], 4, Art.INK)
		"paintbrush":
			_handle(40, Color("e0353a"), 5)
			_rect(-5, -52, 10, 12, metal, 2)
			_poly([Vector2(-6, -52), Vector2(6, -52), Vector2(2, -72), Vector2(-2, -72)], Color("3a7fd5"), 3)
		"tape":
			_ov(0, -22, 22, 22, Color("b9bcc2"), 3, 0.15)
			_ov(0, -22, 10, 10, Color("f2efe4"), 3)
			_poly([Vector2(18, -10), Vector2(32, 0), Vector2(30, 6), Vector2(14, -6)], Color("b9bcc2"), 2)
		"rope":
			for i in 3:
				Art.stroke(_ci, _tp(Art.ellipse(Vector2(0, -26 - i * 2), 22 - i * 3, 16 - i * 2, 24)), 6, Art.INK)
				Art.stroke(_ci, _tp(Art.ellipse(Vector2(0, -26 - i * 2), 22 - i * 3, 16 - i * 2, 24)), 3.5, Color("d9b26e"))
			_curve(Vector2(-20, -18), Vector2(-28, 6), Vector2(-12, 18), 5, Color("d9b26e"))
		"flashlight":
			_rect(-8, -40, 16, 50, Color("3a3a42"), 4, 3)
			_poly([Vector2(-8, -40), Vector2(8, -40), Vector2(14, -54), Vector2(-14, -54)], Color("6a6f78"), 3)
			_poly([Vector2(-14, -56), Vector2(14, -56), Vector2(46, -150), Vector2(-46, -150)], Color(1, 0.97, 0.7, 0.28), 0)
		"lantern":
			_curve(Vector2(-10, -50), Vector2(0, -66), Vector2(10, -50), 3)
			_rect(-16, -50, 32, 48, Color("3a3a42"), 4, 3)
			_rect(-11, -44, 22, 36, Color(1.0, 0.85, 0.35), 3, 0)
			_ov(0, -26, 6, 9 + sin(_t * 9.0) * 1.5, Color("ff8a2a"), 0)
		"magnifying_glass":
			_handle(26, Color("6b3a1e"), 7)
			_ov(0, -50, 22, 22, Color(0.75, 0.9, 1.0, 0.6), 6)
			_ov(-6, -56, 6, 4, Color(1, 1, 1, 0.7), 0, 0.0, -0.6)
		"grabber":
			_stick(Vector2(0, 14), Vector2(0, -90), 4, metal)
			_rect(-6, -2, 12, 18, Color("e0353a"), 3)
			_poly([Vector2(0, -90), Vector2(-14, -110), Vector2(-8, -112)], Color("e0353a"), 2)
			_poly([Vector2(0, -90), Vector2(14, -110), Vector2(8, -112)], Color("e0353a"), 2)
		"key":
			Art.stroke(_ci, _tp(Art.ellipse(Vector2(0, -8), 10, 10, 18)), 6, gold.darkened(0.25))
			_stick(Vector2(0, -18), Vector2(0, -48), 4, gold)
			_rect(0, -40, 9, 5, gold, 1, 2)
			_rect(0, -48, 7, 5, gold, 1, 2)
		"toolbox":
			_curve(Vector2(-12, -26), Vector2(0, -42), Vector2(12, -26), 4)
			_rect(-32, -26, 64, 30, Color("d8352a"), 4, 3, 0.15)
			_line([Vector2(-32, -16), Vector2(32, -16)], 3)
		# ---------------------------------------------------- music
		"clarinet":
			_stick(Vector2(0, 30), Vector2(0, -50), 9, Color(0.12, 0.12, 0.14))
			_poly([Vector2(-5, 26), Vector2(5, 26), Vector2(12, 44), Vector2(-12, 44)], Color(0.15, 0.15, 0.17), 3)
			for i in 4:
				_dot(0, -35 + i * 14, 2.5, Color(0.85, 0.85, 0.9))
		"guitar":
			_rect(-5, -96, 10, 62, Color("6b3a1e"), 3, 3)
			_rect(-8, -110, 16, 16, Color("3a2a1a"), 3, 3)
			_ov(0, -12, 26, 22, Color("e08a3a"), 3, 0.15)
			_ov(0, -36, 19, 17, Color("e08a3a"), 3)
			_ov(0, -24, 7, 7, Color("3a2a1a"), 0)
			_line([Vector2(-2, -100), Vector2(-2, -6)], 1.2, Color.WHITE)
			_line([Vector2(2, -100), Vector2(2, -6)], 1.2, Color.WHITE)
		"violin":
			_rect(-4, -92, 8, 44, Color("2a1a10"), 3)
			_ov(0, -16, 16, 14, Color("a8501e"), 3, 0.15)
			_ov(0, -38, 12, 12, Color("a8501e"), 3)
			_line([Vector2(-40, -70), Vector2(40, -10)], 2, Color("d9c48e"))
		"trumpet":
			_line([Vector2(0, 4), Vector2(0, -50)], 6, gold.darkened(0.2))
			_rect(-10, -34, 20, 18, Color(0, 0, 0, 0), 4, 3)
			_poly([Vector2(-4, -50), Vector2(4, -50), Vector2(16, -76), Vector2(-16, -76)], gold, 3, 0.15)
			for x in [-5, 0, 5]:
				_stick(Vector2(x, -26), Vector2(x, -36), 2, gold)
		"drumsticks":
			_stick(Vector2(-6, 12), Vector2(-14, -60), 4, Color("e2b77a"))
			_stick(Vector2(6, 12), Vector2(16, -58), 4, Color("e2b77a"))
		"tambourine":
			_ov(0, -34, 28, 28, Color("f5e6c0"), 5)
			for i in 6:
				var a := i * TAU / 6.0
				_ov(cos(a) * 28, -34 + sin(a) * 28, 6, 3, gold, 2, 0.0, a)
		"maracas":
			_handle(18, Color("6b3a1e"), 6)
			_ov(0, -40, 16, 20, Color("f58a23"), 3, 0.15)
			for c in [Vector2(-6, -46), Vector2(6, -36), Vector2(0, -52)]:
				_dot(c.x, c.y, 3, Color("58b847"))
		"triangle":
			for seg in [[Vector2(0, -70), Vector2(-26, -20)], [Vector2(-26, -20), Vector2(26, -20)], [Vector2(26, -20), Vector2(4, -62)]]:
				_line(seg, 6, Art.INK)
				_line(seg, 3, metal)
			_line([Vector2(0, -8), Vector2(0, -70)], 1.5, Art.INK)
		"bell":
			_handle(14, Color("6b3a1e"), 6)
			_poly([Vector2(-8, -18), Vector2(8, -18), Vector2(14, -40), Vector2(24, -48), Vector2(-24, -48), Vector2(-14, -40)], gold, 3, 0.15)
			_dot(0, -52, 5, gold.darkened(0.3))
		"whistle":
			_rect(-16, -30, 26, 16, metal, 7, 3, 0.15)
			_rect(8, -30, 12, 8, metal, 2, 3)
			_curve(Vector2(-14, -18), Vector2(-24, 6), Vector2(-4, 18), 2, Color("e0353a"))
		"microphone":
			_stick(Vector2(0, 14), Vector2(0, -34), 7, Color("2a2a2a"))
			_ov(0, -46, 14, 14, Color("9aa0aa"), 3, 0.2)
			for i in 3:
				_line([Vector2(-10, -50 + i * 6), Vector2(10, -50 + i * 6)], 1.5, Color("5a5f68"))
		"megaphone":
			_rect(-5, -24, 10, 30, Color("2a2a2a"), 3)
			_poly([Vector2(-8, -24), Vector2(8, -24), Vector2(26, -76), Vector2(-26, -76)], Color("f2a22a"), 3, 0.1)
			_ov(0, -76, 26, 6, Color("fbe7c0"), 3)
		# ---------------------------------------------------- gadgets
		"phone":
			_rect(-13, -50, 26, 50, Color("2a2a33"), 6, 3)
			_rect(-9, -44, 18, 34, Color("8fd3ff"), 2, 0)
			_dot(0, -5, 2.5, Color("6a6f78"))
		"walkie_talkie":
			_line([Vector2(8, -46), Vector2(8, -70)], 4, Art.INK)
			_rect(-13, -48, 26, 50, Color("3a3a42"), 5, 3)
			for i in 3:
				_line([Vector2(-8, -38 + i * 6), Vector2(8, -38 + i * 6)], 2, Color("1a1a1f"))
			_dot(0, -12, 4, Color("e0353a"))
		"remote":
			_rect(-10, -54, 20, 58, Color("3a3a42"), 6, 3)
			_dot(0, -44, 4, Color("e0353a"))
			for i in 3:
				for j in 2:
					_dot(-4 + j * 8, -30 + i * 9, 2.5, Color("cfd4dc"))
		"game_controller":
			_rect(-30, -34, 60, 26, Color("6a6f78"), 12, 3, 0.15)
			_line([Vector2(-20, -21), Vector2(-10, -21)], 4, Art.INK)
			_line([Vector2(-15, -26), Vector2(-15, -16)], 4, Art.INK)
			_dot(14, -24, 4, Color("e0353a"))
			_dot(22, -18, 4, Color("3a7fd5"))
		"camera":
			_rect(-24, -42, 48, 34, Color("2a2a33"), 6, 3)
			_rect(-16, -48, 14, 8, Color("2a2a33"), 2)
			_ov(4, -25, 12, 12, Color("5a6070"), 3)
			_ov(4, -25, 6, 6, Color("8fd3ff"), 0)
			_dot(-16, -36, 3, Color("ffe88a"))
		"binoculars":
			for x in [-11, 11]:
				_rect(x - 9, -48, 18, 40, Color("2a2a33"), 6, 3)
				_ov(x, -48, 8, 4, Color("8fd3ff"), 2)
			_rect(-4, -36, 8, 12, Color("3a3a42"), 2)
		"laser_pointer":
			_rect(-5, -44, 10, 52, metal, 4, 3)
			_dot(0, -12, 3, Color("e0353a"))
			_line([Vector2(0, -46), Vector2(0, -200)], 2, Color(1, 0.1, 0.1, 0.75))
		"detector":
			_rect(-20, -40, 40, 34, Color(0.7, 0.72, 0.75), 6, 3, 0.2)
			_line([Vector2(10, -40), Vector2(18, -72)], 3)
			var blink_on := fmod(_t * 3.0, 1.0) < 0.5
			_dot(18, -74, 6, Color(1, 0.15, 0.1) if blink_on else Color(0.45, 0.05, 0.05))
			_dot(-6, -24, 7, Color(0.2, 0.9, 0.4))
		"beeper":
			_rect(-14, -30, 28, 20, Color("2b2b33"), 4)
			_rect(-9, -26, 18, 8, Color("9ee66e"), 2, 0)
		"dragon_radar":
			_ov(0, -30, 24, 24, Color("e9eef5"), 3, 0.15)
			_ov(0, -30, 17, 17, Color("6ee08a"), 2)
			_line([Vector2(-17, -30), Vector2(17, -30)], 1.5, Color("2f8a4a"))
			_line([Vector2(0, -47), Vector2(0, -13)], 1.5, Color("2f8a4a"))
			_dot(7, -36, 3.5, Color("f5c02a") if fmod(_t * 2.0, 1.0) < 0.6 else Color("6ee08a"))
			_rect(-4, -58, 8, 6, Color("e9eef5"), 2)
		"vacuum":
			_line([Vector2(0, 0), Vector2(0, -24)], 5, Art.INK)
			_rect(-16, -26, 32, 40, Color("3fb34f"), 8, 3, 0.15)
			_curve(Vector2(0, -26), Vector2(30, -50), Vector2(16, -86), 8, Art.INK)
			_curve(Vector2(0, -26), Vector2(30, -50), Vector2(16, -86), 4, Color("6a6f78"))
			_poly([Vector2(6, -84), Vector2(26, -88), Vector2(30, -104), Vector2(2, -100)], Color("6a6f78"), 3)
		"calculator":
			_rect(-18, -50, 36, 52, Color("3a3a42"), 5, 3)
			_rect(-13, -44, 26, 10, Color("b9e6a0"), 2, 0)
			for i in 3:
				for j in 3:
					_rect(-12 + j * 9, -28 + i * 9, 6, 6, Color("cfd4dc"), 1, 0)
		"alarm_clock":
			_ov(-14, -46, 7, 7, Color("e0353a"), 3)
			_ov(14, -46, 7, 7, Color("e0353a"), 3)
			_ov(0, -26, 20, 20, Color("e0353a"), 3, 0.15)
			_ov(0, -26, 15, 15, Color.WHITE, 0)
			_line([Vector2(0, -26), Vector2(0, -37)], 2.5)
			_line([Vector2(0, -26), Vector2(8, -26)], 2.5)
		"light_bulb":
			_rect(-8, -16, 16, 14, metal, 3)
			var glow := 0.75 + sin(_t * 4.0) * 0.15
			_ov(0, -34, 18, 20, Color(1.0, 0.95, 0.5, glow), 3)
			_curve(Vector2(-5, -18), Vector2(0, -36), Vector2(5, -18), 2, Color("c98a1a"))
		"test_tube":
			_rect(-7, -60, 14, 60, Color(0.85, 0.95, 1.0, 0.8), 7, 3)
			_rect(-5, -30, 10, 28, Color("3ad0e0"), 5, 0)
			_rect(-9, -64, 18, 6, Color(0.85, 0.95, 1.0, 0.9), 2, 2)
		"beaker":
			_poly([Vector2(-10, -52), Vector2(10, -52), Vector2(10, -34), Vector2(22, 0), Vector2(-22, 0), Vector2(-10, -34)], Color(0.85, 0.95, 1.0, 0.75), 3)
			_poly([Vector2(-15, -18), Vector2(15, -18), Vector2(20, -3), Vector2(-20, -3)], Color("3a7fd5"), 0)
			for c in [Vector2(-4, -26), Vector2(4, -32)]:
				_ov(c.x, c.y, 3, 3, Color(1, 1, 1, 0.7), 1.5)
		# ---------------------------------------------------- paper & books
		"book":
			_book(Color("3a7fd5"))
		"notebook":
			_rect(-20, -50, 40, 52, Color("f6f1e1"), 3, 3)
			_lines(-14, 16, -40, 5, 8, Color("8fb3e0"))
			for i in 6:
				_ov(-20, -46 + i * 9, 3, 3, metal, 1.5)
		"journal":
			_book(Color("8c4a2a"))
			_rect(-12, -36, 18, 10, Color("f2e2b0"), 2, 2)
		"comic_book":
			_rect(-22, -54, 44, 58, Color("f5e04a"), 2, 3)
			_star(0, -30, 14, Color("e0353a"), 2)
			_rect(-18, -52, 36, 10, Color("3a7fd5"), 1, 0)
		"newspaper":
			_rect(-30, -50, 60, 44, Color("ecebe4"), 2, 3)
			_rect(-26, -46, 52, 8, Color("3a3a42"), 1, 0)
			_rect(-26, -34, 22, 18, Color("b9bcc2"), 1, 0)
			_lines(0, 26, -32, 4, 6)
		"letter", "poem", "contract":
			_paper(Color("fbf8ee") if id != "contract" else Color("f2e8c8"))
			_lines(-11, 11, -40, 4, 7)
			if id == "contract":
				_curve(Vector2(-10, -12), Vector2(0, -20), Vector2(10, -12), 2, Color("3a3fd5"))
			elif id == "poem":
				_ov(10, -14, 4, 4, Color("e8526a"), 0)
		"envelope":
			_rect(-26, -40, 52, 34, Color("fbf8ee"), 2, 3)
			_line([Vector2(-26, -40), Vector2(0, -20), Vector2(26, -40)], 2.5)
			_ov(0, -22, 5, 5, Color("c4392a"), 2)
		"map", "treasure_map":
			var paper := Color("f2dfa6") if id == "treasure_map" else Color("e9f2d8")
			_poly([Vector2(-30, -54), Vector2(-10, -50), Vector2(10, -54), Vector2(30, -50), Vector2(30, -4), Vector2(10, -8), Vector2(-10, -4), Vector2(-30, -8)], paper, 3)
			_line([Vector2(-10, -50), Vector2(-10, -4)], 1.5, paper.darkened(0.3))
			_line([Vector2(10, -54), Vector2(10, -8)], 1.5, paper.darkened(0.3))
			_curve(Vector2(-22, -16), Vector2(0, -50), Vector2(16, -26), 2, Color("c4392a"))
			_line([Vector2(12, -30), Vector2(20, -22)], 3, Color("c4392a"))
			_line([Vector2(20, -30), Vector2(12, -22)], 3, Color("c4392a"))
		"scroll":
			_rect(-18, -56, 36, 52, Color("f2e2b0"), 2, 3)
			_rect(-22, -62, 44, 10, Color("d9c48e"), 5, 3)
			_rect(-22, -8, 44, 10, Color("d9c48e"), 5, 3)
			_lines(-10, 10, -44, 4, 8, Color("8c6634"))
		"receipt":
			_poly([Vector2(-12, -64), Vector2(12, -64), Vector2(12, 0), Vector2(8, -4), Vector2(4, 0), Vector2(0, -4), Vector2(-4, 0), Vector2(-8, -4), Vector2(-12, 0)], Color.WHITE, 2)
			_lines(-8, 8, -56, 6, 8)
		"tickets":
			for i in 2:
				_rect(-22 + i * 6, -40 - i * 8, 40, 22, Color("f5c02a") if i == 0 else Color("e8526a"), 2, 3)
			_lines(-10, 12, -42, 2, 6, Color(0.3, 0.2, 0.2))
		"clipboard":
			_rect(-22, -60, 44, 62, Color("a8743c"), 4, 3)
			_rect(-17, -50, 34, 46, Color.WHITE, 1, 2)
			_rect(-9, -64, 18, 10, metal, 2, 3)
			_lines(-12, 12, -42, 4, 8)
		"sign":
			_handle(40, wood, 5)
			_rect(-36, -82, 72, 44, Color("fbf8ee"), 4, 3)
			_lines(-24, 24, -68, 2, 14, Color("c4392a"))
		"painting", "picture_frame":
			_rect(-30, -60, 60, 50, Color("c9a13a"), 3, 3, 0.15)
			_rect(-23, -53, 46, 36, Color("bfe3ff"), 1, 2)
			if id == "painting":
				_poly([Vector2(-23, -17), Vector2(-6, -38), Vector2(8, -24), Vector2(23, -40), Vector2(23, -17)], Color("6cc04a"), 0)
				_dot(12, -46, 5, Color("f5c02a"))
			else:
				_ov(0, -40, 8, 8, Color("f2c9a0"), 2)
				_ov(0, -20, 14, 8, Color("3a7fd5"), 2)
		"pen", "pencil", "crayon", "marker":
			var col: Color = {"pen": Color("3a3fd5"), "pencil": Color("f5c02a"), "crayon": Color("e0353a"), "marker": Color("2a2a33")}[id]
			_rect(-5, -46, 10, 54, col, 3, 3)
			_poly([Vector2(-5, -46), Vector2(5, -46), Vector2(0, -60)], Color("f2d9a0") if id == "pencil" else col.darkened(0.2), 2)
			if id == "pencil":
				_rect(-5, 4, 10, 8, Color("f58ab4"), 2, 2)
			elif id == "marker":
				_rect(-6, 0, 12, 12, Color("e9eef5"), 2, 2)
		"package":
			_rect(-26, -50, 52, 46, Color("c9935a"), 2, 3, 0.15)
			_line([Vector2(-26, -30), Vector2(26, -30)], 5, Color("e9d8b0"))
			_line([Vector2(-6, -50), Vector2(-6, -4)], 5, Color("e9d8b0"))
		"gift":
			_rect(-24, -44, 48, 40, Color("e8526a"), 3, 3, 0.15)
			_rect(-5, -44, 10, 40, Color("f5c02a"), 0, 0)
			_ov(-9, -50, 9, 6, Color("f5c02a"), 2, 0.0, 0.4)
			_ov(9, -50, 9, 6, Color("f5c02a"), 2, 0.0, -0.4)
		"box":
			_rect(-28, -50, 56, 48, Color("c9935a"), 2, 3, 0.15)
			_line([Vector2(-28, -38), Vector2(28, -38)], 2, Color("8c6634"))
		# ---------------------------------------------------- treasure
		"money":
			_rect(-24, -36, 48, 26, Color(0.55, 0.85, 0.5), 3)
			_text(-6, -16, "$", 18, Color(0.15, 0.45, 0.15))
		"coin":
			_ov(0, -22, 18, 18, gold, 3, 0.2)
			_ov(0, -22, 11, 11, gold.lightened(0.2), 2)
		"money_bag":
			_ov(0, -26, 26, 24, Color("c9a46a"), 3, 0.2)
			_rect(-8, -56, 16, 10, Color("c9a46a"), 3)
			_text(-7, -14, "$", 22, Color("3a6a2a"))
		"gem", "crystal":
			var col := Color("6be0ff") if id == "crystal" else Color("e23b8a")
			if id == "crystal":
				col = col.lightened(0.1 + sin(_t * 3.0) * 0.1)
				_poly([Vector2(0, -66), Vector2(14, -42), Vector2(8, -4), Vector2(-8, -4), Vector2(-14, -42)], col, 3, 0.2)
				_line([Vector2(0, -66), Vector2(0, -4)], 1.5, Color(1, 1, 1, 0.6))
			else:
				_poly([Vector2(-18, -36), Vector2(-8, -46), Vector2(8, -46), Vector2(18, -36), Vector2(0, -8)], col, 3, 0.2)
				_line([Vector2(-18, -36), Vector2(18, -36)], 1.5, Color(1, 1, 1, 0.6))
		"locket":
			_line([Vector2(-4, 6), Vector2(-10, -6), Vector2(-3, -34)], 2.0, Color("c9a13a"))
			Art.shape(_ci, _tp(Art.heart(Vector2(0, -22), 15.0)), Color("f2c14e"), 3.0, 0.15)
			Art.shape(_ci, _tp(Art.heart(Vector2(0, -21), 9.0)), Color("f28cb8"), 2.0)
		"necklace":
			Art.stroke(_ci, _tp(Art.arc_pts(Vector2(0, -20), 18, 26, 0, PI, 16)), 3, gold.darkened(0.2))
			_ov(0, 8, 7, 7, Color("6be0ff"), 2)
		"ring":
			Art.stroke(_ci, _tp(Art.ellipse(Vector2(0, -16), 12, 12, 20)), 7, Art.INK)
			Art.stroke(_ci, _tp(Art.ellipse(Vector2(0, -16), 12, 12, 20)), 4, gold)
			_poly([Vector2(-7, -30), Vector2(0, -38), Vector2(7, -30), Vector2(0, -24)], Color("cfeeff"), 2)
		"crown":
			_poly([Vector2(-26, -8), Vector2(26, -8), Vector2(28, -44), Vector2(14, -28), Vector2(0, -50), Vector2(-14, -28), Vector2(-28, -44)], gold, 3, 0.15)
			for x in [-14, 0, 14]:
				_dot(x, -16, 4, Color("e0353a"))
		"trophy":
			_rect(-16, -6, 32, 10, Color("6b3a1e"), 2)
			_rect(-4, -20, 8, 14, gold, 1, 2)
			for s in [-1, 1]:
				Art.stroke(_ci, _tp(Art.ellipse(Vector2(s * 20, -40), 8, 10, 16)), 5, Art.INK)
			_poly(Array(Art.arc_pts(Vector2(0, -48), 20, 30, 0, PI, 12)), gold, 3, 0.15)
		"medal":
			_poly([Vector2(-12, 6), Vector2(-4, 6), Vector2(4, -22), Vector2(-4, -22)], Color("3a7fd5"), 2)
			_poly([Vector2(12, 6), Vector2(4, 6), Vector2(-4, -22), Vector2(4, -22)], Color("e0353a"), 2)
			_ov(0, -34, 14, 14, gold, 3, 0.15)
			_star(0, -34, 7, gold.lightened(0.3), 1.5)
		"keychain":
			Art.stroke(_ci, _tp(Art.ellipse(Vector2(0, -8), 9, 9, 18)), 3, metal.darkened(0.3))
			_poly([Vector2(-10, -18), Vector2(10, -18), Vector2(14, -42), Vector2(0, -50), Vector2(-14, -42)], Color("9b59d0"), 3)
		"golden_poke_ball", "poke_ball":
			var top := gold if id == "golden_poke_ball" else Color("e0353a")
			var bottom := gold.lightened(0.25) if id == "golden_poke_ball" else Color.WHITE
			_ov(0, -20, 18, 18, bottom, 3)
			_poly(Array(Art.arc_pts(Vector2(0, -20), 18, 18, PI, TAU, 14)), top, 3)
			_line([Vector2(-18, -20), Vector2(18, -20)], 4)
			_ov(0, -20, 6, 6, Color.WHITE, 3)
		"moon_stone":
			_ov(0, -26, 22, 20, Color("c8cde0"), 3, 0.2)
			Art.shape(_ci, _tp(Art.star(Vector2(0, -26), 12, 0.4)), Color("f8f2a0"), 2)
		"dragon_ball":
			_ov(0, -22, 18, 18, Color("ffa62b"), 3, 0.2)
			for c in [Vector2(-5, -26), Vector2(5, -24), Vector2(0, -16), Vector2(0, -30)]:
				_star(c.x, c.y, 3.5, Color("d8352a"), 0)
			_ov(-6, -30, 5, 3, Color(1, 1, 1, 0.6), 0, 0.0, -0.5)
		# ---------------------------------------------------- sports & toys
		"ball":
			_ball(18, Color("e0353a"))
			_line([Vector2(-18, -20), Vector2(18, -20)], 3, Color.WHITE)
		"beach_ball":
			_ball(24, Color.WHITE, 0.1)
			for i in 3:
				var a0 := i * TAU / 3.0
				_poly(Array(Art.arc_pts(Vector2(0, -26), 24, 24, a0, a0 + PI / 3.0, 6)) + [Vector2(0, -26)], [Color("e0353a"), Color("3a7fd5"), Color("f5c02a")][i], 0)
			Art.outline(_ci, _tp(Art.ellipse(Vector2(0, -26), 24, 24, 36)), 3)
		"baseball":
			_ball(13, Color.WHITE, 0.1)
			_curve(Vector2(-8, -24), Vector2(-3, -15), Vector2(-8, -6), 1.6, Color("e0353a"))
			_curve(Vector2(8, -24), Vector2(3, -15), Vector2(8, -6), 1.6, Color("e0353a"))
		"baseball_bat":
			_stick(Vector2(0, 14), Vector2(0, -30), 6, Color("d9a35e"))
			Art.limb(_ci, _p([Vector2(0, -30), Vector2(0, -96)]), 14, Color("d9a35e"))
		"baseball_glove":
			_ov(0, -26, 22, 26, Color("a8501e"), 3, 0.2)
			for x in [-12, -4, 4, 12]:
				_ov(x, -50, 5, 8, Color("a8501e"), 2)
			_line([Vector2(-10, -30), Vector2(10, -30)], 2, Color("5a2a10"))
		"football":
			_ov(0, -24, 24, 14, Color("8c4a2a"), 3, 0.15, 0.6)
			_line([Vector2(-8, -30), Vector2(8, -18)], 2, Color.WHITE)
		"basketball":
			_ball(20, Color("f58a23"))
			_line([Vector2(-20, -22), Vector2(20, -22)], 2)
			_line([Vector2(0, -42), Vector2(0, -2)], 2)
		"dodgeball":
			_ball(22, Color("e0353a"), 0.25)
		"tennis_racket":
			_handle(28, Color("2a2a2a"), 6)
			_ov(0, -62, 20, 28, Color(1, 1, 1, 0.25), 5)
			for i in 5:
				_line([Vector2(-14 + i * 7, -86), Vector2(-14 + i * 7, -38)], 1, Color(1, 1, 1, 0.8))
				_line([Vector2(-18, -80 + i * 10), Vector2(18, -80 + i * 10)], 1, Color(1, 1, 1, 0.8))
			Art.outline(_ci, _tp(Art.ellipse(Vector2(0, -62), 20, 28, 30)), 5, Color("3a7fd5"))
		"foam_finger":
			_rect(-18, -50, 36, 54, Color("f5c02a"), 10, 3, 0.1)
			_rect(-8, -96, 16, 50, Color("f5c02a"), 8, 3)
			_text(-10, -12, "#1", 14, Color("3a3fd5"))
		"balloon":
			_curve(Vector2(0, 8), Vector2(10, -40), Vector2(0, -90), 1.5)
			_ov(0, -116, 24, 28, Color("e8526a"), 3, 0.15)
			_poly([Vector2(-4, -86), Vector2(4, -86), Vector2(0, -92)], Color("e8526a"), 2)
		"kite":
			_curve(Vector2(0, 8), Vector2(20, -60), Vector2(30, -120), 1.5)
			_poly([Vector2(30, -170), Vector2(52, -140), Vector2(30, -110), Vector2(8, -140)], Color("3a7fd5"), 3)
			_line([Vector2(30, -170), Vector2(30, -110)], 1.5)
		"yo_yo":
			_line([Vector2(0, 0), Vector2(0, 34 + sin(_t * 6.0) * 10.0)], 1.5)
			_ov(0, 46 + sin(_t * 6.0) * 10.0, 13, 13, Color("e0353a"), 3, 0.15)
		"teddy_bear":
			for x in [-12, 12]:
				_ov(x, -58, 7, 7, Color("b5753a"), 3)
			_ov(0, -16, 18, 18, Color("b5753a"), 3, 0.15)
			_ov(0, -46, 16, 15, Color("b5753a"), 3, 0.1)
			_ov(0, -42, 7, 5, Color("e8c79a"), 2)
			_dot(-6, -50, 2, Art.INK)
			_dot(6, -50, 2, Art.INK)
		"doll":
			_ov(0, -50, 12, 12, Color("f2c9a0"), 3)
			_poly([Vector2(-10, -38), Vector2(10, -38), Vector2(18, 0), Vector2(-18, 0)], Color("e8526a"), 3)
			_poly(Array(Art.arc_pts(Vector2(0, -52), 13, 13, PI, TAU, 10)), Color("f5c02a"), 2)
			_dot(-4, -50, 1.8, Art.INK)
			_dot(4, -50, 1.8, Art.INK)
		"rubber_duck":
			_ov(0, -18, 22, 14, Color("f7d93d"), 3, 0.15)
			_ov(-8, -38, 12, 12, Color("f7d93d"), 3)
			_poly([Vector2(-18, -40), Vector2(-30, -36), Vector2(-18, -32)], Color("f58a23"), 2)
			_dot(-10, -42, 2.5, Art.INK)
		"bubble_wand":
			_handle(30, Color("3fb3e0"), 4)
			Art.stroke(_ci, _tp(Art.ellipse(Vector2(0, -44), 12, 12, 20)), 4, Color("3fb3e0"))
			var b := fmod(_t, 2.0)
			_ov(14 + b * 16, -70 - b * 30, 9, 9, Color(0.8, 0.95, 1.0, 0.35), 2)
			_ov(-10 - b * 8, -60 - b * 22, 6, 6, Color(0.8, 0.95, 1.0, 0.35), 2)
		"jump_rope":
			_rect(-4, -20, 8, 26, Color("e0353a"), 4, 3)
			_curve(Vector2(0, -20), Vector2(-60, -10), Vector2(-40, 70), 3, Color("f5c02a"))
		"fishing_rod":
			var tip := Vector2(10, -150)
			_stick(Vector2(0, 20), tip, 5, wood)
			var bob := tip + Vector2(46, 60 + sin(_t * 3.0) * 4.0)
			_curve(tip, tip + Vector2(40, 0), bob, 1.5, Color(1, 1, 1, 0.9))
			_ov(bob.x, bob.y, 6, 6, Color("e6452f"), 2)
		"net":
			_stick(Vector2(0, 20), Vector2(0, -80), 5, Color(0.6, 0.42, 0.22))
			Art.fill(_ci, _tp(Art.ellipse(Vector2(0, -105), 24, 24, 24)), Color(1, 1, 1, 0.35))
			for i in 5:
				var x := -18.0 + i * 9.0
				_line([Vector2(x, -122), Vector2(x, -88)], 1.5, Color(1, 1, 1, 0.8))
			Art.outline(_ci, _tp(Art.ellipse(Vector2(0, -105), 24, 24, 24)), 4.0, Color(0.6, 0.42, 0.22))
		# ---------------------------------------------------- adventure
		"sword":
			_rect(-5, -4, 10, 22, Color("5a2a10"), 3, 3)
			_rect(-18, -10, 36, 8, gold, 3, 3)
			_poly([Vector2(-6, -10), Vector2(6, -10), Vector2(6, -96), Vector2(0, -110), Vector2(-6, -96)], metal.lightened(0.15), 3, 0.15)
		"spear":
			_handle(110, Color("a8743c"), 5)
			_poly([Vector2(0, -136), Vector2(9, -112), Vector2(0, -104), Vector2(-9, -112)], metal, 3)
			_line([Vector2(-6, -104), Vector2(6, -104)], 4, Color("3a6ad5"))
		"shield":
			_poly([Vector2(-26, -60), Vector2(26, -60), Vector2(24, -24), Vector2(0, 6), Vector2(-24, -24)], Color("3a6ad5"), 3, 0.15)
			_star(0, -32, 12, gold, 2)
		"bow":
			Art.stroke(_ci, _tp(Art.arc_pts(Vector2(0, -36), 18, 52, -PI / 2, PI / 2, 14)), 7, Art.INK)
			Art.stroke(_ci, _tp(Art.arc_pts(Vector2(0, -36), 18, 52, -PI / 2, PI / 2, 14)), 4, wood)
			_line([Vector2(0, -88), Vector2(0, 16)], 1.5, Color.WHITE)
		"wand", "star_wand":
			_stick(Vector2(0, 14), Vector2(0, -46), 4, Color("2a2a33") if id == "wand" else Color("f5e6c0"))
			if id == "star_wand":
				_star(0, -60, 16, gold, 3)
			else:
				_dot(0, -48, 4, Color.WHITE)
			_sparkle(14, -70, 4.0 + sin(_t * 7.0) * 2.0)
			_sparkle(-12, -60, 3.0 + cos(_t * 6.0) * 1.5)
		"staff":
			_handle(120, wood, 6)
			_ov(0, -132, 12, 12, Color("9b59d0"), 3, 0.2)
		"orb":
			var a := 0.55 + sin(_t * 3.0) * 0.15
			_ov(0, -30, 26, 26, Color(0.6, 0.9, 1.0, a * 0.5), 0)
			_ov(0, -30, 18, 18, Color(0.55, 0.85, 1.0, 0.9), 3, 0.2)
			_ov(-6, -36, 5, 4, Color(1, 1, 1, 0.8), 0)
		"potion":
			_rect(-5, -58, 10, 10, Color("8c6634"), 3, 3)
			_rect(-4, -50, 8, 12, Color(0.85, 0.95, 1.0, 0.85), 2, 3)
			_ov(0, -20, 18, 20, Color("e8526a"), 3, 0.2)
			_ov(-6, -28, 4, 5, Color(1, 1, 1, 0.6), 0)
		"torch":
			_handle(30, wood, 7)
			var f := sin(_t * 10.0) * 2.0
			_ov(0, -50, 13, 22 + f, Color("ff8a2a"), 3)
			_ov(0, -44, 7, 12 + f, Color("ffe14a"), 0)
		"skull":
			_ov(0, -30, 18, 18, Color("f2efe4"), 3, 0.15)
			_rect(-9, -16, 18, 12, Color("f2efe4"), 3, 3)
			_ov(-7, -32, 5, 6, Art.INK, 0)
			_ov(7, -32, 5, 6, Art.INK, 0)
		"magic_lamp":
			_poly([Vector2(-20, -14), Vector2(20, -14), Vector2(40, -26), Vector2(14, -22), Vector2(0, -32), Vector2(-14, -22), Vector2(-26, -20)], gold, 3, 0.15)
			_ov(0, -8, 22, 8, gold, 3, 0.2)
			_ov(0, -34, 6, 4, gold, 2)
		# ---------------------------------------------------- everyday
		"toothbrush":
			_stick(Vector2(0, 12), Vector2(0, -50), 5, Color("3fb3e0"))
			_rect(-2, -66, 10, 18, Color.WHITE, 3, 2)
		"comb":
			_rect(-26, -16, 52, 10, Color("e8526a"), 3, 3)
			for i in 9:
				_line([Vector2(-22 + i * 5.5, -16), Vector2(-22 + i * 5.5, -30)], 2.5, Color("e8526a").darkened(0.2))
		"hand_mirror":
			_handle(24, Color("e8526a"), 7)
			_ov(0, -52, 20, 24, Color("e8526a"), 3)
			_ov(0, -52, 15, 19, Color("cfeeff"), 0)
			_line([Vector2(-6, -60), Vector2(2, -68)], 3, Color.WHITE)
		"perfume":
			_ov(0, -18, 18, 18, Color(0.9, 0.6, 0.95, 0.85), 3, 0.15)
			_rect(-5, -44, 10, 10, gold, 2, 3)
			_ov(18, -40, 6, 6, Color("e8526a"), 2)
		"sunscreen", "soap":
			if id == "soap":
				_rect(-20, -30, 40, 26, Color("f7c6d9"), 10, 3, 0.1)
				for c in [Vector2(-14, -38), Vector2(-2, -44), Vector2(10, -38)]:
					_ov(c.x, c.y, 6, 6, Color(1, 1, 1, 0.6), 2)
			else:
				_rect(-12, -50, 24, 54, Color("f5a623"), 6, 3, 0.1)
				_rect(-6, -58, 12, 10, Color.WHITE, 2)
				_ov(0, -24, 8, 8, Color("ffe14a"), 2)
		"towel":
			_rect(-22, -60, 44, 66, Color("3fb3e0"), 3, 3, 0.15)
			for y in [-48, -8]:
				_line([Vector2(-22, y), Vector2(22, y)], 4, Color.WHITE)
		"pillow":
			_rect(-34, -46, 68, 42, Color("f5f0ff"), 14, 3, 0.15)
		"blanket":
			_rect(-30, -70, 60, 76, Color("9b59d0"), 4, 3, 0.15)
			for i in 3:
				_line([Vector2(-30, -56 + i * 22), Vector2(30, -56 + i * 22)], 4, Color("f5c02a"))
		"umbrella":
			_stick(Vector2(0, 14), Vector2(0, -90), 3, Color("2a2a33"))
			Art.stroke(_ci, _tp(Art.arc_pts(Vector2(-7, 14), 7, 7, 0, PI, 8)), 4, Color("2a2a33"))
			_poly(Array(Art.arc_pts(Vector2(0, -90), 54, 40, PI, TAU, 18)), Color("e0353a"), 3, 0.1)
		"suitcase":
			_curve(Vector2(-10, -50), Vector2(0, -66), Vector2(10, -50), 4)
			_rect(-34, -50, 68, 50, Color("8c4a2a"), 6, 3, 0.15)
			_line([Vector2(-34, -32), Vector2(34, -32)], 3, Color("5a2a10"))
		"purse":
			_curve(Vector2(-14, -28), Vector2(0, 6), Vector2(14, -28), 3, Color("5a2a10"))
			_rect(-22, -30, 44, 30, Color("e8526a"), 8, 3, 0.15)
			_dot(0, -18, 3.5, gold)
		"sack":
			_ov(0, -34, 30, 32, Color("c9a46a"), 3, 0.2)
			_line([Vector2(-8, -66), Vector2(8, -66)], 5, Color("8c6634"))
			_poly([Vector2(-10, -64), Vector2(10, -64), Vector2(0, -70)], Color("c9a46a"), 3)
		"paper_bag":
			_rect(-20, -50, 40, 54, Color("c9935a"), 2, 3, 0.15)
			for i in 4:
				_line([Vector2(-20 + i * 10, -50), Vector2(-15 + i * 10, -56), Vector2(-10 + i * 10, -50)], 2)
		"basket":
			_curve(Vector2(-24, -22), Vector2(0, -64), Vector2(24, -22), 5, Color("a8743c"))
			_poly([Vector2(-28, -22), Vector2(28, -22), Vector2(20, 6), Vector2(-20, 6)], Color("d9a35e"), 3, 0.15)
			for y in [-14, -4]:
				_line([Vector2(-24, y), Vector2(24, y)], 2, Color("8c6634"))
			_ov(-10, -26, 8, 6, Color("e0353a"), 2)
			_ov(8, -26, 9, 6, Color("f7d93d"), 2)
		"candle":
			_rect(-8, -40, 16, 44, Color("fbf6ea"), 3, 3)
			_line([Vector2(0, -40), Vector2(0, -46)], 2)
			var fl := sin(_t * 11.0) * 1.5
			_ov(0, -54, 5, 9 + fl, Color("ffb13d"), 2)
			_ov(0, -52, 2.5, 5 + fl * 0.5, Color("fff2a0"), 0)
		"scarf":
			_curve(Vector2(-6, -40), Vector2(-14, -10), Vector2(-4, 16), 12, Art.INK)
			_curve(Vector2(-6, -40), Vector2(-14, -10), Vector2(-4, 16), 7, Color("e0353a"))
			_curve(Vector2(6, -40), Vector2(14, -10), Vector2(4, 16), 12, Art.INK)
			_curve(Vector2(6, -40), Vector2(14, -10), Vector2(4, 16), 7, Color("e0353a"))
		"glasses":
			for x in [-14, 14]:
				Art.stroke(_ci, _tp(Art.ellipse(Vector2(x, -24), 11, 9, 18)), 4, Art.INK)
			_line([Vector2(-3, -26), Vector2(3, -26)], 3)
		# ---------------------------------------------------- nature
		"flower":
			_stick(Vector2(0, 14), Vector2(0, -36), 3, Color("3c9a3a"))
			_ov(8, -16, 7, 3.5, Color("58b847"), 2, 0.0, -0.5)
			for i in 5:
				var a := i * TAU / 5.0
				_ov(cos(a) * 9, -46 + sin(a) * 9, 7, 7, Color("f58ab4"), 2)
			_dot(0, -46, 5, Color("f5c02a"))
		"rose":
			_stick(Vector2(0, 14), Vector2(0, -36), 3, Color("3c9a3a"))
			_ov(-7, -16, 7, 3.5, Color("58b847"), 2, 0.0, 0.5)
			_ov(0, -44, 11, 10, Color("d8243a"), 3, 0.2)
			_curve(Vector2(-5, -46), Vector2(0, -52), Vector2(5, -44), 2, Color("8c1424"))
		"bouquet":
			_poly([Vector2(-10, -24), Vector2(10, -24), Vector2(4, 12), Vector2(-4, 12)], Color("f2efe4"), 3)
			var spots := [Vector2(-12, -38), Vector2(0, -46), Vector2(12, -38), Vector2(-5, -30), Vector2(7, -30)]
			var cols := [Color("f58ab4"), Color("f5c02a"), Color("e8526a"), Color("9b59d0"), Color("6be0ff")]
			for i in spots.size():
				_ov(spots[i].x, spots[i].y, 8, 8, cols[i], 2)
		"potted_plant":
			for a in [-0.6, 0.0, 0.6]:
				_ov(sin(a) * 18, -54 - cos(a) * 10, 9, 16, Color("58b847"), 2, 0.0, a)
			_poly([Vector2(-20, -38), Vector2(20, -38), Vector2(14, 2), Vector2(-14, 2)], Color("c96a3a"), 3, 0.15)
		"leaf":
			_line([Vector2(0, 12), Vector2(0, -10)], 3, Color("3c9a3a"))
			_ov(0, -34, 14, 26, Color("58b847"), 3, 0.15)
			_line([Vector2(0, -10), Vector2(0, -56)], 2, Color("3c9a3a"))
		"pinecone":
			_ov(0, -24, 14, 22, Color("8c5a2a"), 3, 0.2)
			for i in 4:
				_line([Vector2(-12, -38 + i * 9), Vector2(0, -34 + i * 9), Vector2(12, -38 + i * 9)], 2, Color("5a3a1a"))
		"seashell":
			_poly([Vector2(0, -4), Vector2(-24, -24), Vector2(-14, -44), Vector2(0, -50), Vector2(14, -44), Vector2(24, -24)], Color("f7c6c0"), 3, 0.1)
			for x in [-12, -4, 4, 12]:
				_line([Vector2(0, -6), Vector2(x * 1.5, -44)], 2, Color("d98a80"))
		"rock":
			_poly([Vector2(-20, -4), Vector2(-24, -24), Vector2(-8, -40), Vector2(14, -36), Vector2(24, -14), Vector2(16, -2)], Color("9a9aa2"), 3, 0.2)
		"bone":
			_stick(Vector2(0, -6), Vector2(0, -46), 9, Color("f6ecd8"))
			for y in [-6, -46]:
				for x in [-6, 6]:
					_ov(x, y, 7, 7, Color("f6ecd8"), 3)
			_stick(Vector2(0, -6), Vector2(0, -46), 9, Color("f6ecd8"))
		"worm":
			var wig := sin(_t * 5.0) * 4.0
			Art.limb(_ci, _tp(Art.curve(Vector2(0, -2), Vector2(14 + wig, -26), Vector2(-4, -50), 12)), 8, Color("f29a9a"))
			_dot(-4, -50, 1.8, Art.INK)
		"feather":
			_line([Vector2(0, 14), Vector2(0, -56)], 2, Color("5a5f68"))
			_ov(0, -34, 10, 26, Color("6be0ff"), 3, 0.1, 0.1)
			_line([Vector2(0, -8), Vector2(0, -58)], 2, Color("3a7fd5"))
		"acorn":
			_ov(0, -18, 12, 15, Color("c98a3c"), 3, 0.15)
			_poly(Array(Art.arc_pts(Vector2(0, -26), 14, 10, PI, TAU, 10)), Color("6b3a1e"), 3)
			_line([Vector2(0, -36), Vector2(2, -42)], 3, Color("6b3a1e"))
