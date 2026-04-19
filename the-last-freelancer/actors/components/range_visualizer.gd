class_name RangeVisualizer extends Node

const RangeMarkerScene = preload("res://entities/range_marker.tscn")

@export var is_active: bool = true

var markers: Dictionary[Vector2i, RangeMarker] = {}

@onready var actor: Actor = get_parent()


func _ready() -> void:
	Globals.board.level_loaded.connect(_at_movement_started)
	actor.movement_started.connect(_at_movement_started)


func clear_markers() -> void:
	for grid_pos in markers.keys():
		markers[grid_pos].disappear()
		markers.erase(grid_pos)


func get_cells_in_range() -> Array[Vector2i]:
	return Globals.grid.get_cells_in_range(
		actor.grid_pos, actor.attack_range
	)


func mark_range() -> void:
	var marker: RangeMarker
	var cell_coords: Array[Vector2i] = get_cells_in_range()
	
	# adding current markers
	for coord: Vector2i in cell_coords:
		if coord in markers.keys():
			continue
		marker = RangeMarkerScene.instantiate()
		Globals.board.entity_layer.add_child(marker)
		marker.setup(actor, coord)
		markers[coord] = marker
		
	# removing other markers
	for coord: Vector2i in markers.keys():
		if coord not in cell_coords:
			markers[coord].disappear()
			markers.erase(coord)


func _at_movement_started():
	if is_active:
		mark_range()


func _on_tree_exiting() -> void:
	clear_markers()
