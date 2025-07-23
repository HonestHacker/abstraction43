@tool
extends Node3D

@export var targetname: String
@export var target: String

@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
	get:
		return func_godot_properties

var pressed = false

@export var anim_player : AnimationPlayer

func _ready() -> void:
	pass

func press():

	GameManager.use_targets(self)
	anim_player.play("press")
	pressed = true

func release():
	GameManager.use_targets(self)
	anim_player.play_backwards("press")
	pressed = false

func _on_activation_area_body_entered(body: Node3D) -> void:
	if body is RigidBody3D or body is Player:
		if not pressed:
			press()

func _on_activation_area_body_exited(body: Node3D) -> void:
	if body is RigidBody3D or body is Player:
		if pressed:
			release()
