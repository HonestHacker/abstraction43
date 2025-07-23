@tool
extends Node3D


@export var targetname : String
@export var target : String
@export var hint : String
@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
		hint = func_godot_properties['hint']
	get:
		return func_godot_properties

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)

func show_hint() -> void:
	var tutorial = get_tree().get_first_node_in_group("tutorial")
	if tutorial:
		tutorial.show_text(hint, 7.0)

func use(_activator: Node) -> void:
	show_hint()
