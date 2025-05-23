extends Action
class_name SuperJumpAction

func _init() -> void:
	icon = load("res://textures/ui/pda/jump_action32_negate.png")

func do() -> bool:
	player.velocity.y += 25
	return true
