extends TextureRect
class_name ActionTextureRect


var playing_peek_anim := false
var time := 0.0

func _ready() -> void:
	pivot_offset = Vector2(16, 16)

func _process(delta: float) -> void:
	#if get_index() == 0:
		#scale = Vector2.ONE * (1 + (sin(time * 3)) / 10)
		#time += delta
	pass
