@tool
extends AnimatableBody3D

const DOOR_OPENNING_TIME = 0.8

enum Direction {
	DOWN,
	UP
}

enum Action {
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
			Action.IDLING,
			Action.OPEN,
			Action.CLOSE,
			Action.MOVING_UP if direction == Direction.UP else Action.MOVING_DOWN,
			Action.OPEN,
			Action.CLOSE
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
		Action.IDLING:
			idle()
		Action.OPEN:
			open()
		Action.CLOSE:
			close()
		Action.MOVING_UP:
			transform.origin.y += speed * delta
		Action.MOVING_DOWN:
			transform.origin.y -= speed * delta

func use(_activator: Node) -> void:
	idx += 1
