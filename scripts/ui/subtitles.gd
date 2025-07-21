extends Control
class_name Subtitles

@export var label : RichTextLabel
@export var type : String = "subtitles"

var tween: Tween

func _ready() -> void:
	add_to_group(type)

func show_text(text: String, fade_time: float) -> void:
	modulate.a = 1.0
	label.text = text
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
