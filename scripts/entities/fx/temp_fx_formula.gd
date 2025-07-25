extends Node3D

@export var latex : Node
@export var texts : Array[String]
@export var colors : Array[Color]
@export var speed : float
@export var speed_dispersion : float
@export var lifetime : float

var time = 0.0

func pick_random_formula():
	latex.LatexExpression = texts.pick_random()
	latex.MathColor = colors.pick_random()
	latex.Render()

func _ready() -> void:
	pick_random_formula()
	speed += randf_range(-speed_dispersion / 2, speed_dispersion / 2)

func _process(delta: float) -> void:
	transform.origin.z -= speed * delta
	time += delta
	if time > lifetime:
		queue_free()
