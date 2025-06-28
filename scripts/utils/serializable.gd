@icon("res://textures/ui/toolkit/saveload_system_icon.svg")
extends Node
class_name Serializable

@export var properties: Dictionary[NodePath, PackedStringArray]

func _ready() -> void:
	name = get_parent().name + "Serializable"
	add_to_group("serializables")

func save() -> Dictionary:
	var data: Dictionary[String, Dictionary] = {}
	for object in properties:
		var object_properties := properties[object]
		var object_data := {}
		for property in object_properties:
			object_data[property] = var_to_str(
				get_node(object).get_indexed(property)
			)
		data[str(object)] = object_data
	return data

func restore(data: Dictionary) -> void:
	for object_path in data:
		var object = get_node(object_path)
		var object_data = data[object_path]
		for property in object_data:
			object.set_indexed(property, str_to_var(object_data[property]))
