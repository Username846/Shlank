class_name ShowIcon
extends Control
## A round badge identifying which show something belongs to.
## The design comes from the show's "icon" in data/shows.json:
##   bubbles - Bikini Bottom style: sea-blue with a sky flower and bubbles
##   city    - Hillwood style: sunset sky with a brick skyline
##   star, heart, film, note, moon, bolt - generic badges for episodes
## Shows without one get their initials on a coloured badge.

var show_name := ""
var kind := ""
var color := Color("b48be0")


## Every badge an episode can choose, as [kind, label].
static func episode_icons() -> Array:
	var out := []
	for show in Game.shows:
		var k := String(Game.shows[show].get("icon", ""))
		if k != "":
			out.append([k, show])
	for k in [["star", "Star"], ["heart", "Heart"], ["film", "Film"], ["note", "Music"], ["moon", "Moon"], ["bolt", "Lightning"]]:
		out.append(k)
	return out


static func make_kind(p_kind: String, px: float = 84.0, tip: String = "") -> ShowIcon:
	var icon := ShowIcon.new()
	icon.kind = p_kind
	icon.custom_minimum_size = Vector2(px, px)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.tooltip_text = tip
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	return icon


## The badge for an episode: its own @icon, else its series' badge.
static func for_episode(sc: EpisodeScript, px: float = 84.0) -> ShowIcon:
	if sc.icon != "":
		return make_kind(sc.icon, px, sc.series)
	return make(sc.series, px)


static func make(show: String, px: float = 84.0) -> ShowIcon:
	var icon := ShowIcon.new()
	icon.show_name = show
	var info: Dictionary = Game.shows.get(show, {})
	icon.kind = String(info.get("icon", ""))
	icon.color = Color(String(info.get("color", "#b48be0")))
	icon.custom_minimum_size = Vector2(px, px)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.tooltip_text = show
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	return icon


func _draw() -> void:
	var c := size / 2.0
	var r := minf(size.x, size.y) * 0.5 - 4.0
	var disc := Art.ellipse(c, r, r, 48)
	match kind:
		"bubbles":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("2f7fd0"), Color("8fd6ee")))
			Art.sky_flower(self, c + Vector2(-r * 0.25, -r * 0.2), r * 0.5, Color(1, 1, 1, 0.75), 0.3)
			Art.sky_flower(self, c + Vector2(r * 0.42, r * 0.05), r * 0.28, Color(0.8, 1, 0.85, 0.7), 1.0)
			for b in [[Vector2(0.15, 0.55), 0.12], [Vector2(0.45, 0.5), 0.08], [Vector2(-0.45, 0.45), 0.1], [Vector2(0.55, -0.45), 0.07]]:
				var bc: Vector2 = c + b[0] * r
				draw_arc(bc, b[1] * r, 0, TAU, 16, Color.WHITE, 2.0, true)
			# Sandy sea floor
			for poly in Geometry2D.intersect_polygons(disc, PackedVector2Array([c + Vector2(-r, r * 0.62), c + Vector2(r, r * 0.5), c + Vector2(r, r), c + Vector2(-r, r)])):
				draw_colored_polygon(poly, Color("f1dc9b"))
		"city":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("f29a6a"), Color("fbd9a0")))
			Art.dot(self, c + Vector2(r * 0.3, -r * 0.1), r * 0.28, Color("ffe08a"))
			var rng := RandomNumberGenerator.new()
			rng.seed = 7
			var x := -r
			while x < r:
				var bw := rng.randf_range(0.22, 0.36) * r
				var bh := rng.randf_range(0.35, 0.95) * r
				var bld := PackedVector2Array([c + Vector2(x, r * 0.55 - bh), c + Vector2(x + bw, r * 0.55 - bh), c + Vector2(x + bw, r), c + Vector2(x, r)])
				for poly in Geometry2D.intersect_polygons(disc, bld):
					draw_colored_polygon(poly, Color("b0573e").darkened(rng.randf_range(0.0, 0.25)))
				var wy := r * 0.55 - bh + r * 0.1
				while wy < r * 0.5:
					if c.distance_to(c + Vector2(x + bw * 0.5, wy)) < r - 6:
						draw_rect(Rect2(c + Vector2(x + bw * 0.3, wy), Vector2(bw * 0.4, r * 0.08)), Color("ffd76a"))
					wy += r * 0.2
				x += bw + r * 0.04
		"journal":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("8fd06a"), Color("4f9a3a")))
			var book := Rect2(c + Vector2(-r * 0.42, -r * 0.55), Vector2(r * 0.84, r * 1.1))
			Art.shape(self, Art.rrect(book, 6), Color("e6452f"), 3.0, 0.15)
			Art.shape(self, Art.rrect(Rect2(book.position + Vector2(r * 0.14, r * 0.18), Vector2(r * 0.56, r * 0.26)), 3), Color("fff6dc"), 2.0)
			draw_line(book.position + Vector2(r * 0.1, 0), book.position + Vector2(r * 0.1, book.size.y), Art.INK, 3.0)
		"bottle":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("bfe3fb"), Color("7ab8ea")))
			Art.shape(self, Art.rrect(Rect2(c + Vector2(-r * 0.24, -r * 0.2), Vector2(r * 0.48, r * 0.8)), 10), Color("f4f4f2"), 3.0)
			Art.shape(self, Art.rrect(Rect2(c + Vector2(-r * 0.24, r * 0.25), Vector2(r * 0.48, r * 0.35)), 8), Color("f2f2ee").lerp(Color.WHITE, 0.5), 0.0)
			Art.shape(self, Art.rrect(Rect2(c + Vector2(-r * 0.28, -r * 0.32), Vector2(r * 0.56, r * 0.14)), 4), Color("f28cb8"), 3.0)
			Art.shape(self, PackedVector2Array([c + Vector2(-r * 0.12, -r * 0.32), c + Vector2(r * 0.12, -r * 0.32), c + Vector2(r * 0.05, -r * 0.62),
				c + Vector2(-r * 0.05, -r * 0.62)]), Color("f2c14e"), 3.0)
		"rokket":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("ffffff"), Color("d9dde3")))
			Art.text(self, UiKit.TITLE_FONT, Vector2(0, c.y + r * 0.42), "R", int(r * 1.25), Color("e6452f"), 7, HORIZONTAL_ALIGNMENT_CENTER, size.x)
		"star":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("6b4fd6"), Color("b48be0")))
			var pts := PackedVector2Array()
			for i in 10:
				var a := -PI / 2 + TAU * i / 10.0
				pts.append(c + Vector2(cos(a), sin(a)) * (r * 0.62 if i % 2 == 0 else r * 0.27))
			Art.shape(self, pts, Color("f6df4c"), 3.0)
		"heart":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("f7a1b4"), Color("ef5a9a")))
			Art.shape(self, Art.heart(c + Vector2(0, r * 0.05), r * 0.62), Color("e6452f"), 3.0, 0.15)
			Art.dot(self, c + Vector2(-r * 0.25, -r * 0.2), r * 0.1, Color(1, 1, 1, 0.8))
		"film":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("3a3d42"), Color("5f646b")))
			var reel := r * 0.62
			Art.blob(self, c, reel, reel, Color("cfd3d8"), 3.0)
			for i in 6:
				var a := TAU * i / 6.0
				Art.dot(self, c + Vector2(cos(a), sin(a)) * reel * 0.55, reel * 0.2, Color("3a3d42"))
			Art.dot(self, c, reel * 0.12, Color("3a3d42"))
		"note":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("63c3a5"), Color("3d8fe0")))
			for k in 2:
				var head := c + Vector2(-r * 0.32 + k * r * 0.52, r * 0.3 - k * r * 0.1)
				Art.blob(self, head, r * 0.17, r * 0.13, Color.WHITE, 3.0, 0.0, -0.4)
				draw_line(head + Vector2(r * 0.15, 0), head + Vector2(r * 0.15, -r * 0.62), Art.INK, 4.0, true)
			draw_line(c + Vector2(-r * 0.17, -r * 0.32), c + Vector2(r * 0.35, -r * 0.42), Art.INK, 8.0, true)
		"moon":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("1d2a5a"), Color("3b2a6e")))
			for p in [Vector2(0.45, -0.35), Vector2(-0.5, 0.45), Vector2(0.3, 0.55), Vector2(-0.2, -0.6)]:
				Art.dot(self, c + p * r, 2.5, Color(1, 1, 0.85))
			var moon := Art.ellipse(c, r * 0.5, r * 0.5, 36)
			var bite := Art.translate(Art.ellipse(c, r * 0.42, r * 0.42, 36), Vector2(r * 0.25, -r * 0.15))
			for poly in Geometry2D.clip_polygons(moon, bite):
				Art.shape(self, poly, Color("ffe08a"), 3.0)
		"bolt":
			draw_polygon(disc, _vertical_gradient(disc, c, r, Color("f2a65a"), Color("e6452f")))
			var bolt := PackedVector2Array([c + Vector2(0.1, -0.7) * r, c + Vector2(-0.35, 0.08) * r, c + Vector2(-0.02, 0.08) * r,
				c + Vector2(-0.15, 0.7) * r, c + Vector2(0.38, -0.12) * r, c + Vector2(0.05, -0.12) * r])
			Art.shape(self, bolt, Color("f6df4c"), 3.0)
		_:
			draw_colored_polygon(disc, color)
			var initials := ""
			for word in show_name.split(" ", false):
				initials += word[0]
			Art.text(self, UiKit.TITLE_FONT, Vector2(0, c.y + r * 0.3), initials.substr(0, 2).to_upper(), int(r * 0.9), Color.WHITE, 6, HORIZONTAL_ALIGNMENT_CENTER, size.x)
	# Gold rim
	draw_arc(c, r, 0, TAU, 48, Color("f2c14e"), 5.0, true)
	draw_arc(c, r + 3.0, 0, TAU, 48, Art.INK, 3.0, true)
	draw_arc(c, r - 3.0, 0, TAU, 48, Art.INK, 2.0, true)


static func _vertical_gradient(pts: PackedVector2Array, c: Vector2, r: float, top: Color, bottom: Color) -> PackedColorArray:
	var cols := PackedColorArray()
	for p in pts:
		cols.append(top.lerp(bottom, clampf((p.y - (c.y - r)) / (2.0 * r), 0.0, 1.0)))
	return cols
