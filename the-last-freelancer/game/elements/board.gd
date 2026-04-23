class_name Board extends Node

const DIFFICULTY_MAP := {
	Enums.DIFFICULTY.EASY: {
		"shield_count": 2
	},
	Enums.DIFFICULTY.NORMAL: {
		"shield_count": 0
	},
	Enums.DIFFICULTY.HARD: {
		"shield_count": 0,
		"no_extra_shields": true
	},
	Enums.DIFFICULTY.HEROIC: {
		"shield_count": 0,
		"no_extra_shields": true,
		"no_range_markers": true
	},
}

@export var grid: Grid
@export var level_def: String
@export var is_paused: bool = true
@export var difficulty: Enums.DIFFICULTY = Enums.DIFFICULTY.NORMAL

var size: Vector2i = Vector2i.ZERO
var player: Player
var player_shield_count: int = 0:
	set(value):
		if value != player_shield_count:
			player_shield_count = value
			%ShieldInfoContainer.update_shield_display(value)
		
var enemies: Array[Actor] = []
var entities: Array[Entity] = []

var is_set: bool = false
var pending_projectiles: bool = false
var killer_name: String = "Enemy"

var score: int = 0:
	set(value):
		score = value
		%ScoreLabel.text = "Score: %s" % score

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


func at_level_start() -> void:
	for actor: Actor in [player] + enemies:
		actor.at_level_start()


func setup() -> void:
	if player:
		player.queue_free()
		player = null
	for entity: Entity in entities:
		entity.queue_free()
	entities.clear()
	for enemy: Actor in enemies:
		enemy.queue_free()
	enemies.clear()
	grid.cleanup()
	movement_man.reset()
	level_man.setup_board(self)
	player.shield_count = player_shield_count
	terrain_layer.update_tilemaps(grid)
	at_level_start()
	update_statuses()
	is_set = true
	level_loaded.emit()


func reset() -> void:
	score = 0
	level_man.set_next_level(level_man.first_level_index, level_man.first_loop)
	player_shield_count = DIFFICULTY_MAP[difficulty]["shield_count"]
	setup()


func update_statuses() -> void:
	for actor: Actor in [player] + enemies:
		actor.status_man.update()


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
