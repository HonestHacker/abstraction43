extends Action
class_name DashAction

func _init() -> void:
	icon = load("res://textures/ui/pda/dash_action32_negate.png")

func do():
	var wishdir = player.get_wishdir() 
	if wishdir:
		await make_prejump()
		player.velocity = player.get_wishdir() * 25 + Vector3.UP * 5
		finished.emit()
