@tool
extends AudioStreamPlayer


@export var targetname : String
@export var target : String
@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
		stream = load(func_godot_properties['path'])
	get:
		return func_godot_properties

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)
		add_to_group("ost")
		bus = "Music"

func use(_activator: Node) -> void:
	print(targetname, " is playing")
	get_tree().call_group("ost", "stop")
	await get_tree().process_frame
	play()
