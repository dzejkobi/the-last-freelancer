class_name shield extends Collectable


func collect_by(actor: Actor) -> void:
	super.collect_by(actor)
	actor.shield_count += 1
	
