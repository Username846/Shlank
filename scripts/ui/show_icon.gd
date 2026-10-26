class_name ShowIcon
extends Control
## A round badge identifying which show something belongs to.
## The design comes from the show's "icon" in data/shows.json:
##   bubbles - Bikini Bottom style: sea-blue with a sky flower and bubbles
##   city    - Hillwood style: sunset sky with a brick skyline
## Shows without one get their initials on a coloured badge.

var show_name := ""
var kind := ""
var color := Color("b48be0")


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
