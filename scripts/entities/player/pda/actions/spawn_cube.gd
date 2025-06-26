extends Action

var preview_instance: Node = null
var preview_visible: bool = false
var cube_spawned: bool = false

func _find_mesh(node):
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found = _find_mesh(child)
		if found:
			return found
	return null

func _make_transparent_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.3
	return mat

func process_for_cube(scene, player) -> void:
	if cube_spawned:
		return
	if Input.is_action_just_pressed("pda_activate"):
		if not preview_visible:
			# Spawn transparent preview
			var cube_scene = load("res://scenes/entities/prop_cube.tscn")
			preview_instance = cube_scene.instantiate()
			var mesh = _find_mesh(preview_instance)
			if mesh:
				mesh.material_override = _make_transparent_material()
			scene.current_scene.add_child(preview_instance)
			preview_instance.add_to_group("no_pickup")
			preview_visible = true
		else:
			# Replace preview with normal cube at last preview position
			if preview_instance:
				preview_instance.queue_free()
			var cube_scene = load("res://scenes/entities/prop_cube.tscn")
			var cube_instance = cube_scene.instantiate()
			scene.current_scene.add_child(cube_instance)
			cube_instance.global_transform.origin = preview_instance.global_transform.origin
			cube_spawned = true
			preview_visible = false

	# If preview is visible, update its position to follow player
	if preview_visible and preview_instance:
		var camera = player.camera
		var forward = -camera.global_transform.basis.z.normalized()
		var new_pos = camera.global_transform.origin + forward * 2.0
		preview_instance.global_transform.origin = new_pos
