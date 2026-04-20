class_name GridCell extends RefCounted

var terrain_type: Enums.TERRAIN_TYPE
var actor: Actor
var entity: Entity

func _init(
	_terrain_type: Enums.TERRAIN_TYPE = Enums.TERRAIN_TYPE.FLOOR,
	_actor: Actor = null,
	_entity: Entity = null
) -> void:
	terrain_type = _terrain_type
	actor = _actor
	entity = _entity
	
func is_passable() -> bool:
	return terrain_type == Enums.TERRAIN_TYPE.FLOOR and actor == null
