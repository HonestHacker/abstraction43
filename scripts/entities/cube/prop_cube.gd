extends RigidBody3D

@export_file("*.tscn") var packed_scene_path: String

var node_path :
	get:
		return get_path()
