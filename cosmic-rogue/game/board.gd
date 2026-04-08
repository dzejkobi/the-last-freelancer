class_name Board extends Node

@export var grid: Grid
@export var level: Level

var size: Vector2i = Vector2i.ZERO

@onready var terrain_layer: TerrainLayer = $TerrainLayer
@onready var actor_layer: Node2D = $ActorLayer


func setup() -> void:
	grid.cleanup()
	level.setup_board(self)
	terrain_layer.update_tilemaps(grid)
