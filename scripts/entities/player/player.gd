extends CharacterBody3D
class_name Player

static var Preload := preload("res://scripts/ui/hud/pause_menu.gd").new()

@export_category("Activity Controls")
@export var look_enabled : bool = true : 
	get:
		return move_enabled
	set(val):
		look_enabled = val
		update_mouse_mode()
@export var move_enabled : bool = true 
@export var jump_when_held : bool = false

@export_category("Input Definitions")
@export var sensitivity : Vector2 = Vector2.ONE
@export var move_forward : String
@export var move_backward : String
@export var move_left : String
@export var move_right : String
@export var jump : String

@export_category("Movement Variables")
@export var gravity : float = 30
@export var ground_accelerate : float = 250
@export var air_accelerate : float = 85
@export var max_ground_velocity : float = 10
@export var max_air_velocity : float = 1.5
@export var jump_force : float = 1
@export var friction : float = 6
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
		rotate_y(deg_to_rad(-event.relative.x * sensitivity.x))
		camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity.y))
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

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Preload.on_start($logic/save/load)

func _physics_process(delta):
	preload("res://scripts/ui/hud/pause_menu.gd").new().for_process($logic/settings, $logic/save, $logic/pause_menu)
	handle_movement(delta)

func _unhandled_input(event):
	if $logic/pause_menu.visible or $logic/settings.visible or $logic/save.visible:
		return
	mouse_look(event)

func _on_exit_pressed() -> void:
	Preload.on_exit_pressed(get_tree())

func _on_settings_pressed() -> void:
	Preload.on_settings_pressed($logic/settings,$logic/pause_menu)

func _on_load_and_save_pressed() -> void:
	Preload.on_load_and_save_pressed($logic/save, $logic/pause_menu)

func _on_new_game_pressed() -> void:
	Preload.on_new_game_pressed(get_tree())

func _on_continue_pressed() -> void:
	Preload.on_continue_pressed($logic/pause_menu,self)

func _on_load_button_pressed() -> void:
	Preload.on_load_button_pressed($logic/save/load, self, $Camera)

func _on_save_button_pressed() -> void:
	Preload.on_save_button_pressed($logic/save/save, self, $Camera, get_tree())

func _on_fov_slider_value_changed(value: float) -> void:
	Preload.on_fov_slider_value_changed(value,$Camera)
