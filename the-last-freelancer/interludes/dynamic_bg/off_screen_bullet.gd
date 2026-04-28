class_name OffScreenBullet extends Node2D

@export var speed: float = 600.0  # pixels / sec

@onready var sprite: Sprite2D = $Sprite


func setup(pos: Vector2, color: Color) -> void:
	position = pos
	modulate = color
	
	
func move_to(to_pos: Vector2) -> float:
	var distance: float = position.distance_to(to_pos)
	var duration: float = distance / speed
	var tween := create_tween()
	
	tween.tween_property(self, "position", to_pos, duration)
	tween.tween_callback(_at_target_reached)
	return duration

	
func _at_target_reached() -> void:
	queue_free()
