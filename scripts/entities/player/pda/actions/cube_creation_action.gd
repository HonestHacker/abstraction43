extends Action
class_name CubeCreationAction

var cube_scene = preload("res://scenes/entities/prop_cube.tscn")
var transparent_cube: Node3D = null
var solid_cube: Node3D = null

func _init() -> void:
	icon = load("res://textures/ui/pda/materialization_action32_negate2.png")

func do() -> void:
	if transparent_cube == null:
		spawn_transparent_cube()
	else:
		place_solid_cube()

func spawn_transparent_cube() -> void:
	transparent_cube = cube_scene.instantiate()
	var mesh_instance = transparent_cube.get_node("cube").get_node("Cube")
	if mesh_instance and mesh_instance is MeshInstance3D:
		var material: StandardMaterial3D = mesh_instance.get_surface_override_material(0)
		if material == null:
			material = StandardMaterial3D.new()
			mesh_instance.set_surface_override_material(0, material)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.flags_transparent = true
		var color: Color = material.albedo_color
		color.a = 0.3
		material.albedo_color = color
	transparent_cube.set_collision_layer(0)
	transparent_cube.set_collision_mask(0)

	get_tree().current_scene.add_child(transparent_cube)
	set_process(true)

func _process(delta: float) -> void:
	if transparent_cube:
		if not player:
			return
		var camera = player.camera
		if not camera:
			return

		var camera_transform = camera.global_transform
		var forward_dir = -camera_transform.basis.z.normalized()
		var target_pos = camera_transform.origin + forward_dir * 5.0
		
		# Raycasting stuff
		var space_state = player.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			camera.global_transform.origin,
			target_pos
		)
		var result = space_state.intersect_ray(query)
		if result:
			target_pos = result.position + result.normal * 0.5
		else:
			target_pos = camera_transform.origin + forward_dir * 3
		
		var new_transform = transparent_cube.global_transform
		new_transform.origin = target_pos
		transparent_cube.global_transform = new_transform

func place_solid_cube() -> void:
	if transparent_cube:
		var final_position = transparent_cube.global_transform.origin
		transparent_cube.queue_free()
		transparent_cube = null

		solid_cube = cube_scene.instantiate()
		get_tree().current_scene.add_child(solid_cube)
		solid_cube.global_transform.origin = final_position

		var mesh_instance = solid_cube.get_node("cube").get_node("Cube")
		if mesh_instance and mesh_instance is MeshInstance3D:
			var material: StandardMaterial3D = mesh_instance.get_surface_override_material(0)
			if material:
				var color: Color = material.albedo_color
				color.a = 1.0
				material.albedo_color = color
		finished.emit()
		set_process(false)
