extends AudioStreamPlayer3D

@onready var player: Player = $".."
var footstep_sounds = {
	"concrete": [
		preload("res://sounds/walking/walking_concrete_1.wav")
	],
	"wood": [
		preload("res://sounds/walking/walking_wood_1.wav"),
	],
	"metal": [
		preload("res://sounds/walking/walking_metal_1.wav"),
	],
	"fabric": [
		preload("res://sounds/walking/walking_fabric_1.wav")
	]
}

var is_moving := false
var pitch_timer := Timer.new()

func _ready() -> void:
	connect("finished", Callable(self, "_on_footstep_finished"))
	pitch_timer.wait_time = 0.25
	pitch_timer.one_shot = false
	pitch_timer.connect("timeout", Callable(self, "_on_pitch_timer_timeout"))
	add_child(pitch_timer)

func _process(_delta: float) -> void:
	var moving = player.is_on_floor() and player.get_wishdir().length() > 0

	if moving and not is_moving:
		is_moving = true
		if not is_playing():
			_play_next_footstep()
	elif not moving and is_moving:
		is_moving = false
		if is_playing():
			stop()
			pitch_timer.stop()

func _on_pitch_timer_timeout() -> void:
	pitch_scale = randf_range(0.75, 1.35)

func _play_next_footstep() -> void:
	var ground_type = _get_ground_type()
	var sounds = footstep_sounds.get(ground_type)
	
	if not sounds.is_empty():
		stream = sounds[randi() % sounds.size()]
		pitch_scale = randf_range(0.35, 1.35)
		play()
		pitch_timer.start()

func _on_footstep_finished() -> void:
	if is_moving:
		_play_next_footstep()
	else:
		pitch_timer.stop()

func _get_ground_type() -> String:
	var from_pos = player.global_transform.origin
	var to_pos = from_pos - Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from_pos
	query.to = to_pos
	query.exclude = []
	query.collision_mask = 1
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider and collider.has_meta("ground_type"):
			return collider.get_meta("ground_type")
	return "concrete"
