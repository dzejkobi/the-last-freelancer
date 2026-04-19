class_name Crosshair extends Node2D

@export var color_name: String = "headhunter_color"
@export var tween_time: float = 0.5

var grid_pos: Vector2i

@onready var anim_sprite: AnimatedSprite2D = $AnimSprite


func _ready() -> void:
	anim_sprite.modulate = Colors.get(color_name)
	anim_sprite.modulate.a = 0.0
	
	
func appear_at(_grid_pos: Vector2i) -> void:
	grid_pos = _grid_pos
	position = Grid.grid_pos_to_pos(grid_pos)
	var tween := anim_sprite.create_tween()
	tween.tween_property(anim_sprite, "modulate:a", 1.0, tween_time)
	
	
func disappear() -> void:
	var tween := anim_sprite.create_tween()
	tween.tween_property(anim_sprite, "modulate:a", 0.0, tween_time)
	tween.tween_callback(func ():
		queue_free()
	)
	
	
func move_to(_grid_pos: Vector2i) -> void:
	var tween := create_tween()
	grid_pos = _grid_pos
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		self, "position", Grid.grid_pos_to_pos(grid_pos), tween_time
	)
	
