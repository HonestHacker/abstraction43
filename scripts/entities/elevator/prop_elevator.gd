@tool
extends AnimatableBody3D


enum Direction {
	DOWN,
	UP
}

enum State {
	IDLING,
	CLOSE,
	OPEN,
	MOVING_UP,
	MOVING_DOWN
}

@export var targetname: String
@export var direction: Direction = Direction.DOWN
@export var speed: float = 1.0
@export var animation_player: AnimationPlayer
@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		direction = int(func_godot_properties['direction'])
		speed = func_godot_properties['speed']
	get:
		return func_godot_properties

var opened := false

var elevator_program: Array

var idx := 0 : 
	set(value):
		idx = value if value < len(elevator_program) else len(elevator_program) - 1

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.set_targetname(self, targetname)
		elevator_program =[
			State.IDLING,
			State.OPEN,
			State.CLOSE,
			State.MOVING_UP if direction == Direction.UP else State.MOVING_DOWN,
			State.OPEN,
			State.CLOSE
		]

func idle():
	if opened:
		animation_player.play("RESET")
		opened = false

func open():
	if not opened:
		animation_player.play('open')
		opened = true

func close():
	if opened:
		animation_player.play_backwards('open')
		opened = false

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	match elevator_program[idx]:
		State.IDLING:
			idle()
		State.OPEN:
			open()
		State.CLOSE:
			close()
		State.MOVING_UP:
			transform.origin.y += speed * delta
		State.MOVING_DOWN:
			transform.origin.y -= speed * delta

func use(_activator: Node) -> void:
	idx += 1
