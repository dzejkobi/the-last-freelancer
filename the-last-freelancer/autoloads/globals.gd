extends Node

var grid: Grid
var board: Board


func set_board(_board: Board) -> void:
	board = _board
	grid = board.grid
	board.reset()
