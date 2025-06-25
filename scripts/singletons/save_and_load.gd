extends Node

func save(player, level_path, filename):
	if not filename or filename.strip_edges() == "":
		push_error("No filename provided for save.")
		return
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("save"):
		dir.make_dir("save")
	var save_path = "res://save/%s" % filename.strip_edges()
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		push_error("Could not open save file for writing: %s" % save_path)
		return
	var pos = player.global_transform.origin
	file.store_line("position: %s,%s,%s" % [pos.x, pos.y, pos.z])
	file.store_line("look_deg: %s,%s" % [rad_to_deg(player.rotation.y), player.camera and rad_to_deg(player.camera.rotation.x) or 0.0])
	file.store_line("scene_path: %s" % level_path)
	file.store_line("velocity: %s,%s,%s" % [player.velocity.x, player.velocity.y, player.velocity.z])
	file.close()

func load(filename, player):
	if not filename or filename.strip_edges() == "":
		push_warning("No filename provided for load.")
		return null
	var save_path = "res://save/%s" % filename.strip_edges()
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		push_warning("No save file found: %s" % save_path)
		return null
	var pos_data = file.get_line().replace("position: ", "").split(",")
	var look_data = file.get_line().replace("look_deg: ", "").split(",")
	var scene_path = file.get_line().replace("scene_path: ", "")
	var vel_data = file.get_line().replace("velocity: ", "").split(",")
	file.close()
	if pos_data.size() != 3 or look_data.size() != 2 or vel_data.size() != 3:
		push_warning("Save file is missing or invalid data.")
		return null
	var pos = Vector3(pos_data[0].to_float(), pos_data[1].to_float(), pos_data[2].to_float())
	var yaw_deg = look_data[0].to_float()
	var pitch_deg = look_data[1].to_float()
	var velocity = Vector3(vel_data[0].to_float(), vel_data[1].to_float(), vel_data[2].to_float())
	if player:
		player.global_transform.origin = pos
		player.rotation.y = deg_to_rad(yaw_deg)
		if player.camera:
			player.camera.rotation.x = clamp(deg_to_rad(pitch_deg), deg_to_rad(-89), deg_to_rad(89))
		player.velocity = velocity
	return {"position": pos, "yaw_deg": yaw_deg, "pitch_deg": pitch_deg, "scene_path": scene_path, "velocity": velocity}
