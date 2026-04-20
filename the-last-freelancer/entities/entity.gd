class_name Entity extends Node2D

@export var color_name: String

var grid_pos: Vector2i

@onready var anim_sprite: AnimatedSprite2D = $AnimSprite


func setup(_grid_pos: Vector2i) -> void:
	grid_pos = _grid_pos
	position = Grid.grid_pos_to_pos(grid_pos)
	Globals.board.entities.append(self)


func cleanup() -> void:
	Globals.board.entities.erase(self)
	queue_free()


func _ready() -> void:
	if color_name:
		anim_sprite.modulate = Colors.get(color_name)
