class_name shield extends Collectable


func should_create() -> bool:
	return not Globals.board.get_difficulty_settings()\
		.get("no_extra_shields", false)
	

func collect_by(actor: Actor) -> void:
	super.collect_by(actor)
	actor.shield_count += 1
	
