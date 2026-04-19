class_name RandomMovementAI extends BaseAI


func get_valid_moves() -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	var grid_pos: Vector2i = actor.grid_pos
	var cell: GridCell
	
	for try_pos: Vector2i in [
		grid_pos + Vector2i.UP,
		grid_pos + Vector2i.RIGHT,
		grid_pos + Vector2i.DOWN,
		grid_pos + Vector2i.LEFT,
	]:
		cell = Globals.grid.cells.get(try_pos)
		if cell and cell.is_passable():
			moves.append(try_pos)

	return moves
	
	
func move_randomly() -> void:
	var moves: Array[Vector2i] = get_valid_moves()
	if len(moves):
		actor.move_to_cell(moves.pick_random())
	else:
		actor.delayed_try_to_shoot()
	
	
func move() -> void:
	move_randomly()
