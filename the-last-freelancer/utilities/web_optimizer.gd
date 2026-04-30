class_name WebOptimizer extends Node2D

# Special utility node used to prepare all particle effects at the start
# of the game. This should reduce lags during the game when particles
# are being created for the first time.


func _ready() -> void:
	position = Vector2i(10000, 10000)  # to be sure it's off the screen
