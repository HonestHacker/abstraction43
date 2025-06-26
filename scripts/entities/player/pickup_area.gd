extends Area3D

@export var force : float = 25
@export var floor_area : Area3D
var picked_prop : RigidBody3D

func pick(body: RigidBody3D):
	picked_prop = body

func drop():
	picked_prop.linear_velocity *= 0.1
	picked_prop = null

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		if picked_prop:
			drop()
		else:
			for body in get_overlapping_bodies():
				if body is RigidBody3D and not (body in floor_area.get_overlapping_bodies()) and not body.is_in_group("no_pickup"):
					pick(body)
					break
	if picked_prop != null and weakref(picked_prop).get_ref():
		var a = get_global_transform().origin
		var b = picked_prop.get_global_transform().origin
		picked_prop.linear_velocity = (a - b) * force
		picked_prop.angular_velocity *= 0.01

func _on_body_exited(body: Node3D) -> void:
	if body == picked_prop:
		drop()
