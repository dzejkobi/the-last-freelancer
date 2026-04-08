class_name TerrainLayer extends TileMapLayer


class TerrainDef extends RefCounted:
	var name: String
	var terrain_type: Enums.TERRAIN_TYPE
	var coords: Array[Vector2i] = []
	var terrain_set_id: int = 0
	var terrain_id: int

	func _init(
		_name: String,
		_terrain_type: Enums.TERRAIN_TYPE,
		_terrain_id: int
	) -> void:
		name = _name
		terrain_type = _terrain_type
		terrain_id = _terrain_id
		
		
var terrain_defs: Array[TerrainDef] = [
	TerrainDef.new("floor", Enums.TERRAIN_TYPE.FLOOR, 0),
	TerrainDef.new("wall", Enums.TERRAIN_TYPE.WALL, 1),
	TerrainDef.new("rocks", Enums.TERRAIN_TYPE.ROCKS, 2)
]


func _find_terrain_def_index(terrain_type: Enums.TERRAIN_TYPE) -> int:
	for i in range(len(terrain_defs) - 1):
		if terrain_defs[i].terrain_type == terrain_type:
			return i
	push_error(
		"Terrain type %s not found in terrain_defs." % terrain_type
	)
	return -1


func update_tilemaps(grid: Grid) -> void:
	var pos: Vector2i
	var terr_def_i: int
	
	for terrain: TerrainDef in terrain_defs:
		terrain.coords.clear()

	for y: int in range(grid.size.y):
		for x: int in range(grid.size.x):
			pos = Vector2i(x, y)
			terr_def_i = _find_terrain_def_index(grid.cells[pos].terrain_type)
			terrain_defs[terr_def_i].coords.append(pos)
	
	for terrain_def: TerrainDef in terrain_defs:
		set_cells_terrain_connect(
			terrain_def.coords, 
			terrain_def.terrain_set_id,
			terrain_def.terrain_id
		)
