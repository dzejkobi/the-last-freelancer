class_name Game extends Control

@onready var board: Board = %Board
@onready var menu_info_label: Label = %MenuInfoLabel


func _ready() -> void:
	RenderingServer.set_default_clear_color(Colors.bg_color)
	Globals.set_board(board)
	Globals.game = self
	menu_info_label.text = "%s - menu" % Settings.menu_key_name
