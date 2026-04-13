class_name Player extends Actor


func move_to_cell(to_grid_pos: Vector2i) -> void:
	Sounds.footstep.play({"global_position": global_position})
	super.move_to_cell(to_grid_pos)
	Globals.board.player_movement_started.emit(self)


func die() -> void:
	super.die()
	Globals.board.game_over()
	
	
func _movement_finished_callback() -> void:
	super._movement_finished_callback()
	await Globals.board.until_no_projectiles()
	Globals.board.player_movement_finished.emit(self)
