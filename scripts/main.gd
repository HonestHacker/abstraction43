extends Node


@export var main_menu : Control
@export_file("*.tscn") var map_scene : String

var map_node : Node
var savefile : String :
	set(value):
		savefile = value
		if map_node:
			SaveloadManager.restore(savefile)

func _process(delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(map_scene)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var map = ResourceLoader.load_threaded_get(map_scene)
		map_node = map.instantiate()
		add_child(map_node)
		main_menu.is_pause_menu = true
		main_menu.visible = false
		if savefile:
			SaveloadManager.restore(savefile)

func _on_main_menu_new_game_started() -> void:
	ResourceLoader.load_threaded_request(map_scene)

func _on_main_menu_load_game_pressed(filename: String) -> void:
	savefile = filename
	if not map_node:
		ResourceLoader.load_threaded_request(map_scene)
