@tool
extends Node


@export var targetname : String
@export var damage : int = 0
@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		damage = func_godot_properties['damage']
	get:
		return func_godot_properties 

func _ready() -> void:
	if not Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)

func use(_activator: Node) -> void:
	GameManager.player.hp -= damage
