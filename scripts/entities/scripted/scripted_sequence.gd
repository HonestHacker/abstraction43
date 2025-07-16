@tool
extends Node3D

@export var targetname: String
@export var target: String
@export var actorname: String
@export var animation: String
@export var movement_type: Actor.MovementType

@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
		actorname = func_godot_properties['actorname']
		animation = func_godot_properties['animation']
		movement_type = int(func_godot_properties['movement_type'])
	get:
		return func_godot_properties

var actor: Node



func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)
		actor = get_tree().get_first_node_in_group(actorname)
		actor.sequence_finished.connect(_on_sequence_finished)

func use(activator: Node) -> void:
	await get_tree().process_frame
	print("Activator: " + activator.targetname)
	actor.play_sequence(targetname, animation, global_position, movement_type)

func _on_sequence_finished(sequence_name: String) -> void:
	if sequence_name == targetname:
		GameManager.use_targets(self)
