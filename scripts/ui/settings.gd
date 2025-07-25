extends Window

@export var resolution : OptionButton
@export var fov_slider : Slider
@export var sensitivity_slider : Slider
@export var audio_volume : Slider
@export var fullscreen_toggle: CheckButton

const SETTINGS_PATH = "user://settings.cfg"

func _ready():
	# Initialize resolution dropdown
	_populate_resolutions()
	
	# Connect signals
	resolution.item_selected.connect(_on_resolution_selected)
	if fullscreen_toggle:
		fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	if fov_slider:
		fov_slider.value_changed.connect(_on_FOV_changed)
	if sensitivity_slider:
		sensitivity_slider.value_changed.connect(_on_Sensitivity_changed)
	if audio_volume:
		audio_volume.value_changed.connect(_on_audio_volume_changed)
	get_tree().current_scene.game_loaded.connect(_on_game_loaded)
	# Load settings on startup
	load_settings()

func _populate_resolutions():
	# Clear existing items
	resolution.clear()
	
	# Common resolutions
	var resolutions = [
		Vector2i(1920, 1080),
		Vector2i(1600, 900),
		Vector2i(1366, 768),
		Vector2i(1280, 720),
		Vector2i(1024, 768),
		Vector2i(800, 600)
	]
	
	# Add resolutions to dropdown
	for res in resolutions:
		resolution.add_item("%d x %d" % [res.x, res.y])
		resolution.set_item_metadata(resolution.get_item_count() - 1, res)
	
	# Add current resolution if not in list
	var current_size = get_window().size
	var current_text = "%d x %d (Current)" % [current_size.x, current_size.y]
	resolution.add_item(current_text)
	resolution.set_item_metadata(resolution.get_item_count() - 1, current_size)
	resolution.select(0)

func _on_resolution_selected(index: int):
	var selected_res = resolution.get_item_metadata(index)
	get_tree().get_root().size = selected_res
	resolution.set_item_text(index, resolution.get_item_text(index).replace(" (Current)", ""))
	resolution.set_item_text(resolution.get_item_count() - 1, "%d x %d (Current)" % [selected_res.x, selected_res.y])
	resolution.select(resolution.get_item_count() - 1)
	save_settings()  # Save when changed

func _on_fullscreen_toggled(button_pressed: bool):
	if button_pressed:
		get_tree().get_root().mode = Window.MODE_FULLSCREEN
	else:
		get_tree().get_root().mode = Window.MODE_WINDOWED
	save_settings()  # Save when changed

func _on_FOV_changed(value):
	if GameManager.player:
		GameManager.player.camera.fov = float(value)
	save_settings()  # Save when changed

func _on_Sensitivity_changed(value):
	if GameManager.player:
		GameManager.player.sensitivity = Vector2(value, value)
	save_settings()  # Save when changed

func _on_back_button_pressed() -> void:
	save_settings()  # Save when closing
	queue_free()

# New functions for saving/loading settings
func save_settings():
	var config = ConfigFile.new()
	
	# Save resolution as string (widthxheight)
	var res = resolution.get_item_metadata(resolution.selected)
	config.set_value("graphics", "resolution", "%dx%d" % [res.x, res.y])
	
	# Save other settings
	config.set_value("graphics", "fullscreen", fullscreen_toggle.button_pressed)
	config.set_value("graphics", "fov", fov_slider.value)
	config.set_value("controls", "sensitivity", sensitivity_slider.value)
	config.set_value("audio", "volume", audio_volume.value)
	
	# Save to file
	config.save(SETTINGS_PATH)
	print("Settings saved to: ", SETTINGS_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	
	if err != OK:  # File doesn't exist or error
		print("Using default settings")
		return
	
	# Load resolution
	var res_str = config.get_value("graphics", "resolution", "1920x1080")
	var res_parts = res_str.split("x")
	var loaded_res = Vector2i(int(res_parts[0]), int(res_parts[1]))
	
	# Apply resolution and select in dropdown
	for i in range(resolution.item_count):
		var res = resolution.get_item_metadata(i)
		if res == loaded_res:
			resolution.select(i)
			_on_resolution_selected(i)  # Apply resolution
			break
	
	# Load fullscreen setting
	var fullscreen = config.get_value("graphics", "fullscreen", false)
	fullscreen_toggle.button_pressed = fullscreen
	_on_fullscreen_toggled(fullscreen)  # Apply setting
	
	# Load FOV
	var fov = config.get_value("graphics", "fov", 70.0)
	fov_slider.value = fov
	_on_FOV_changed(fov)  # Apply setting
	
	# Load sensitivity
	var sensitivity = config.get_value("controls", "sensitivity", 0.5)
	sensitivity_slider.value = sensitivity
	_on_Sensitivity_changed(sensitivity)  # Apply setting
	
	# Load audio volume
	var volume = config.get_value("audio", "volume", 0.5)
	audio_volume.value = volume
	_on_audio_volume_changed(volume)
	
	print("Settings loaded from: ", SETTINGS_PATH)

func _on_game_loaded():
	# The code is shitty
	_on_FOV_changed(fov_slider.value)
	_on_Sensitivity_changed(sensitivity_slider.value)

func _on_audio_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100))
	save_settings()
