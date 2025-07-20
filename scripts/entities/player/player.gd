extends CharacterBody3D
class_name Player


signal died

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
@export var sensitivity : Vector2 = Vector2.ONE :
	get:
		return Vector2(sensitivity.x, sensitivity.y * gravity_scale)
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
## Whether bunnyhopping should be 'additive' - whether it should 
## converge to the player's wishdir
@export var additive_bhop : bool = true

@export_category("Health Properties")
## Maximum health points
@export var max_hp : int = 100

@export_category("Controlled Nodes")
## Camera to update with mouse controls
@export var camera : Camera3D
## The PDA
@export var pda: PDA
@export var alive_camera_position : Node3D
@export var died_camera_position : Node3D

@export_category("Debug")
## Whether to look for and update debug raycasts
@export var debug_mode_enabled : bool = false
## Raycast to update with wishdir
@export var debug_wishdir_raycast : RayCast3D
## Raycast to update with velocity
@export var debug_velocity_raycast : RayCast3D

var can_move : bool = true : 
	get:
		return move_enabled and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	set(val):
		can_move = val

# Gravity inversion variables
var gravity_scale: float = 1.0
var is_flipping: bool = false

var should_jump := false

# Health variables
var hp := max_hp :
	set(value):
		if value <= 0:
			died.emit()
		elif hp <= 0:
			revive()
		hp = value

## Utility function for setting mouse mode, always visible if camera is unset
func update_mouse_mode():
	if look_enabled and camera:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func mouse_look(event):
	# Mouse look controls, don't activate if camera is unset
	if look_enabled and can_move and camera:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * sensitivity.y))
			camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity.x))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

## Get player's intended direction. (0,0) if movement disabled
func get_wishdir():
	if not can_move:
		return Vector3.ZERO
	return Vector3.ZERO + \
			(transform.basis.z * Input.get_axis(move_forward, move_backward)) +\
			(transform.basis.x * Input.get_axis(move_left, move_right))

func is_on_ground() -> bool:
	return is_on_floor() if gravity_scale >= 0 else is_on_ceiling()

## Get jump force
func get_jump():
	return sqrt(4 * jump_force * gravity) * gravity_scale

## Get gravity force
func get_player_gravity(delta):
	return gravity * gravity_scale * delta

######
# All this code was only possible thanks to the technical writeup by Flafla2 available below.
# Most of this was shamelessly adjusted from direct copy-pasting.
#
# Bunnyhopping from the Programmer's Perspective
# https://adrianb.io/2015/02/14/bunnyhop.html
######

## Source-like acceleration function
func accelerate(accelDir, prevVelocity, acceleration, max_vel, delta):
	# Calculate projected velocity for the next frame
	var projectedVel = prevVelocity.dot(accelDir)
	# Calculate the accelerated velocity given the maximum velocity, projected velocity, and current acceleration
	var accelVel = clamp(max_vel - projectedVel, 0, acceleration * delta)
	# Return the previous velocity in addition to the new velocity post acceleration
	return prevVelocity + accelDir * accelVel

## Get intended velocity for the next frame
func get_next_velocity(previousVelocity, delta):
	var grounded = is_on_ground() 
	var can_jump = grounded # Jumping is a seperate var in case of additive bunnyhopping modifying grounded
	
	# Apply friction if player is grounded, and if the frame_timer indicates it should be applied
	if grounded and (frame_timer >= bhop_frames):
		var speed = previousVelocity.length()
		if speed != 0:
			var drop = speed * friction * delta
			previousVelocity *= max(speed - drop, 0) / speed
	else:
		# If bunnyhopping is additive, we should use the air velocity and accelerate values for all frames
		# that the bunnyhop is possible
		if not additive_bhop:
			grounded = false
	
	var max_vel = max_ground_velocity if grounded else max_air_velocity
	var accel = ground_accelerate if grounded else air_accelerate
	
	# Calculate velocity for next frame
	var velocity = accelerate(get_wishdir(), previousVelocity, accel, max_vel, delta)
	# Apply gravity
	velocity += Vector3.DOWN * get_player_gravity(delta)
	
	# Apply jump if desired
	if (Input.is_action_pressed(jump) if jump_when_held else Input.is_action_just_pressed(jump) or should_jump) \
			and can_move and can_jump:
		velocity.y = get_jump()
		should_jump = false
	
	# Return the new velocity
	return velocity

## Count of frames since last grounded
var frame_timer = bhop_frames
## Update frame timer if necessary
func update_frame_timer():
	if is_on_ground():
		frame_timer += 1
	else:
		frame_timer = 0

## Get frame velocity and update character body
func handle_movement(delta):
	# Update the bhop frame timer
	update_frame_timer() 
	velocity = get_next_velocity(velocity, delta)
	move_and_slide()

func revive() -> void:
	move_enabled = true
	camera.transform.origin = alive_camera_position.transform.origin
	

func die() -> void:
	move_enabled = false
	camera.transform.origin = died_camera_position.transform.origin
	await get_tree().create_timer(3.0).timeout
	SaveloadManager.restore(SaveloadManager.get_savefile_list()[0])

## Conditionally update debug raycasts
func draw_debug():
	if not debug_mode_enabled:
		return
	var debug_velocity = velocity
	## We don't usually want to visualize the y component here
	debug_velocity.y = 0
	# Print velocity in debug mode
	print("BHop3D | Velocity: ", debug_velocity.length())
	if debug_velocity_raycast: 
		debug_velocity_raycast.target_position = debug_velocity
	if debug_wishdir_raycast: 
		debug_wishdir_raycast.target_position = get_wishdir()

### Godot internal functions
func _physics_process(delta):
	handle_movement(delta)
	draw_debug()

func _unhandled_input(event):
	mouse_look(event)

func _ready():
	update_mouse_mode()
	died.connect(die)
	GameManager.player = self
