extends Area3D


@export var action: Script
@export var rotation_speed: float = deg_to_rad(90)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.pda.action_queue.push(action.new())
		queue_free()

func _physics_process(delta: float):
	rotation.y = Time.get_ticks_msec() / 1000.0 * rotation_speed
