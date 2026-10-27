class_name Library
extends RefCounted
## Built-in episodes (res://) plus the player's own (user://episodes/, which the web
## build keeps in the browser's local storage). A saved episode with the same id as a
## built-in one replaces it; deleting it brings the original back.

const USER_DIR := "user://episodes"


## [{id, path, text, origin: "built-in" | "edited" | "mine"}] in display order.
static func entries() -> Array:
	var out := []
	var by_id := {}
	for e in Game.episodes:
		var path := String(e.get("file", ""))
		var id := path.get_file().get_basename()
		_migrate(e.get("aka", []), id)
		var entry := {"id": id, "path": path, "text": Game.load_text(path), "origin": "built-in"}
		by_id[id] = entry
		out.append(entry)
	for id in user_ids():
		var text := load_user(id)
		if by_id.has(id):
			by_id[id].text = text
			by_id[id].origin = "edited"
			by_id[id].path = _user_path(id)
		else:
			out.append({"id": id, "path": _user_path(id), "text": text, "origin": "mine"})
	return out


## A built-in episode that was renamed lists its old ids under "aka"; an edited copy
## saved under an old id moves to the new one so it still replaces the original.
static func _migrate(old_ids: Array, id: String) -> void:
	for old in old_ids:
		if FileAccess.file_exists(_user_path(old)) and not FileAccess.file_exists(_user_path(id)):
			DirAccess.rename_absolute(_user_path(old), _user_path(id))


static func user_ids() -> Array:
	var ids := []
	var dir := DirAccess.open(USER_DIR)
	if dir == null:
		return ids
	for f in dir.get_files():
		if f.ends_with(".txt"):
			ids.append(f.get_basename())
	ids.sort()
	return ids


static func load_user(id: String) -> String:
	var f := FileAccess.open(_user_path(id), FileAccess.READ)
	return f.get_as_text() if f else ""


static func save(id: String, text: String) -> bool:
	DirAccess.make_dir_recursive_absolute(USER_DIR)
	var f := FileAccess.open(_user_path(id), FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(text)
	f.close()  # closing flushes it to the browser's storage on the web
	return true


static func delete(id: String) -> void:
	DirAccess.remove_absolute(_user_path(id))


static func new_id(title: String) -> String:
	var slug := ""
	for ch in title.to_lower():
		slug += ch if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") else "_"
	while slug.contains("__"):
		slug = slug.replace("__", "_")
	slug = slug.strip_edges().trim_prefix("_").trim_suffix("_").left(32)
	if slug == "":
		slug = "episode"
	var id := "my_" + slug
	var n := 2
	var taken := user_ids()
	for e in Game.episodes:
		taken.append(String(e.get("file", "")).get_file().get_basename())
	while taken.has(id):
		id = "my_%s_%d" % [slug, n]
		n += 1
	return id


static func _user_path(id: String) -> String:
	return "%s/%s.txt" % [USER_DIR, id]


# -------------------------------------------------------------- clipboard --

## Puts text on the system clipboard (must be called from a click/keypress).
static func copy_to_clipboard(text: String) -> void:
	DisplayServer.clipboard_set(text)


static var _js_callback: JavaScriptObject
static var _js_error: JavaScriptObject


## Reads the system clipboard and calls `done` with its text ("" if unavailable).
## In browsers this asks permission; it can fail, so the import dialog also has a
## text box that Ctrl+V pastes into.
static func read_clipboard(done: Callable) -> void:
	if OS.has_feature("web"):
		var nav := JavaScriptBridge.get_interface("navigator")
		if nav and nav.clipboard:
			_js_callback = JavaScriptBridge.create_callback(func(args: Array) -> void:
				done.call(str(args[0]) if args.size() > 0 else ""))
			_js_error = JavaScriptBridge.create_callback(func(_args: Array) -> void: done.call(""))
			nav.clipboard.readText().then(_js_callback).catch(_js_error)
			return
	done.call(DisplayServer.clipboard_get())
