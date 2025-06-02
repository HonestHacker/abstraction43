@tool
extends Node3D


@export var targetname: String
@export var target: String
@export var limit: int

var activation_count: int = 0

@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
		limit = func_godot_properties['limit']
	get:
		return func_godot_properties

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)

func use(_activator: Node) -> void:
	activation_count += 1
	if activation_count <= limit:
		GameManager.use_targets(self)
