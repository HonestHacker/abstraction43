extends Control

func on_start(save):
	var dir := DirAccess.open("res://save")
	if not dir:
		return
	save.clear()
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir() or file_name.begins_with("."):
			continue
		save.add_item(file_name)
	dir.list_dir_end()

func on_load_button_pressed(save_lineedit, player, camera) -> void:
	var file_name = save_lineedit.text.strip_edges()
	if file_name == "":
		push_warning("No filename entered!")
		return
	var file = FileAccess.open("res://save/%s" % file_name, FileAccess.READ)
	if not file:
		push_warning("No save file found!")
		return
	var pos_data = file.get_line().split(",")
	var cam_rot_data = file.get_line().split(",")
	file.close()
	if pos_data.size() == 3:
		player.global_transform.origin = Vector3(pos_data[0].to_float(), pos_data[1].to_float(), pos_data[2].to_float())
	if cam_rot_data.size() == 3:
		camera.rotation = Vector3(cam_rot_data[0].to_float(), cam_rot_data[1].to_float(), cam_rot_data[2].to_float())

func on_save_button_pressed(save_lineedit, player, camera, scene) -> void:
	var file_name = save_lineedit.text.strip_edges()
	if file_name == "":
		push_error("Filename is empty!")
		return
	var dir = DirAccess.open("res://")
	if not dir:
		push_error("Could not open res:// directory!")
		return
	if not dir.dir_exists("save"):
		dir.make_dir("save")
	var save_path = "res://save/%s" % file_name
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		push_error("Could not open save file for writing: %s" % save_path)
		return
	var pos = player.global_transform.origin
	var cam_rot = camera.rotation
	file.store_line("%s,%s,%s" % [pos.x, pos.y, pos.z])
	file.store_line("%s,%s,%s" % [cam_rot.x, cam_rot.y, cam_rot.z])
	file.store_line("%s" % scene.current_scene.scene_file_path)
	file.close()

func on_load_and_save_pressed(save, pause_menu) -> void:
	save.visible = true
	pause_menu.visible=false

func on_continue_pressed(pause_menu, current) -> void:
	pause_menu.visible=false
	current.update_mouse_mode()

func on_new_game_pressed(scene) -> void:
	scene.reload_current_scene()

func on_settings_pressed(setting,pause_menu) -> void:
	setting.visible=true
	pause_menu.visible=false

func on_exit_pressed(scene) -> void:
	scene.quit()

func on_back_pressed(setting, pause_menu) -> void:
	setting.visible=false
	pause_menu.visible=true

func on_fov_slider_value_changed(value: float, camera) -> void:
	camera.fov = value

func for_process(setting, save, pause_menu) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if save.visible:
			save.visible = false
			setting.visible = false
			pause_menu.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
		elif setting.visible:
			setting.visible = false
			save.visible = false
			pause_menu.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			return
		elif pause_menu.visible:
			pause_menu.visible = false
			setting.visible = false
			save.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
		else:
			pause_menu.visible = true
			setting.visible = false
			save.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			return
