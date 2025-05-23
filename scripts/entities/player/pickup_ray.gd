extends RayCast3D

@export var use = "use"
@export var grab: Joint3D

var object: RigidBody3D = null

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(use):
		if not object:
			var collider = get_collider()
			if collider is RigidBody3D:
				object = collider
				object.sleeping = true
				grab.set_node_b(object.get_path())
		else:
			object.sleeping = false
			object = null
			grab.set_node_b("")
