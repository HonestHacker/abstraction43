extends Control

@onready var FOV_Slider = $FOV
@onready var Sensitivity_Slider = $Sensetivity

func _ready():
	FOV_Slider.text_changed.connect(_on_FOV_changed)
	Sensitivity_Slider.value_changed.connect(_on_Sensitivity_changed)

func _on_FOV_changed(value):
	if GameManager.player:
		GameManager.player.update_fov(float(value))

func _on_Sensitivity_changed(value):
	if GameManager.player:
		GameManager.player.sensitivity = Vector2(value, value) # Assuming sensitivity is the same for X and Y

func _on_back_button_pressed() -> void:
	queue_free()
