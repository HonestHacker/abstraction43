extends Window

@export var fov_slider : Slider
@export var sensitivity_slider : Slider

func _ready():
	fov_slider.value_changed.connect(_on_FOV_changed)
	sensitivity_slider.value_changed.connect(_on_Sensitivity_changed)

func _on_FOV_changed(value):
	if GameManager.player:
		GameManager.player.camera.fov = float(value)

func _on_Sensitivity_changed(value):
	if GameManager.player:
		GameManager.player.sensitivity = Vector2(value, value)

func _on_back_button_pressed() -> void:
	queue_free()
