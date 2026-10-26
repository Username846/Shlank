extends Node
## Dev tool: counts which CanvasItems redraw, over 2 seconds of the menu / episode.
var counts := {}

func _ready() -> void:
	var main = load("res://scripts/main.gd").new()
	add_child(main)
	await get_tree().create_timer(1.0).timeout
	await _measure("menu")
	main.play_episode(main._episodes[0].script)
	await get_tree().create_timer(9.0).timeout
	await _measure("episode")
	get_tree().quit()

func _measure(label: String) -> void:
	counts.clear()
	_hook(get_tree().root)
	await get_tree().create_timer(2.0).timeout
	var keys := counts.keys()
	keys.sort_custom(func(a, b): return counts[a] > counts[b])
	print("== ", label)
	for k in keys.slice(0, 12):
		print("  %4d  %s" % [counts[k], k])

func _hook(n: Node) -> void:
	if n is CanvasItem and not n.draw.is_connected(_on_draw.bind(n)):
		n.draw.connect(_on_draw.bind(n))
	for c in n.get_children(true):
		_hook(c)

func _on_draw(n: Node) -> void:
	var k := "%s (%s)" % [n.get_class() if n.get_script() == null else n.get_script().resource_path.get_file(), n.name]
	counts[k] = counts.get(k, 0) + 1
