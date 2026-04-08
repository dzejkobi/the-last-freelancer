class_name Grid extends Node


var size: Vector2i = Vector2i.ZERO
var cells: Dictionary[Vector2i, GridCell] = {}


func cleanup() -> void:
	for pos: Vector2i in cells:
		cells.erase(pos)
	size = Vector2i.ZERO
