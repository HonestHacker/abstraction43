extends Node
class_name ActionQueue

@onready var pda : PDA = $".."
@onready var actions_dump : Array[String] = [] :
	set(value):
		clear()
		for x in value:
			var action = load(x).new()
			push(action)
	get:
		var value : Array[String] = []
		for x in get_children():
			value.append(x.get_script().resource_path)
		return value

func push(action: Action) -> void:
	add_child(action)
	var action_texture = ActionTextureRect.new()
	action_texture.texture = action.icon
	pda.hud.actions.add_child(action_texture)

func peek() -> Action:
	if get_child_count() > 0:
		return get_child(0)
	return null

func pop() -> void:
	pda.hud.actions.get_child(0).queue_free()
	peek().queue_free()

func clear() -> void:
	for x in get_children():
		x.queue_free()
	for x in pda.hud.actions.get_children():
		x.queue_free()

func activate_action() -> void:
	var action = peek()
	if action:
		if not action.finished.is_connected(pop):
			action.finished.connect(pop)
		action.do()
