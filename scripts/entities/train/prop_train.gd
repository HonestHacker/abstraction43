@tool
extends AnimatableBody3D


enum State {
	IDLING,
	RIDING,
	OPENING,
	CLOSING
}

@export var targetname: String
@export var velocity: Vector3 = Vector3(0, 0, -10)
@export var animation_player: AnimationPlayer
@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		velocity = func_godot_properties['velocity']
	get:
		return func_godot_properties

var opened := false

var train_program: Array

var idx := 0 : 
	set(value):
		idx = value if value < len(train_program) else len(train_program) - 1

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)
		train_program = [
			State.IDLING,
			State.RIDING,
			State.IDLING,
			State.OPENING,
			State.CLOSING
		]

func idle():
	if opened:
		animation_player.play("RESET")
		opened = false

func open():
	if not opened:
		animation_player.play('open_right')
		opened = true

func close():
	if opened:
		animation_player.play_backwards('open_right')
		opened = false

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	match train_program[idx]:
		State.IDLING:
			idle()
		State.RIDING:
			transform.origin += velocity * delta
		State.OPENING:
			open()
		State.CLOSING:
			close()

func use(_activator: Node) -> void:
	idx += 1
