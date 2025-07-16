@tool
extends CharacterBody3D
class_name Actor


signal sequence_finished(sequence_name: String)
signal sentence_finished(sentence_name: String)

enum MovementType {
	NO = 0,
	LOOKING = 1,
	WALKING = 2,
	TELEPORTING = 3
}

@export var targetname: String
@export var animation_player: AnimationPlayer
@export var audio_stream_player: AudioStreamPlayer3D
@export var speed: float

@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
	get:
		return func_godot_properties

var current_sequence_name: String = ""
var current_sentence_name: String = ""
var in_sequence := false 

func face_at(target: Vector3) -> void:
	look_at(target, Vector3.UP, true)
	rotation.x = 0
	rotation.z = 0

var moving_to_target: bool = false :
	set(value):
		moving_to_target = value
		if not moving_to_target:
			animation_player.play("idle01")
var movement_target: Vector3 = Vector3.ZERO

func emit_current_sequence_finished():
	sequence_finished.emit(current_sequence_name)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	audio_stream_player.finished.connect(_on_audio_stream_player_finished)
	sequence_finished.connect(_on_sequence_finished)
	sentence_finished.connect(_on_sentence_finished)
	GameManager.set_targetname(self, targetname)

func play_sequence(sequence_name: String, animation: String, target_position: Vector3, movement_type: MovementType=MovementType.WALKING) -> void:
	if in_sequence:
		return
	if sequence_name:
		current_sequence_name = sequence_name
	in_sequence = true
	# Reset any previous movement
	moving_to_target = false
	velocity = Vector3.ZERO
	
	# Start new animation and movement
	if animation_player:
		animation_player.play(animation)
	print("%s starts performing a sequence %s. The animation is %s" % [name, sequence_name, animation_player.current_animation])
	match movement_type:
		MovementType.NO:
			animation_player.animation_finished.connect(emit_current_sequence_finished)
		MovementType.LOOKING:
			face_at(target_position)
			sequence_finished.emit(current_sequence_name)
		MovementType.WALKING:
			moving_to_target = true
			movement_target = target_position
		MovementType.TELEPORTING:
			global_position = target_position
			sequence_finished.emit(current_sequence_name)

func play_sentence(sentence_name: String, sentence: Sentence) -> void:
	current_sentence_name = sentence_name
	if audio_stream_player:
		# Stop any currently playing audio
		audio_stream_player.stop()
		
		# Configure and play new audio
		audio_stream_player.stream = sentence.audio_stream
		audio_stream_player.play()
		var subtitles = get_tree().get_first_node_in_group("subtitles")
		if subtitles:
			subtitles.show_text(sentence.subtitles, sentence.audio_stream.get_length() + 5.0)

func _physics_process(delta: float) -> void:
	if moving_to_target:
		var direction = movement_target - global_position
		var distance = direction.length()
		
		# Check if reached target
		if distance < 0.1:
			moving_to_target = false
			sequence_finished.emit(current_sequence_name)
			velocity = Vector3.ZERO
			if in_sequence:
				sequence_finished.emit(current_sequence_name)
		else:
			# Move toward target
			face_at(movement_target)
			velocity = direction.normalized() * speed
			move_and_slide()

func _on_audio_stream_player_finished() -> void:
	if current_sentence_name:
		sentence_finished.emit(current_sentence_name)

func _on_sentence_finished(sentence_name: String) -> void:
	#current_sentence_name = ""
	print("%s spoke a sentence %s." % [name, sentence_name])

func _on_sequence_finished(sequence_name: String) -> void:
	#current_sentence_name = ""
	in_sequence = false
	print("%s performed a sequence %s. The animation is %s" % [name, sequence_name, animation_player.current_animation])
	if animation_player.animation_finished.is_connected(emit_current_sequence_finished):
		animation_player.animation_finished.disconnect(emit_current_sequence_finished)
