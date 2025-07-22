@icon("res://textures/ui/toolkit/saveload_system_icon.svg")
extends Node
class_name AbstractionSaveloadManager
## Save/Load Manager (Singleton)
##
## Handles saving and restoring game state using Serializable nodes.
## Manages save files in [code]user://save/[/code] directory with JSON serialization.

## Returns [PackedStringArray] which contains all files in save/ directory
func get_savefile_list() -> PackedStringArray:
	var dir = DirAccess.open("user://save")
	if not dir:
		return []
	var result := dir.get_files()
	result.reverse()
	return result

## Saves game state to a file[br]
##
## Collects data from all Serializable nodes, serializes to JSON, and writes to [code]user://save/<filename>[/code].[br]
## Creates save directory if missing. Shows errors for invalid filenames or write failures.[br]
##
## [param filename]: Save file name (without path extension). Whitespace is trimmed.[br]
## [color=red]Errors[/color]: Pushes error for empty filename or file write failures.[br]
func save(filename: String) -> void:
	if not filename or filename.strip_edges() == "":
		push_error("No filename provided for save.")
		return
	# It's better to use user:// path instead the res:// for saving game state
	# See https://docs.godotengine.org/en/stable/tutorials/scripting/filesystem.html
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("save"):
		dir.make_dir("save")
	var save_path = "user://save/%s" % filename.strip_edges()
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		push_error("Could not open save file for writing: %s" % save_path)
		return
	var data := {}
	for serializable: Serializable in get_tree().get_nodes_in_group("serializables"):
		data[serializable.name] = serializable.save()
	file.store_line(JSON.stringify(data))
	file.close()


## Loads game state from a file.[br]
##
## Reads JSON data from [code]user://save/<filename>[/code], parses it, and restores all [Serializable] nodes.[br]
## Shows warnings for missing Serializable data. Shows errors for invalid files or formats.[br]
##
## [param filename]: Save file name to load (without path extension). Whitespace is trimmed.[br]
## [color=red]Errors[/color]: Pushes error for empty filename, missing files, or invalid JSON formats.[br]
## [color=yellow]Warnings[/color]: Pushes warning when save data exists but no matching Serializable is found.[br]
func restore(filename: String) -> void:
	if not filename or filename.strip_edges() == "":
		push_error("No filename provided for load.")
		return
	var save_path = "user://save/%s" % filename.strip_edges()
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		push_error("No save file found: %s" % save_path)
		return
	var raw_data := file.get_line()
	var data = JSON.parse_string(raw_data)
	if data is not Dictionary:
		push_error("Wrong format: %s" % filename)
		return
	var serializables := get_tree().get_nodes_in_group("serializables")
	var serializable_names := serializables.map(func(x): return x.name)
	# Recreate serializables
	
	for serializable_name in data.keys():
		#print(data[serializable_name])
		#print(data[serializable_name].has(".."))
		#print(data[serializable_name][".."].has("packed_scene_path"))
		#print(data[serializable_name][".."].has("node_path"))
		
		if serializable_name not in serializable_names \
			and data[serializable_name].has("..") \
			and data[serializable_name][".."].has("packed_scene_path") \
			and data[serializable_name][".."].has("node_path"):
			var packed_scene: PackedScene = load(
				str_to_var(data[serializable_name][".."]["packed_scene_path"])
			)
			var node_path: NodePath = NodePath(str_to_var(data[serializable_name][".."]["node_path"]))
			var node = packed_scene.instantiate()
			node.name = node_path.get_name(node_path.get_name_count() - 1)
			get_node(node_path.slice(0, -1)).add_child(node)
	serializables = get_tree().get_nodes_in_group("serializables")
	# Restore all serializables
	for serializable: Serializable in serializables:
		if not data.has(serializable.name):
			if serializable.remove_if_not_found:
				serializable.get_parent().queue_free()
			else:
				push_warning("Serializable data has not been found: %s" % serializable.name)
			continue
		serializable.restore(data[serializable.name])
