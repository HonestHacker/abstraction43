@tool
extends Area3D


@export var environment : Environment
@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		environment = load(func_godot_properties['environment'])
	get:
		return func_godot_properties 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body is Player:
		body.camera.environment = environment

func _on_body_exited(body):
	if body is Player:
		body.camera.environment = null
