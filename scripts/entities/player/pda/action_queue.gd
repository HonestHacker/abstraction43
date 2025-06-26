extends Node
class_name ActionQueue

@onready var pda : PDA = $".."


func push(action: Action) -> void:
	add_child(action)
	var action_texture = TextureRect.new()
	action_texture.texture = action.icon
	pda.hud.actions.add_child(action_texture)

func peek() -> Action:
	if get_child_count() > 0:
		return get_child(0)
	return null

func pop():
	pda.hud.actions.get_child(0).queue_free()
	peek().queue_free()

func activate_action() -> void:
	var action = peek()
	if action:
		if not action.finished.is_connected(pop):
			action.finished.connect(pop)
		action.do()
