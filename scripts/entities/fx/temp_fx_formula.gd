extends Node3D

@export var latex : Node
@export var texts : Array[String]
@export var colors : Array[Color]
@export var speed : float
@export var lifetime : float

var time = 0.0

func _ready() -> void:
	latex.LatexExpression = texts.pick_random()
	latex.MathColor = colors.pick_random()

func _process(delta: float) -> void:
	transform.origin -= transform.basis.z * speed * delta
	time += delta
	if time > lifetime:
		queue_free()
