extends Action
class_name SuperJumpAction

func _init() -> void:
	icon = load("res://textures/ui/pda/jump_action32_negate.png")

func do():
	await make_prejump()
	player.velocity.y = 25 * player.gravity_scale
	finished.emit()
