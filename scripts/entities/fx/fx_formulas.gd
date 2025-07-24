@tool
extends Node3D


const FORMULA = preload("res://scenes/entities/temp_fx_formula.tscn")

@export var targetname : String
@export var target : String
@export var interval : float
@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
		interval = func_godot_properties['interval']
	get:
		return func_godot_properties

var activated := false
var timer := 0.0

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	timer += delta
	if timer > interval and activated:
		var formula := FORMULA.instantiate()
		formula.rotation = rotation
		add_child(formula)
		timer = -10000000

func use(_activator: Node) -> void:
	activated = not activated
