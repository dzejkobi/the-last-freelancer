class_name VictoryScreen extends Control

@onready var rocket: Rocket = $Rocket
@onready var victory_panel: PanelContainer = %VictoryPanel
@onready var score_label: Label = %VictoryPanel/%ScoreLabel


func display() -> void:
	if score_label and Globals.board:
		score_label.text = "Final score: %s" % Globals.board.score


func _ready() -> void:
	display()


func _input(event):
	if (
		(event is InputEventKey and event.pressed) or
		(event is InputEventMouseButton and event.pressed)
	):
		if rocket.is_flying:
			rocket.explode()
		else:
			var main_menu: MainMenu = get_tree().get_root()\
				.find_child("MainMenu", true, false)
			Globals.game.show_start_screen()
			main_menu.toggle()
			queue_free()
