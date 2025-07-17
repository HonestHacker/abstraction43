@tool
extends Node3D


@export var targetname: String
@export var target: String
@export var degrees_seen = 90

@export var func_godot_properties: Dictionary :
	set(value):
		func_godot_properties = value
		if !Engine.is_editor_hint():
			return
		targetname = func_godot_properties['targetname']
		target = func_godot_properties['target']
		degrees_seen = func_godot_properties['degrees_seen']
	get:
		return func_godot_properties

var is_visible := false :
	set(value):
		if is_visible != value:
			GameManager.use_targets(self)

func get_visibility() -> bool:
	var player = GameManager.player
	if not player:
		return false
	var camera = player.camera
	if not camera:
		return false
		
	var camera_pos = camera.global_position
	var trigger_pos = global_position
	
	# Calculate direction to trigger and distance
	var dir_to_trigger = (trigger_pos - camera_pos)
	var distance = dir_to_trigger.length()
	if distance < 0.0001:  # Positions are too close
		return true
		
	dir_to_trigger = dir_to_trigger / distance  # Normalize
	
	# Calculate angle between camera forward and direction to trigger
	var camera_forward = -camera.global_transform.basis.z.normalized()
	var dot = dir_to_trigger.dot(camera_forward)
	var angle_rad = acos(clamp(dot, -1.0, 1.0))
	var angle_deg = rad_to_deg(angle_rad)
	
	# Check if within field of view
	if angle_deg > degrees_seen / 2.0:
		return false
	return true

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	is_visible = get_visibility()
