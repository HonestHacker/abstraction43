extends Node
class_name Action

@onready var player: Player = $"../../../.."

var icon : Texture2D

func do() -> bool:
	return true
