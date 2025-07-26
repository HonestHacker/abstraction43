@tool
extends AudioStreamPlayer
class_name Narrator


signal sentence_finished(sentence_name: String)

@export var targetname: String
@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
	get:
		return func_godot_properties

var audio_stream_player: AudioStreamPlayer

var current_sentence_name: String = ""

func play_sentence(sentence_name: String, sentence: Sentence) -> void:
	sentence.play(self, sentence_name)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	bus = "Narrator"
	audio_stream_player = self
	audio_stream_player.finished.connect(_on_audio_stream_player_finished)
	sentence_finished.connect(_on_sentence_finished)
	GameManager.set_targetname(self, targetname)

# FIXME: Copypaste from npc_nn.gd
# Violation of DRY
func _on_audio_stream_player_finished() -> void:
	if current_sentence_name:
		sentence_finished.emit(current_sentence_name)

func _on_sentence_finished(sentence_name: String) -> void:
	#current_sentence_name = ""
	print("%s spoke a sentence %s." % [name, sentence_name])
