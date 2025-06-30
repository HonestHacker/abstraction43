extends Node3D
class_name PDA


@export var player : Player
@export var action_queue: ActionQueue
@export var hud: Control


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pda_activate") and player.hp > 0:
		action_queue.activate_action()
		
