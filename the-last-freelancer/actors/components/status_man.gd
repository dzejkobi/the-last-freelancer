class_name StatusMan extends HBoxContainer

@onready var actor: Actor = get_parent()
@onready var statuses: Dictionary[Enums.ACTOR_STATUS, Dictionary] = {
	Enums.ACTOR_STATUS.INT_BOOSTED: {
		"is_active": false,
		"turns_to_expire": -1,
		"int_boost": 0.0,
		"icon_node": $IntBoost
	}
}


func set_status(
	status: Enums.ACTOR_STATUS,
	turns_to_expire: int = -1,
	data: Dictionary = {}
) -> void:
	statuses[status]["is_active"] = true
	if statuses[status]["turns_to_expire"] < turns_to_expire:
		statuses[status]["turns_to_expire"] = turns_to_expire
	
	# Running status-specific logic
	match status:
		Enums.ACTOR_STATUS.INT_BOOSTED:
			if (
				data["int_boost"] >
				statuses[status]["int_boost"]
			):
				statuses[status]["int_boost"] = \
					data["int_boost"]
				if actor.ai and "int_mod" in actor.ai:
					actor.ai.int_mod = data["int_boost"]
		_:
			push_error('Unsupported ACTOR_STATUS "%s".' % status)
		
		
func unset_status(status: Enums.ACTOR_STATUS) -> void:
		if statuses[status]["is_active"]:
			statuses[status]["is_active"] = false
			
		# Running status-specific logic
		match status:
			Enums.ACTOR_STATUS.INT_BOOSTED:
				if actor.ai and "int_mod" in actor.ai:
					actor.ai.int_mod = 0.0


func update_icons() -> void:
	for status in statuses:
		statuses[status].icon_node.visible = statuses[status]["is_active"]


# Should be manually called after all actions are finished on each turn
func update() -> void:
	var is_active: bool
	var turns_to_expire: int
	
	for status in statuses:
		is_active = statuses[status]["is_active"]
		turns_to_expire = statuses[status]["turns_to_expire"]
		if is_active:
			if turns_to_expire == 0:
				unset_status(status)
			else:
				statuses[status]["turns_to_expire"] -= 1
				
	update_icons()
	
