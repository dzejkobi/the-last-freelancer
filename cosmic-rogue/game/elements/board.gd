class_name Board extends Node

@export var grid: Grid
@export var level_def: String
@export var is_paused: bool = true

var size: Vector2i = Vector2i.ZERO
var player: Player
var enemies: Array[Actor] = []

var is_set: bool = false
var pending_projectiles: bool = false
var killer_name: String = "Enemy"

var score: int = 0:
	set(value):
		score = value
		%ScoreLabel.text = "Score: %s" % score
	get():
		return score

@onready var terrain_layer: TerrainLayer = $TerrainLayer
@onready var actor_layer: Node2D = $ActorLayer
@onready var entity_layer: Node2D = $EntityLayer
@onready var camera: Camera2D = %Camera
@onready var level_man: LevelMan = %LevelMan
@onready var movement_man: MovementMan = $MovementMan

signal level_loaded
@warning_ignore("unused_signal")
signal player_movement_started(player: Actor)
@warning_ignore("unused_signal")
signal player_movement_finished(player: Actor)


func center_camera() -> void:
	var screen_size: Vector2i = get_viewport().get_visible_rect().size
	camera.position = floor(screen_size / 2.0)
	
	
func _ready() -> void:
	center_camera()
	AudioPlayer.setup(%AudioListener)


func setup() -> void:
	if player:
		player.queue_free()
		player = null
	#for node: Node in entity_layer.get_children():
		#node.queue_free()
	for enemy: Actor in enemies:
		enemy.queue_free()
	enemies.clear()
	grid.cleanup()
	level_man.setup_board(self)
	terrain_layer.update_tilemaps(grid)
	is_set = true
	level_loaded.emit()


func reset() -> void:
	score = 0
	level_man.set_next_level(level_man.first_level_index, level_man.first_loop)
	setup()


func game_over(killer: Actor) -> void:
	%GameOverPanel.display(killer)
	Sounds.game_over.play()
	is_paused = true
	is_set = false
	

func victory() -> void:
	%VictoryPanel.display()
	is_paused = true
	is_set = false


func complete_level() -> void:
	Sounds.victory.play()
	if level_man.set_next_level():
		setup()


func until_no_movement() -> void:
	while movement_man.in_movement:
		await get_tree().process_frame


func check_level_completion() -> void:
	if not enemies.size():
		# lets firstly wait for all projectiles to hit their targets
		await until_no_movement()
		if is_set:
			complete_level()
