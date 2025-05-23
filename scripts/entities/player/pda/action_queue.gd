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

func activate_action() -> void:
	var action = peek()
	if action:
		var is_done = action.do()
		if is_done:
			pda.hud.actions.get_child(0).queue_free()
			action.queue_free()
