extends Node


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
	for serializable: Serializable in get_tree().get_nodes_in_group("serializables"):
		serializable.restore(data[serializable.name])
