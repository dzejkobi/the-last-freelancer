class_name Headhunter extends Actor

const crosshair_scene = preload("res://entities/crosshair.tscn")

var crosshair: Crosshair = null
var show_crosshair: bool


func _ready() -> void:
	super._ready()
	show_crosshair = not Globals.board.get_difficulty_settings()\
		.get("no_range_markers", false)


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
		crosshair.visible = show_crosshair
		Globals.board.entity_layer.add_child(crosshair)
		crosshair.appear_at(grid_pos, show_crosshair)
		crosshair.move_to(
			Globals.board.player.get_predicted_grid_pos()
		)
		

func die(_killer: Actor = null) -> void:
	if crosshair:
		crosshair.disappear()
	super.die(_killer)
	
	
func _exit_tree() -> void:
	if crosshair and is_instance_valid(crosshair):
		crosshair.queue_free()
