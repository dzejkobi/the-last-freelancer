class_name Headhunter extends Actor

const crosshair_scene = preload("res://entities/crosshair.tscn")

var crosshair: Crosshair = null


func try_to_shoot() -> void:
	if not Globals.board.player:
		return
	if crosshair:
		if Globals.board.player.grid_pos == crosshair.grid_pos:
			shoot(Globals.board.player)
			crosshair.disappear()
			crosshair = null
		else:
			crosshair.move_to(Globals.board.player.get_predicted_grid_pos())
	else:
		crosshair = crosshair_scene.instantiate()
		Globals.board.entity_layer.add_child(crosshair)
		crosshair.appear_at(grid_pos)
		crosshair.move_to(
			Globals.board.player.get_predicted_grid_pos()
		)
		

func die(killer: Actor = null) -> void:
	super.die(killer)


func _on_tree_exiting() -> void:
	if crosshair:
		crosshair.disappear()
