class_name TankRangeVisualizer extends RangeVisualizer


func get_cells_in_range() -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	
	for x in range(0, Globals.grid.size.x):
		coords.append(Vector2i(x, actor.grid_pos.y))
	for y in range(0, Globals.grid.size.y):
		if y != actor.grid_pos.y:
			coords.append(Vector2i(actor.grid_pos.x, y))
	return coords
