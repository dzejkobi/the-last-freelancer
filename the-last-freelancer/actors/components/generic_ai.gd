class_name GenericAI extends BaseAI

@export var base_int: float = 0
@export var max_int: float = 1
@export var activity_level: float = 1
@export var attitude: Enums.ATTITUDE = Enums.ATTITUDE.AGGRESSIVE

@export var further_axis_first: bool = true
# If set to false then move_towards_player function will prefer movement
# over proximal axis over further exis.
# This is useful for tanks to get the player in their line of fire sooner.
# This doesn't affect move_away_from_player function.

var int_mod: float = 0

var curr_int: float:
	get():
		return clamp(base_int + int_mod, 0, max_int)


func move_or_wait(to_grid_pos: Vector2i) -> void:
	if to_grid_pos == Vector2i.ZERO:
		actor.delayed_try_to_shoot()
		actor.delayed_interact_with_cell()
	else:
		actor.move_to_cell(to_grid_pos)

	
func move_randomly(valid_moves: Array[Vector2i]) -> void:
	var move_to: Vector2i = Vector2i.ZERO
	if len(valid_moves):
		move_to = valid_moves.pick_random()
	move_or_wait(move_to)


func _find_move_towards_or_away(
	valid_moves: Array[Vector2i],
	direction_sign: int,
	_further_axis_first: bool = true
) -> Vector2i:
	var pos: Vector2i = actor.grid_pos
	var target: Vector2i = Globals.board.player.grid_pos
	var delta: Vector2i = target - pos
	
	var x_dir: int = sign(delta.x)
	var y_dir: int = sign(delta.y)
	
	var primary_first: bool = abs(delta.x) >= abs(delta.y)\
		if _further_axis_first \
		else abs(delta.x) < abs(delta.y)
	
	var primary_move: Vector2i
	var secondary_move: Vector2i
	
	if primary_first:
		primary_move = pos + Vector2i(x_dir * direction_sign, 0)
		secondary_move = pos + Vector2i(0, y_dir * direction_sign)
	else:
		primary_move = pos + Vector2i(0, y_dir * direction_sign)
		secondary_move = pos + Vector2i(x_dir * direction_sign, 0)
	
	if primary_move in valid_moves:
		return primary_move
	elif secondary_move in valid_moves:
		return secondary_move
	else:
		return Vector2i.ZERO


func move_towards_player(valid_moves: Array[Vector2i]):
	move_or_wait(
		_find_move_towards_or_away(valid_moves, 1, further_axis_first)
	)


func move_away_from_player(valid_moves: Array[Vector2i]):
	move_or_wait(
		_find_move_towards_or_away(valid_moves, -1)
	)


func move_aggresively(valid_moves: Array[Vector2i]) -> void:
	move_towards_player(valid_moves)


func move_cautiously(valid_moves: Array[Vector2i]) -> void:
	var player: Player = Globals.board.player
	var distance: float = \
		Vector2(actor.grid_pos).distance_to(player.grid_pos)
	if distance > player.attack_range + 2:
		move_towards_player(valid_moves)
	else:
		move_away_from_player(valid_moves)
	
	
func move_fearfully(valid_moves: Array[Vector2i]) -> void:
	move_away_from_player(valid_moves)
	

func move_intelligently(valid_moves: Array[Vector2i]) -> void:
	match attitude:
		Enums.ATTITUDE.CHAOTIC:
			move_randomly(valid_moves)
		Enums.ATTITUDE.AGGRESSIVE:
			move_aggresively(valid_moves)
		Enums.ATTITUDE.CAUTIOUS:
			move_cautiously(valid_moves)
		Enums.ATTITUDE.FEARFUL:
			move_fearfully(valid_moves)
	
	
func move() -> void:
	var activity_roll: float = randf()
	var int_roll: float = randf()
	var valid_moves: Array[Vector2i] = actor.get_valid_moves()
	
	if activity_roll > activity_level:
		actor.wait()
		return
	
	if int_roll <= curr_int:
		move_intelligently(valid_moves)
	else:
		move_randomly(valid_moves)
