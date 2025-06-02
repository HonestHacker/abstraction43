@tool
extends Area3D

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

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if !Engine.is_editor_hint():
		visible = false

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		GameManager.use_targets(self)
