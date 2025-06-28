extends Area3D


@export var action: Script
@export var rotation_speed: float = deg_to_rad(90)
@export var collision_shape: CollisionShape3D

var picked_up = false : 
	set(value):
		picked_up = value
		visible = not picked_up
		collision_shape.disabled = picked_up

func set_picked_up(value: bool) -> void:
	picked_up = value

func _on_body_entered(body: Node3D) -> void:
	if body is Player and not picked_up:
		body.pda.action_queue.push(action.new())
		set_picked_up.call_deferred(true)

func _physics_process(delta: float):
	rotation.y = Time.get_ticks_msec() / 1000.0 * rotation_speed
