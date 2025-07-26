extends Resource
class_name Sentence


@export var audio_stream: AudioStream
@export_multiline var subtitles: String

func play(actor: Node, sentence_name: String):
	actor.current_sentence_name = sentence_name
	if actor.audio_stream_player:
		#var bus_index := AudioServer.get_bus_index("Music")
		#var value := AudioServer.get_bus_volume_linear(bus_index)
		#print(value)
		#AudioServer.set_bus_volume_linear(
		#	bus_index,
		#	value / 100
		#)
		# Stop any currently playing audio
		actor.audio_stream_player.stop()
		
		# Configure and play new audio
		actor.audio_stream_player.stream = audio_stream
		#if not actor.audio_stream_player.finished.is_connected(reset_music_volume):
		#	actor.audio_stream_player.finished.connect(reset_music_volume)
		actor.audio_stream_player.play()
		var ui_subtitles = actor.get_tree().get_first_node_in_group("subtitles")
		if ui_subtitles:
			ui_subtitles.show_text(subtitles, audio_stream.get_length() + 5.0)

func reset_music_volume():
	#var bus_index := AudioServer.get_bus_index("Music")
	#var value := AudioServer.get_bus_volume_linear(bus_index)
	#print(value)
	#AudioServer.set_bus_volume_linear(
	#	bus_index,
	#	value * 100
	#)
	pass
