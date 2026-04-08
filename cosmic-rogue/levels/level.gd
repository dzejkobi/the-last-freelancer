class_name Level extends Node

const TERRAIN_CHAR_MAP = {
	" ": Enums.TERRAIN_TYPE.FLOOR,
	"x": Enums.TERRAIN_TYPE.WALL,
	"o": Enums.TERRAIN_TYPE.ROCKS
}

const ACTOR_CHAR_MAP: Dictionary = {
	"": {
		"type": Enums.ACTOR_TYPE.UNKNOWN,
		"scene": null
	},
	" ": {
		"type": Enums.ACTOR_TYPE.NONE,
		"scene": null
	},
	"p": { 
		"type": Enums.ACTOR_TYPE.PLAYER,
		"scene": preload("res://actors/player.tscn")
	},
	"m": {
		"type": Enums.ACTOR_TYPE.MANIPULANT,
		"scene": null
	},
	"r": {
		"type": Enums.ACTOR_TYPE.RECRUITER,
		"scene": null
	}
}

@export_file var level_def_file: String

var level_def: String


func read_cell_from_str(cell_str: String) -> Array:
	if len(cell_str) == 1:
		cell_str += ' '
	assert(
		len(cell_str) == 2,
		"Parameter cell_str should be a String of length 2."
	)
	var terrain_type: Enums.TERRAIN_TYPE = TERRAIN_CHAR_MAP.get(
		cell_str[0], Enums.TERRAIN_TYPE.UNKNOWN
	)
	var actor_def: Dictionary = ACTOR_CHAR_MAP.get(
		cell_str[1], ACTOR_CHAR_MAP[""]
	)
	assert(terrain_type, "Unknown terrain type.")
	assert(actor_def["type"], "Unknown actor type.")
	return [terrain_type, actor_def]
	

func setup_board(board: Board):
	var grid: Grid = board.grid
	var row_len: int
	var pos: Vector2i
	var actor: Actor = null
	var cell_def: Array
	
	level_def = FileAccess.get_file_as_string(level_def_file).strip_edges()
	grid.size = Vector2i.ZERO
	
	pos = Vector2.ZERO
	for row: String in level_def.split("\n"):
		pos.x = 0
		for index in range(0, len(row), 2):
			cell_def = read_cell_from_str(row.substr(index, 2))
			if cell_def[1]["scene"]:
				actor = cell_def[1]["scene"].instantiate()
				actor.position = pos * Consts.TILE_SIZE
				board.add_child(actor)
			grid.cells[pos] = GridCell.new(cell_def[0], actor)
			pos.x += 1
		pos.y += 1
		
	grid.size = pos
