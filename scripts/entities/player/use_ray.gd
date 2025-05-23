extends RayCast3D

@export var player : Player

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		var collider = get_collider()
		if collider and collider.has_method("use") and \
			'can_be_used_by_player' in collider and collider.can_be_used_by_player:
			collider.use(player)
