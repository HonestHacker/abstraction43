@tool
extends Node3D


@export var targetname: String
@export var target: String
@export var force: float = 10

@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
		force = func_godot_properties['force']
	get:
		return func_godot_properties

var activated := false

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	GameManager.player.move_enabled = not activated
	if activated:
		var dir := transform.origin - GameManager.player.transform.origin
		# Newton and Coulomb are cool men
		var vel := dir * force / (dir.length_squared() + 1)
		GameManager.player.velocity += vel

func use(_activator: Node) -> void:
	activated = not activated
