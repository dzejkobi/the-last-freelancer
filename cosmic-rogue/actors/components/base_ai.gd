class_name BaseAI extends Node

var board: Board

@onready var actor: Actor = get_parent()


func _ready() -> void:
	Globals.board.player_movement_started.connect(
		_on_player_movement_started
	)


func move() -> void:
	pass  # Override in derived class


func _on_player_movement_started(_player: Actor):
	if not actor.is_dying:
		move()
