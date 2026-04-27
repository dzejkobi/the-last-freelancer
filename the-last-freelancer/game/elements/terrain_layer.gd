class_name TerrainLayer extends TileMapLayer


var terrain_defs: Dictionary[Enums.TERRAIN_TYPE, Dictionary] = {
	Enums.TERRAIN_TYPE.FLOOR: {
		"coords": [],
		"terrain_id": 0
	},
	Enums.TERRAIN_TYPE.WALL: {
		"coords": [],
		"terrain_id": 1
	},
	Enums.TERRAIN_TYPE.PYRAMID: {
		"coords": [],
		"terrain_id": 2
	},
	Enums.TERRAIN_TYPE.ROCKS: {
		"coords": [],
		"terrain_id": 3
	},
	Enums.TERRAIN_TYPE.SERVER: {
		"coords": [],
		"terrain_id": 4
	},
	Enums.TERRAIN_TYPE.EMPTY_JAR: {
		"coords": [],
		"terrain_id": 5
	},
	Enums.TERRAIN_TYPE.FILLED_JAR: {
		"coords": [],
		"terrain_id": 6
	}
}


func update_tilemaps(grid: Grid) -> void:
	var pos: Vector2i
	
	for tt: Enums.TERRAIN_TYPE in terrain_defs:
		terrain_defs[tt]["coords"].clear()

	for y: int in range(grid.size.y):
		for x: int in range(grid.size.x):
			pos = Vector2i(x, y)
			terrain_defs[grid.cells[pos].terrain_type]["coords"].append(pos)
	
	for tt: Enums.TERRAIN_TYPE in terrain_defs:
		set_cells_terrain_connect(
			terrain_defs[tt]["coords"], 0, terrain_defs[tt]["terrain_id"]
		)
