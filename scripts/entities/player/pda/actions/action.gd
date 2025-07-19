extends Node
class_name Action

signal finished

@onready var player: Player = $"../../../.."

var icon : Texture2D

func make_prejump():
	# gumbelmachine's skill issue fix
	var is_on_ground = player.is_on_ground()
	player.should_jump = is_on_ground
	if is_on_ground:
		await get_tree().physics_frame
		await get_tree().physics_frame

func do():
	pass
