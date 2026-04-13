class_name Actor extends Node2D

const projectile_scene = preload("res://projectiles/projectile.tscn")

@export var movement_time: float = 0.5
@export var attack_range: int = 3
@export var is_enemy: bool = true
@export var score: int = 5
@export var color_name: String
@export var projectile_type: Enums.PROJECTILE_TYPE

var is_moving: bool = false
var grid_pos: Vector2i

@onready var anim_sprite: AnimatedSprite2D = $AnimSprite


func setup(_grid_pos: Vector2i) -> void:
	grid_pos = _grid_pos
	position = Grid.grid_pos_to_pos(grid_pos)


func _ready() -> void:
	if color_name:
		var color: Color = Colors.get(color_name)
		if color:
			anim_sprite.modulate = color


func is_movement_valid(to_grid_pos: Vector2i) -> bool:
	var target_cell: GridCell = Globals.grid.cells.get(to_grid_pos)
	return target_cell and target_cell.is_passable()


func _movement_finished_callback() -> void:
	anim_sprite.play("idle")
	position = Grid.grid_pos_to_pos(grid_pos)
	is_moving = false


func move_to_cell(to_grid_pos: Vector2i) -> void:
	var target_pos: Vector2 = Grid.grid_pos_to_pos(to_grid_pos)
	var tween: Tween = create_tween()
	
	assert(not is_moving, "Can't move already moving actor.")
	assert(
		is_movement_valid(to_grid_pos),
		"Invalid movement to %s." % to_grid_pos
	)
	
	is_moving = true

	# final position has to be set immidiately
	Globals.grid.cells[grid_pos].actor = null
	Globals.grid.cells[to_grid_pos].actor = self
	grid_pos = to_grid_pos

	anim_sprite.play("walking")
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		self, "position", target_pos, movement_time
	)
	tween.tween_callback(_movement_finished_callback)
	
	var timer: SceneTreeTimer = get_tree().create_timer(0.1 * movement_time)
	timer.timeout.connect(func ():
		# we need to wait until all actors updates their grid positions
		try_to_shoot()
	)


func find_enemies_in_range() -> Array[Actor]:
	var targets: Array[Actor]
	if self is Player:
		targets = Globals.board.enemies
	elif is_enemy:
		targets = [Globals.board.player]
	return Grid.find_actors_in_range(grid_pos, attack_range, targets)
	
	
func shoot(target: Actor) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	Sounds.laser.play({"global_position": global_position})
	projectile.position = position
	projectile.kind = projectile_type
	Globals.board.actor_layer.add_child(projectile)
	projectile.move_to(target.grid_pos)


func try_to_shoot() -> void:
	var targets = find_enemies_in_range()
	if len(targets):
		targets.sort_custom(func (a: Actor, b: Actor):
			return (
				a.grid_pos.distance_to(grid_pos) <
				b.grid_pos.distance_to(grid_pos)
			)

		)
		shoot(targets[0])


func die() -> void:
	Globals.grid.cells.get(grid_pos).actor = null
	if self is Player:
		Globals.board.player = null
	elif is_enemy:
		Globals.board.score += score
		Globals.board.enemies.erase(self)
		Sounds.enemy_dies.play({"global_position": global_position})
		Globals.board.check_level_completion()
	queue_free()


func hit_by_projectile(_projectile: Projectile) -> void:
	die()
