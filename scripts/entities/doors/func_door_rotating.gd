@tool
extends AnimatableBody3D

@export var targetname: String
@export var can_be_used_by_player: bool
@export var distance: float
@export var duration: float

@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		distance = func_godot_properties['distance']
		duration = func_godot_properties['duration']
		can_be_used_by_player = func_godot_properties['can_be_used_by_player']
	get:
		return func_godot_properties 

var closed := true

@onready var default_distance = rotation.y

var tween: Tween

func _ready() -> void:
	var serializable := Serializable.new()
	add_child(serializable)
	serializable.add_object_properties(self, ["rotation"])
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)

func open() -> void:
	if tween:
		tween.kill()
	closed = false
	tween = get_tree().create_tween()
	tween.tween_property(self, "rotation:y", default_distance + deg_to_rad(distance), duration)
	

func close() -> void:
	if tween:
		tween.kill()
	closed = true
	tween = get_tree().create_tween()
	tween.tween_property(self, "rotation:y", default_distance, duration)

func use(_activator: Node) -> void:
	if closed:
		open()
	else:
		close()
