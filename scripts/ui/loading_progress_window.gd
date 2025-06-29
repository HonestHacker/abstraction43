extends Window

@export var progress_bar : ProgressBar

@onready var main := get_tree().get_current_scene()

func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(main.map_scene, progress)
	visible = not (progress[0] == 0.0)
	if progress and progress[0] > 0:
		progress_bar.value = progress[0] * 100
