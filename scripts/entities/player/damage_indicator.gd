extends ColorRect


func _process(delta: float) -> void:
	color.a = -0.005 * $"..".hp + 0.5
