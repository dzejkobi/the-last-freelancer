class_name Grid extends Node


var size: Vector2i = Vector2i.ZERO
var cells: Dictionary[Vector2i, GridCell] = {}


# helper functions

static func pos_to_grid_pos(pos: Vector2) -> Vector2i:
	return Vector2i(
		round(pos.x / float(Consts.TILE_SIZE.x)),
		round(pos.y / float(Consts.TILE_SIZE.y))
	)


static func grid_pos_to_pos(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * Consts.TILE_SIZE.x,
		grid_pos.y * Consts.TILE_SIZE.y
	)


static func find_actors_in_range(
	center: Vector2i, _range: int, actors: Array[Actor]
) -> Array[Actor]:
	var result: Array[Actor] = []
	var r := float(_range)
	var r2 := r * r

	for actor: Actor in actors:
		var dx := actor.grid_pos.x - center.x
		var dy := actor.grid_pos.y - center.y
		
		if dx * dx + dy * dy <= r2 + r:
			result.append(actor)
	
	return result


func get_cells_in_range(center: Vector2i, _range: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var r := float(_range)
	var r2 := r * r

	var y1: int = clampi(center.y - _range, 0, size.y - 1)
	var y2: int = clampi(center.y + _range, 0, size.y - 1)
	var x1: int = clampi(center.x - _range, 0, size.x - 1)
	var x2: int = clampi(center.x + _range, 0, size.x - 1)

	for y in range(y1, y2 + 1):
		for x in range(x1, x2 + 1):
			var dx := x - center.x
			var dy := y - center.y
			
			# edge smoothing
			if dx * dx + dy * dy <= r2 + r:
				result.append(Vector2i(x, y))
	
	return result

# ------


func cleanup() -> void:
	for grid_pos: Vector2i in cells:
		cells.erase(grid_pos)
	size = Vector2i.ZERO
