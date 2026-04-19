class_name RangeMarker extends Node2D

const anim_time: float = 0.2

@export var transparency: float = 0.08

var actor: Actor
var grid_pos: Vector2i

@onready var sprite: Sprite2D = $Sprite


func appear() -> void:
	var tween := self.create_tween()
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", transparency, anim_time)


func disappear() -> void:
	var tween := self.create_tween()
	tween.tween_property(self, "modulate:a", 0.0, anim_time)
	tween.tween_callback(func ():
		queue_free()
	)


func setup(_actor: Actor, _grid_pos: Vector2i) -> void:
	actor = _actor
	grid_pos = _grid_pos
	position = Grid.grid_pos_to_pos(grid_pos)
	sprite.modulate = Colors.get(actor.color_name)
	appear()
