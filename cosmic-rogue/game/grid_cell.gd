class_name GridCell extends RefCounted

var terrain_type: Enums.TERRAIN_TYPE
var actor: Actor

func _init(
	_terrain_type: Enums.TERRAIN_TYPE = Enums.TERRAIN_TYPE.FLOOR,
	_actor: Actor = null
) -> void:
	terrain_type = _terrain_type
	actor = _actor
	
func is_passable() -> bool:
	return terrain_type == Enums.TERRAIN_TYPE.FLOOR and actor == null
