class_name Game extends Node2D

@onready var board: Board = $Board


func _ready() -> void:
	board.setup()
	RenderingServer.set_default_clear_color(Colors.bg_color)
	
