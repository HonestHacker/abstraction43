extends Area3D

@export var target_scene_path: String = "scenes/maps/abstractmap.tscn"

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Player and name == "change_scene_door" and target_scene_path != "":
		get_tree().change_scene_to_file(target_scene_path)
