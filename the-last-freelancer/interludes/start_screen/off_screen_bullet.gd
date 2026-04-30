class_name OffScreenBullet extends Node2D

@export var speed: float = 600.0  # pixels / sec

@onready var sprite: Sprite2D = $Sprite

var character: OffScreenChar


func setup(pos: Vector2, color: Color, _character: OffScreenChar) -> void:
	position = pos
	modulate = color
	character = _character


func _process(_delta: float) -> void:
	var y_range: Array[float] = character._get_y_range()
	var scale_factor = lerpf(
		0.5, 1.0, (position.y - y_range[0]) / (y_range[1] - y_range[0])
	)
	scale = Vector2(scale_factor, scale_factor)
	modulate.a = scale_factor
	
	
func move_to(to_pos: Vector2) -> float:
	var distance: float = position.distance_to(to_pos)
	var duration: float = distance / speed
	var tween := create_tween()
	
	tween.tween_property(self, "position", to_pos, duration)
	tween.tween_callback(_at_target_reached)
	return duration

	
func _at_target_reached() -> void:
	queue_free()
