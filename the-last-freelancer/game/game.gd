class_name Game extends Control

const StartScreenScene = \
	preload("res://interludes/start_screen/start_screen.tscn")

@onready var board: Board = %Board
@onready var menu_info_label: Label = %MenuInfoLabel
@onready var gui_root: Control = %GUIRoot

var start_screen: StartScreen


func show_start_screen() -> void:
	remove_start_screen()
	start_screen = StartScreenScene.instantiate()
	gui_root.add_child(start_screen)
	gui_root.move_child(start_screen, 0)


func remove_start_screen() -> void:
	if start_screen:
		start_screen.queue_free()
		start_screen = null


func optimize() -> void:
	if Settings.build == Settings.BuildKind.WEB:
		var web_optimizer: WebOptimizer = \
			load("res://utilities/web_optimizer.tscn").instantiate()
		add_child(web_optimizer)
		web_optimizer.queue_free()


func _ready() -> void:
	optimize()
	RenderingServer.set_default_clear_color(Colors.bg_color)
	Globals.set_board(board)
	Globals.game = self
	menu_info_label.text = "%s: menu" % Settings.menu_key_name
	show_start_screen()
