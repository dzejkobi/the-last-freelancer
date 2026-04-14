class_name Projectile extends Node2D

const  SplashScene := preload("res://entities/splash.tscn")

@export var kind: Enums.PROJECTILE_TYPE
@export var speed: float = 800.0  # pixels / sec

var to_grid_pos: Vector2i
var shooter: Actor

@onready var sprite: Sprite2D = $Sprite

var kind_map: Dictionary = {
	Enums.PROJECTILE_TYPE.PLAYER_BOLT: {
		"region": Rect2(48, 0, 16, 16),
		"color": Colors.player_color
	},
	Enums.PROJECTILE_TYPE.RECRUITER_BOLT: {
		"region": Rect2(48, 0, 16, 16),
		"color": Colors.recruiter_color,
		"actor_name": "Rectuiter"
	},
	Enums.PROJECTILE_TYPE.HEADHUNTER_BOLT: {
		"region": Rect2(48, 0, 16, 16),
		"color": Colors.headhunter_color,
		"speed": 1600.0,
		"actor_name": "Headhunter"
	},
	Enums.PROJECTILE_TYPE.WEB: {
		"region": Rect2(32, 0, 16, 16),
		"color": Colors.crawler_color,
		"actor_name": "Crawler"
	},
}


func _ready() -> void:
	var map_item: Dictionary = kind_map.get(kind)
	if map_item:
		sprite.region_rect = map_item["region"]
		sprite.modulate = map_item["color"]
		speed = map_item.get("speed", speed)


func move_to(_to_grid_pos: Vector2i) -> void:
	to_grid_pos = _to_grid_pos
	
	var to_pos: Vector2 = Grid.grid_pos_to_pos(to_grid_pos)
	var distance: float = position.distance_to(to_pos)
	var duration: float = distance / speed
	var tween = create_tween()
	
	tween.tween_property(self, "position", to_pos, duration)
	tween.tween_callback(_at_target_reached)
	
	
func _at_target_reached() -> void:
	var cell: GridCell = Globals.board.grid.cells.get(to_grid_pos)
	var splash: Splash
	if cell and cell.actor:
		splash = SplashScene.instantiate()
		splash.position = cell.actor.position + floor(0.5 * Consts.TILE_SIZE)
		Globals.board.entity_layer.add_child(splash)
		splash.display(Colors.get(cell.actor.color_name))
		cell.actor.hit_by_projectile(self)
	queue_free()
