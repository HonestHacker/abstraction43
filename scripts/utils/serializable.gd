@icon("res://textures/ui/toolkit/saveload_system_icon.svg")
extends Node
class_name Serializable
## Serializable node that manages saving/restoring state for tracked properties
##
## Attach to any node to make its properties persistent. Tracks specified properties
## across child nodes and provides serialization/deserialization functionality.

## Dictionary of tracked properties per node path.[br]
## Key: [NodePath] to target node.[br]
## Value: [PackedStringArray] of property names to track.[br]
@export var properties: Dictionary[NodePath, PackedStringArray]

func _ready() -> void:
	name = get_parent().name + "Serializable"
	add_to_group("serializables")

## Adds properties from a node to be tracked for serialization[br]
##
## [param object]: Node whose properties should be tracked[br]
## [param property_list]: List of property names (as strings) to track.
func add_object_properties(object: Node, property_list: PackedStringArray):
	var node_path := get_path_to(object)
	properties[node_path] = property_list

## Serializes tracked properties into a save dictionary.[br]
##
## Structure:[br]
## [codeblock]
## {
##     ^"NodePath": {
##         "property": "stringified_value",
##         ...
##     },
##     ...
## }
## [/codeblock]
## Returns dictionary containing all tracked property values.
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

## Restores property states from serialized data.[br]
##
## [param data]: Dictionary created by [method save] method containing property states.
func restore(data: Dictionary) -> void:
	for object_path in data:
		var object = get_node(object_path)
		var object_data = data[object_path]
		for property in object_data:
			object.set_indexed(property, str_to_var(object_data[property]))
