extends CharacterBody3D
class_name Player

const SaveAndLoad = preload("res://scripts/singletons/save_and_load.gd")

@export_category("Activity Controls")
## Whether the character is currently able to look around
@export var look_enabled : bool = true : 
	get:
		return move_enabled
	set(val): ## Automatically update the mouse mode when look_enabled changes
		look_enabled = val
		update_mouse_mode()
## Whether the character is currently able to move
@export var move_enabled : bool = true 
@export var jump_when_held : bool = false

@export_category("Input Definitions")
## Mouse sensitivity multiplier
@export var sensitivity : Vector2 = Vector2.ONE
## Movement actions
@export var move_forward : String
@export var move_backward : String
@export var move_left : String
@export var move_right : String
@export var jump : String

@export_category("Movement Variables")
## Gravity
@export var gravity : float = 30
## Acceleration when grounded
@export var ground_accelerate : float = 250
## Acceleration when in the air
@export var air_accelerate : float = 85
## Max velocity on the ground
@export var max_ground_velocity : float = 10
## Max velocity in the air
@export var max_air_velocity : float = 1.5
## Jump force multiplier
@export var jump_force : float = 1
## Friction
@export var friction : float = 6
## Bunnyhop window frame length
@export var bhop_frames : int = 2
@export var additive_bhop : bool = true
@export_category("Controlled Nodes")
@export var camera : Camera3D
@export var pda: PDA
@export_category("Debug")
@export var debug_mode_enabled : bool = false
@export var debug_wishdir_raycast : RayCast3D
@export var debug_velocity_raycast : RayCast3D


var can_move : bool = true
var frame_timer = 2

func update_mouse_mode():
	if look_enabled and camera:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func mouse_look(event):
	if look_enabled and can_move and camera and event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity.y))
		camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity.x))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func get_wishdir():
	if not can_move:
		return Vector3.ZERO
	return (transform.basis.z * Input.get_axis(move_forward, move_backward)) + (transform.basis.x * Input.get_axis(move_left, move_right))

func get_jump():
	return sqrt(4 * jump_force * gravity)

func accelerate(accelDir, prevVelocity, acceleration, max_vel, delta):
	var projectedVel = prevVelocity.dot(accelDir)
	var accelVel = clamp(max_vel - projectedVel, 0, acceleration * delta)
	return prevVelocity + accelDir * accelVel

func get_next_velocity(previousVelocity, delta):
	var grounded = is_on_floor()
	if grounded and (frame_timer >= bhop_frames):
		var speed = previousVelocity.length()
		if speed != 0:
			var drop = speed * friction * delta
			previousVelocity *= max(speed - drop, 0) / speed
	var max_vel = max_ground_velocity if grounded else max_air_velocity
	var accel = ground_accelerate if grounded else air_accelerate
	var next_velocity = accelerate(get_wishdir(), previousVelocity, accel, max_vel, delta)
	next_velocity += Vector3.DOWN * gravity * delta
	if Input.is_action_just_pressed(jump) and can_move and grounded:
		next_velocity.y = get_jump()
	return next_velocity

func update_frame_timer():
	if is_on_floor():
		frame_timer += 1
	else:
		frame_timer = 0

func handle_movement(delta):
	if $logic/pause_menu.visible or $logic/settings.visible or $logic/save.visible:
		return
	update_frame_timer()
	velocity = get_next_velocity(velocity, delta)
	move_and_slide()

func _physics_process(delta):
	if $logic/save.visible:
		if Input.is_action_just_pressed("ui_cancel"):
			$logic/save.visible = false
			update_mouse_mode()
		return
	if Input.is_action_just_pressed("ui_cancel") and not $logic/settings.visible and not $logic/save.visible:
		if $logic/pause_menu.visible:
			$logic/pause_menu.visible = false
			update_mouse_mode()
		else:
			$logic/pause_menu.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("ui_cancel") and $logic/settings.visible:
		$logic/settings.visible = false
		update_mouse_mode()

	handle_movement(delta)

func _unhandled_input(event):
	if $logic/pause_menu.visible or $logic/settings.visible or $logic/save.visible:
		return
	mouse_look(event)

func _ready():
	update_mouse_mode()
	var dir = DirAccess.open("res://save")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var save_files = []
		while file_name != "":
			if not dir.current_is_dir():
				save_files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		$logic/save/load.clear()
		for f in save_files:
			$logic/save/load.add_item(f)

func _on_load_button_pressed() -> void:
	if $logic/save/load.text.strip_edges() != "":
		var save_and_load = SaveAndLoad.new()
		save_and_load.load($logic/save/load.text.strip_edges(), self)

func _on_save_button_pressed() -> void:
	if $logic/save/save.text.strip_edges() != "":
		var save_and_load = SaveAndLoad.new()
		save_and_load.save(self, get_tree().current_scene.scene_file_path, $logic/save/save.text.strip_edges())

func _on_load_and_save_pressed() -> void:
	$logic/save.visible = true

func _on_continue_pressed() -> void:
	$logic/pause_menu.visible=false
	update_mouse_mode()

func _on_new_game_pressed() -> void:
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	$logic/settings.visible=true
	$logic/pause_menu.visible=false

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	$logic/settings.visible=false
	$logic/pause_menu.visible=true

func _on_fov_slider_value_changed(value: float) -> void:
	$Camera.fov = value
