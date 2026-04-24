class_name Cubicle extends Actor


@export var spawn_intervel: int = 3  # int turns
@export var enemy_limit: int = 6
@export var limit_range: int = 3
@export var scene_to_spawn: PackedScene

var turns_to_spawn: int


func _ready() -> void:
	turns_to_spawn = spawn_intervel


func get_targets_in_limit_range() -> Array[Actor]:
	var targets: Array[Actor] = Globals.board.enemies
	targets = Grid.find_actors_in_range(grid_pos, limit_range, targets)
	targets.erase(self)
	return targets


func get_spawn_grid_pos_when_applicable() -> Vector2i:
	if (
		turns_to_spawn == 0 and
		get_targets_in_limit_range().size() < enemy_limit
	):
		var valid_moves: Array[Vector2i] = get_valid_moves()
		if valid_moves.size():
			return valid_moves.pick_random()
	return Vector2i.ZERO
	
	
func spawn(at_grid_pos: Vector2i) -> void:
	var child: Actor = scene_to_spawn.instantiate()
	child.setup(at_grid_pos)
	child.score = 1
	Globals.board.actor_layer.add_child(child)
	Globals.board.enemies.append(child)
	child.play_spawn_animation(grid_pos)
	

func interact_with_cell() -> void:
	if turns_to_spawn > 0:
		turns_to_spawn -= 1
	var spawn_grid_pos: Vector2i = get_spawn_grid_pos_when_applicable()
	if spawn_grid_pos != Vector2i.ZERO:
		spawn(spawn_grid_pos)
		turns_to_spawn = spawn_intervel
