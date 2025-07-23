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

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)
		await get_tree().process_frame
		GameManager.use_targets(self)
