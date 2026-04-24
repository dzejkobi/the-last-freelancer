class_name LevelMan extends Node

# TODO: Bonus points to collect in each level, dropping down after each move

const TERRAIN_CHAR_MAP = {
	" ": Enums.TERRAIN_TYPE.FLOOR,
	"x": Enums.TERRAIN_TYPE.WALL,
	"o": Enums.TERRAIN_TYPE.ROCKS
}

const ACTOR_CHAR_MAP: Dictionary = {
	" ": {
		"type": Enums.ACTOR_TYPE.NONE,
		"scene": null
	},
	"p": { 
		"type": Enums.ACTOR_TYPE.PLAYER,
		"scene": preload("res://actors/player.tscn")
	},
	"m": {
		"type": Enums.ACTOR_TYPE.DRONE,
		"scene": preload("res://actors/drone.tscn")
	},
	"r": {
		"type": Enums.ACTOR_TYPE.RECRUITER,
		"scene": preload("res://actors/recruiter.tscn")
	},
	"h": {
		"type": Enums.ACTOR_TYPE.HEADHUNTER,
		"scene": preload("res://actors/headhunter.tscn")
	},
	"t": {
		"type": Enums.ACTOR_TYPE.TANK,
		"scene": preload("res://actors/tank.tscn")
	},
	"e": {
		"type": Enums.ACTOR_TYPE.EXECUTIVE,
		"scene": preload("res://actors/executive.tscn")
	}
}

const ENTITY_CHAR_MAP: Dictionary = {
	" ": {
		"type": Enums.ENTITY_TYPE.NONE,
		"scene": null
	},
	"@": {
		"type": Enums.ENTITY_TYPE.SHIELD,
		"scene": preload("res://entities/shield.tscn")
	}
}

const EMPTY_CELL = [
	TERRAIN_CHAR_MAP[" "], ACTOR_CHAR_MAP[" "], ENTITY_CHAR_MAP[" "]
]

@export var level_names: Array[String] = ["level1"]
@export var first_loop: int = 1
@export var last_loop: int = 3
@export var first_level_index: int = 0

var curr_loop: int = 1
var curr_level_index: int = 0

var curr_level: int:
	get():
		return curr_level_index + 1

var curr_progress: String:
	get():
		return "%s / %s" % [curr_loop, curr_level]


func read_cell_from_str(_cell_str: String) -> Array:
	var cell_str: String = _cell_str
	var apply_at_loop: int

	if len(cell_str) == 1:
		cell_str += '1'
	assert(
		len(cell_str) == 2,
		'Parameter _cell_str "%s" should be a String of length 2.' % _cell_str
	)
	if cell_str[1] == ' ':
		cell_str[1] = '1'
	assert(
		cell_str[0] in TERRAIN_CHAR_MAP or
		cell_str[0] in ACTOR_CHAR_MAP or 
		cell_str[0] in ENTITY_CHAR_MAP,
		'Unknown _cell_str definition "%s".' % _cell_str
	)
	if not cell_str[1].is_valid_int():
		push_error('Invalid loop number in _cell_str "%s".' % _cell_str)
		return EMPTY_CELL
	
	apply_at_loop = int(cell_str[1])
	if curr_loop < apply_at_loop:
		return EMPTY_CELL
		
	var terrain_type: Enums.TERRAIN_TYPE = TERRAIN_CHAR_MAP.get(
		cell_str[0], Enums.TERRAIN_TYPE.FLOOR
	)
	var actor_def: Dictionary = ACTOR_CHAR_MAP.get(
		cell_str[0], ACTOR_CHAR_MAP[" "]
	)
	var entity_def: Dictionary = ENTITY_CHAR_MAP.get(
		cell_str[0], ENTITY_CHAR_MAP[" "]
	)
	return [terrain_type, actor_def, entity_def]
	

func setup_board(board: Board):
	var grid: Grid = board.grid
	var grid_pos: Vector2i
	var actor: Actor = null
	var entity: Entity = null
	var cell_def: Array
	var level_def: String
	var difficulty_settings: Dictionary = \
		board.DIFFICULTY_MAP.get(board.difficulty)
	
	level_def = FileAccess.get_file_as_string(
		"res://levels/%s.txt" % level_names[curr_level_index]
	).strip_edges()
	grid.size = Vector2i.ZERO
	
	grid_pos = Vector2.ZERO
	for row: String in level_def.split("\n"):
		grid_pos.x = 0
		for index in range(0, len(row), 2):
			cell_def = read_cell_from_str(row.substr(index, 2))
			if cell_def[1]["scene"]:
				# Actor
				actor = cell_def[1]["scene"].instantiate()
				actor.setup(grid_pos)
				board.actor_layer.add_child(actor)
				if (
					difficulty_settings.get("no_range_markers", false) and
					actor.range_visualizer
				):
					actor.range_visualizer.is_active = false
				if actor is Player:
					board.player = actor
				elif actor.is_enemy:
					board.enemies.append(actor)
			else:
				actor = null
			
			if cell_def[2]["scene"]:
				if (
					cell_def[2]["type"] != Enums.ENTITY_TYPE.SHIELD or
					not difficulty_settings.get("no_extra_shields", false)
				):
					# Entity
					entity = cell_def[2]["scene"].instantiate()
					entity.setup(grid_pos)
					board.entity_layer.add_child(entity)
			else:
				entity = null
			
			grid.cells[grid_pos] = GridCell.new(cell_def[0], actor, entity)
			grid_pos.x += 1
		grid_pos.y += 1
		
	grid.size = grid_pos
	
	
func set_next_level(level_index: int = -1, loop: int = -1) -> bool:
	if loop > 0:
		curr_loop = loop
	if level_index > -1:
		curr_level_index = level_index
	else:
		curr_level_index += 1
		if curr_level_index >= level_names.size():
			curr_loop += 1
			curr_level_index = 0
		
	curr_loop = clamp(curr_loop, 1, last_loop + 1)
	curr_level_index = clamp(curr_level_index, 0, level_names.size() - 1)
	
	if curr_loop > last_loop:
		Globals.board.victory()
		return false
	else:
		%LevelLabel.text = "Level: %s" % curr_progress
		return true
