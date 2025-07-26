extends Control


signal new_game_started
signal load_game_pressed(filename: String)

@export var main_menu_background : TextureRect
@export var pause_menu_background : ColorRect
@export var load_game_window : Window
@export var settings_window : Window
@export var music : AudioStreamPlayer

@onready var is_pause_menu := false :
	set(value):
		is_pause_menu = value
		main_menu_background.visible = not is_pause_menu
		pause_menu_background.visible = is_pause_menu
		$ButtonContainer/NewGame.visible = not is_pause_menu
		$ButtonContainer/SaveGame.visible = is_pause_menu

@onready var is_paused := false :
	set(value):
		is_paused = value
		visible = is_paused
		get_tree().paused = is_paused
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED
		load_game_window.hide()
		settings_window.hide()
		music.stop()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_open_menu") and is_pause_menu:
		is_paused = not is_paused

func _on_new_game_started() -> void:
	load_game_window.hide()
	settings_window.hide()
	music.stop()

func _on_load_game_pressed() -> void:
	load_game_window.popup_centered()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	settings_window.visible = true
	settings_window.tree_exited.connect(_on_settings_closed)

func _on_settings_closed() -> void:
	settings_window.visible = false

func _on_settings_window_close_requested() -> void:
	settings_window.visible = false

func _on_save_game_pressed() -> void:
	SaveloadManager.save("%s.sav" % Time.get_datetime_string_from_system().validate_filename())

func _on_load_game(filename: String) -> void:
	load_game_window.hide()
	settings_window.hide()
	music.stop()


func _on_new_game_pressed() -> void:
	new_game_started.emit()
