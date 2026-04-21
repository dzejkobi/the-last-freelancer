class_name Actor extends Node2D

const splash_scene := preload("res://entities/splash.tscn")
const projectile_scene = preload("res://entities/projectile.tscn")
const shield_absorb_scene = preload("res://entities/shield_absorb.tscn")

@export var verbose_name: String = "Actor"
@export var movement_time: float = 0.5
@export var attack_range: int = 3
@export var shield_count: int = 0:
	set(value):
		if shield_count != value:
			shield_count = value
			shield_count_changed.emit(value)
			
@export var is_enemy: bool = true
@export var score: int = 5
@export var color_name: String
@export var projectile_type: Enums.PROJECTILE_TYPE
@export var shoot_delay: float = 0.1 * movement_time
@export_multiline var hint: String

var is_moving: bool = false
var is_dying: bool = false
var grid_pos: Vector2i
var prev_grid_pos: Vector2i
var direction: Vector2i = Vector2i.UP

@onready var anim_sprite: AnimatedSprite2D = $AnimSprite
@onready var range_visualizer: RangeVisualizer = \
	get_node_or_null("RangeVisualizer")

signal created
signal movement_started
signal shield_count_changed(value: int)


func setup(_grid_pos: Vector2i) -> void:
	grid_pos = _grid_pos
	prev_grid_pos = _grid_pos
	position = Grid.grid_pos_to_pos(grid_pos)
	created.emit()


func _ready() -> void:
	if color_name:
		var color: Color = Colors.get(color_name)
		if color:
			anim_sprite.modulate = color


func is_movement_valid(to_grid_pos: Vector2i) -> bool:
	var target_cell: GridCell = Globals.grid.cells.get(to_grid_pos)
	return target_cell and target_cell.is_passable()


func interact_with_cell() -> void:
	var cell: GridCell = Globals.grid.cells[grid_pos]
	if (
		cell.entity and
		cell.entity is Collectable and
		cell.entity.is_collectable_by(self)
	):
		cell.entity.collect_by(self)
	

func _movement_finished_callback(waited: bool = false) -> void:
	anim_sprite.play("idle")
	position = Grid.grid_pos_to_pos(grid_pos)
	is_moving = false
	if not waited:
		Globals.board.movement_man.unregister_actor(self)


func play_movement_animation() -> void:
	anim_sprite.play("walking")


func move_to_cell(to_grid_pos: Vector2i) -> void:
	var target_pos: Vector2 = Grid.grid_pos_to_pos(to_grid_pos)
	var tween: Tween = create_tween()
	
	assert(not is_moving, "Can't move already moving actor.")
	assert(
		is_movement_valid(to_grid_pos),
		"Invalid movement to %s." % to_grid_pos
	)
	assert(not is_dying, "Dying actor can't be ordered to move.")
	
	Globals.board.movement_man.register_actor(self)
	is_moving = true

	# final position has to be set immidiately
	Globals.grid.cells[grid_pos].actor = null
	Globals.grid.cells[to_grid_pos].actor = self
	direction = to_grid_pos - grid_pos
	prev_grid_pos = grid_pos
	grid_pos = to_grid_pos
	movement_started.emit()

	play_movement_animation()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		self, "position", target_pos, movement_time
	)
	tween.tween_callback(_movement_finished_callback)
	
	delayed_try_to_shoot()
	delayed_interact_with_cell()


func wait() -> void:
	prev_grid_pos = grid_pos
	movement_started.emit()
	_movement_finished_callback(true)
	delayed_try_to_shoot()
	delayed_interact_with_cell()


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
	projectile.shooter = self
	Globals.board.entity_layer.add_child(projectile)
	projectile.move_to(target.grid_pos)


func try_to_shoot() -> void:
	# the delay is useful to wait until all actors
	# updates their grid positions
	var targets = find_enemies_in_range()
	if len(targets):
		targets.sort_custom(func (a: Actor, b: Actor):
			return (
				a.grid_pos.distance_to(grid_pos) <
				b.grid_pos.distance_to(grid_pos)
			)

		)
		shoot(targets[0])


func delayed_try_to_shoot() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(shoot_delay)
	timer.timeout.connect(try_to_shoot)


func delayed_interact_with_cell() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(movement_time / 2)
	timer.timeout.connect(interact_with_cell)


func die(_killer: Actor = null) -> void:
	Globals.grid.cells.get(grid_pos).actor = null
	is_dying = true
	if is_enemy:
		if Globals.board.player:
			Globals.board.score += score
		Globals.board.enemies.erase(self)
		Sounds.enemy_dies.play({"global_position": global_position})

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.1)
	tween.tween_callback(func (): 
		Globals.board.movement_man.unregister_actor(self, true)
		Globals.board.check_level_completion()
		queue_free()
	)


func hit_by_projectile(projectile: Projectile) -> void:
	if shield_count <= 0:
		var splash: Splash
		splash = splash_scene.instantiate()
		splash.setup(
			position + floor(0.5 * Consts.TILE_SIZE),
			Colors.get(color_name)
		)
		splash.display()
		die(
			projectile.shooter if is_instance_valid(projectile.shooter)
			else null
		)
	else:
		shield_count -= 1
		var shield_absorb: ShieldAbsorb = shield_absorb_scene.instantiate()
		shield_absorb.setup(position + floor(0.5 * Consts.TILE_SIZE))
		shield_absorb.display()


func get_predicted_grid_pos() -> Vector2i:
	if prev_grid_pos == grid_pos:
		return grid_pos
	else:
		var _direction: Vector2i = grid_pos - prev_grid_pos
		return grid_pos + _direction
	
