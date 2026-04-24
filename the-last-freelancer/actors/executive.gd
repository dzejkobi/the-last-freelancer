class_name Executive extends Actor

@export var influence_range: int = 7
@export var int_boost: float = 0.5


func at_level_start(_data: Dictionary = {}) -> void:
	emanate_aura()


func find_actors_in_infl_range() -> Array[Actor]:
	var targets: Array[Actor] = Globals.board.enemies
	return Grid.find_actors_in_range(grid_pos, influence_range, targets)
	
	
func emanate_aura() -> void:
	for ally: Actor in find_actors_in_infl_range():
		if ally != self:
			ally.status_man.set_status(
				Enums.ACTOR_STATUS.INT_BOOSTED, 1, {"int_boost": int_boost}
			)


func try_to_shoot() -> void:
	emanate_aura()
