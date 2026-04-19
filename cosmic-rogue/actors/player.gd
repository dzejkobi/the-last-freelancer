class_name Player extends Actor


func move_to_cell(to_grid_pos: Vector2i) -> void:
	Sounds.footstep.play({"global_position": global_position})
	super.move_to_cell(to_grid_pos)
	Globals.board.player_movement_started.emit(self)


func wait() -> void:
	super.wait()
	Globals.board.player_movement_started.emit(self)


func die(killer: Actor = null) -> void:
	super.die(killer)
	Globals.board.game_over(killer)
	
	
func _movement_finished_callback(waited: bool = false) -> void:
	super._movement_finished_callback(waited)
	await Globals.board.until_no_movement()
	Globals.board.player_movement_finished.emit(self)
