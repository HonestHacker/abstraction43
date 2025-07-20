extends Action
class_name GravityInversionAction

var tween: Tween

func _init() -> void:
	icon = load("res://textures/ui/pda/gravity_inverse32_negate.png")

func do():
	if player.is_flipping:
		return
	player.is_flipping = true
	player.gravity_scale *= -1
	#player.sensitivity.y *= -1
	PhysicsServer3D.area_set_param(
		get_viewport().find_world_3d().space,
		PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR,
		Vector3(0,-1,0) * player.gravity_scale
	)
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(player, "rotation:z", player.rotation.z + PI, 1.0)
	tween.tween_callback(func(): player.is_flipping = false)
	tween.tween_callback(finished.emit)
