@tool
extends Node3D

@export var targetname: String
@export var target: String
@export var actorname: String
@export var sentence: Sentence

@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
		actorname = func_godot_properties['actorname']
		sentence = load(func_godot_properties['sentence'])
	get:
		return func_godot_properties

var actor: Node

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)
		actor = get_tree().get_first_node_in_group(actorname)
		actor.sentence_finished.connect(_on_sentence_finished)

func use(_activator: Node) -> void:
	actor.play_sentence(targetname, sentence)

func _on_sentence_finished(sentence_name: String) -> void:
	print(sentence_name, ":", target)
	if sentence_name == targetname:
		GameManager.use_targets(self)
