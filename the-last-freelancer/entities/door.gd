class_name door extends Entity

enum STATE {
	UNKNOWN = 0,
	OPENING = 1,
	OPEN = 2,
	CLOSING = 3,
	CLOSED = 4
}

const ANIM_NAME_MAP := {
	STATE.OPENING: "opening",
	STATE.OPEN: "open",
	STATE.CLOSING: "closing",
	STATE.CLOSED: "closed"
}

@export var state: STATE = STATE.OPEN

var orientation: Enums.ORIENTATION



func get_curr_anim_name() -> String:
	var suffix: String = "h" if orientation == Enums.ORIENTATION.HORIZONTAL \
		else "v"
	return "%s_%s" % [ANIM_NAME_MAP[state], suffix]


func is_passable() -> bool:
	return state == STATE.OPEN


func set_orientation(_orientation: Enums.ORIENTATION) -> void:
	orientation = _orientation
	anim_sprite.play(get_curr_anim_name())
	

func close() -> void:
	state = STATE.CLOSING
	anim_sprite.play(get_curr_anim_name())
	
	
func open() -> void:
	state = STATE.OPENING
	anim_sprite.play(get_curr_anim_name())


func at_level_start() -> void:
	var left_cell: GridCell = Globals.grid.cells.get(grid_pos - Vector2i.LEFT)
	if left_cell and left_cell.terrain_type == Enums.TERRAIN_TYPE.WALL:
		set_orientation(Enums.ORIENTATION.HORIZONTAL)
	else:
		set_orientation(Enums.ORIENTATION.VERTICAL)
	close()


func _on_anim_sprite_animation_finished() -> void:
	if state == STATE.CLOSING:
		state = STATE.CLOSED
		anim_sprite.play(get_curr_anim_name())
	elif state == STATE.OPENING:
		state = STATE.OPEN
		anim_sprite.play(get_curr_anim_name())
