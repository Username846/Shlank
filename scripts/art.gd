class_name Art
extends RefCounted
## Drawing helpers for the "Flash cartoon" look: flat fills, bold ink outlines,
## and a single cel-shade crescent per shape.

const INK := Color(0.09, 0.07, 0.11)
const INK_W := 4.0
const CACHE_MAX := 4000

## Memoized results of the expensive geometry (most shapes repeat every redraw).
## Anti-aliased strokes cost extra geometry. Turned off while rendering into
## supersampled offscreen textures, where downscaling smooths the edges anyway.
static var antialias := true
static var _smooth_cache := {}
static var _shade_cache := {}
static var _valid_cache := {}


static func _remember(cache: Dictionary, key: int, value: Variant) -> void:
	if cache.size() >= CACHE_MAX:
		cache.clear()
	cache[key] = value


static func ellipse(c: Vector2, rx: float, ry: float, n: int = 36, rot: float = 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		var p := Vector2(cos(a) * rx, sin(a) * ry)
		pts.append(c + p.rotated(rot))
	return pts


static func arc_pts(c: Vector2, rx: float, ry: float, a0: float, a1: float, n: int = 16) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n + 1:
		var a := lerpf(a0, a1, float(i) / n)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func rrect(r: Rect2, rad: float, n: int = 5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var corners := [
		[r.position + Vector2(r.size.x - rad, rad), -PI / 2],
		[r.position + Vector2(r.size.x - rad, r.size.y - rad), 0.0],
		[r.position + Vector2(rad, r.size.y - rad), PI / 2],
		[r.position + Vector2(rad, rad), PI],
	]
	for c in corners:
		for i in n + 1:
			var a: float = c[1] + (PI / 2) * i / n
			pts.append(c[0] + Vector2(cos(a), sin(a)) * rad)
	return pts


## Closed Catmull-Rom spline through the control points.
static func smooth(ctrl: PackedVector2Array, sub: int = 6, closed: bool = true) -> PackedVector2Array:
	var n := ctrl.size()
	if n < 3:
		return ctrl
	var key := hash([ctrl, sub, closed])
	if _smooth_cache.has(key):
		return _smooth_cache[key]
	var out := PackedVector2Array()
	var count := n if closed else n - 1
	for i in count:
		var p0 := ctrl[(i - 1 + n) % n] if (closed or i > 0) else ctrl[0]
		var p1 := ctrl[i]
		var p2 := ctrl[(i + 1) % n]
		var p3 := ctrl[(i + 2) % n] if (closed or i + 2 < n) else ctrl[n - 1]
		for s in sub:
			var t := float(s) / sub
			var t2 := t * t
			var t3 := t2 * t
			out.append(0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3))
	if not closed:
		out.append(ctrl[n - 1])
	_remember(_smooth_cache, key, out)
	return out


## A five-pointed star of outer radius `r`.
static func star(c: Vector2, r: float, inner: float = 0.45) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2 + TAU * i / 10.0
		pts.append(c + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * inner))
	return pts


## Heart outline centred on c (used for the locket).
static func heart(c: Vector2, s: float, n: int = 36) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var t := TAU * i / n
		var x := 16.0 * pow(sin(t), 3)
		var y := 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
		pts.append(c + Vector2(x, -y) * (s / 16.0))
	return pts


static func translate(pts: PackedVector2Array, off: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(pts.size())
	for i in pts.size():
		out[i] = pts[i] + off
	return out


static func outline(ci: CanvasItem, pts: PackedVector2Array, w: float = INK_W, ink: Color = INK) -> void:
	if w <= 0.0 or pts.size() < 2:
		return
	var p := pts.duplicate()
	p.append(pts[0])
	ci.draw_polyline(p, ink, w, antialias)


static func fill(ci: CanvasItem, pts: PackedVector2Array, color: Color) -> void:
	if pts.size() < 3 or color.a <= 0.0:
		return
	var key := hash(pts)
	var ok: bool = _valid_cache.get(key, true)
	if not _valid_cache.has(key):
		ok = not Geometry2D.triangulate_polygon(pts).is_empty()
		_remember(_valid_cache, key, ok)
	if not ok:
		# Self-intersecting outline; fall back to the convex hull so something draws.
		var hull := Geometry2D.convex_hull(pts)
		if hull.size() >= 3:
			ci.draw_colored_polygon(hull, color)
		return
	ci.draw_colored_polygon(pts, color)


## Filled shape with ink outline. `shade` > 0 adds a darker cel crescent on the lower right.
static func shape(ci: CanvasItem, pts: PackedVector2Array, color: Color, w: float = INK_W, shade: float = 0.0, shade_off: Vector2 = Vector2(-10, -10)) -> void:
	fill(ci, pts, color)
	if shade > 0.0:
		var dark := color.darkened(shade)
		var key := hash([pts, shade_off])
		var polys: Array = _shade_cache.get(key, [])
		if not _shade_cache.has(key):
			polys = Geometry2D.clip_polygons(pts, translate(pts, shade_off))
			_remember(_shade_cache, key, polys)
		for poly in polys:
			fill(ci, poly, dark)
	outline(ci, pts, w)


static func blob(ci: CanvasItem, c: Vector2, rx: float, ry: float, color: Color, w: float = INK_W, shade: float = 0.0, rot: float = 0.0) -> void:
	shape(ci, ellipse(c, rx, ry, 40, rot), color, w, shade, Vector2(-rx * 0.18, -ry * 0.18))


static func dot(ci: CanvasItem, c: Vector2, r: float, color: Color) -> void:
	ci.draw_circle(c, r, color, true, -1.0, antialias)


## A thick stroke with an ink border and round caps (arms, legs, stalks).
static func limb(ci: CanvasItem, pts: PackedVector2Array, width: float, color: Color, w: float = 3.0) -> void:
	if pts.size() < 2:
		return
	ci.draw_polyline(pts, INK, width + w * 2.0, antialias)
	dot(ci, pts[0], (width + w * 2.0) * 0.5, INK)
	dot(ci, pts[pts.size() - 1], (width + w * 2.0) * 0.5, INK)
	ci.draw_polyline(pts, color, width, antialias)
	dot(ci, pts[0], width * 0.5, color)
	dot(ci, pts[pts.size() - 1], width * 0.5, color)


static func stroke(ci: CanvasItem, pts: PackedVector2Array, w: float = 3.0, color: Color = INK) -> void:
	if pts.size() >= 2:
		ci.draw_polyline(pts, color, w, antialias)


## Quadratic bezier curve from a to b bending through control c.
static func curve(a: Vector2, c: Vector2, b: Vector2, n: int = 14) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n + 1:
		var t := float(i) / n
		pts.append(a.lerp(c, t).lerp(c.lerp(b, t), t))
	return pts


static func gradient_rect(ci: CanvasItem, r: Rect2, top: Color, bottom: Color) -> void:
	var pts := PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0), r.end, r.position + Vector2(0, r.size.y)])
	ci.draw_polygon(pts, PackedColorArray([top, top, bottom, bottom]))


## Bold cartoon text with an ink outline (used for signs and title cards).
static func text(ci: CanvasItem, font: Font, pos: Vector2, s: String, size: int, color: Color, outline_w: int = 6, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER, width: float = -1.0) -> void:
	if outline_w > 0:
		ci.draw_string_outline(font, pos, s, align, width, size, outline_w, INK)
	ci.draw_string(font, pos, s, align, width, size, color)


## The classic Bikini-Bottom-style sky flower.
static func sky_flower(ci: CanvasItem, c: Vector2, r: float, color: Color, rot: float = 0.0) -> void:
	var ctrl := PackedVector2Array()
	for i in 10:
		var a := rot + TAU * i / 10.0
		var rr := r if i % 2 == 0 else r * 0.55
		ctrl.append(c + Vector2(cos(a), sin(a)) * rr)
	ci.draw_colored_polygon(smooth(ctrl, 5), color)
	dot(ci, c, r * 0.22, color.lightened(0.35))
