class_name VictoryScreen extends Control

@onready var rocket: Rocket = $Rocket
@onready var victory_panel: PanelContainer = %VictoryPanel
@onready var score_label: Label = %VictoryPanel/%ScoreLabel
@onready var score_form: VBoxContainer = %VictoryPanel/VBoxContainer/ScoreForm

var explosion_finished: bool = false
var score_submitted: bool = false


func display() -> void:
	if score_label and Globals.board:
		score_label.text = "Final score: %s" % Globals.board.score
	score_form.set_focus()


func _ready() -> void:
	score_form.score_submitted.connect(_on_score_form_score_submitted)
	display()


func back_to_start_screen() -> void:
	var high_scores_panel: HighScoresPanel = get_tree().get_root()\
		.find_child("HighScoresPanel", true, false)
	Globals.game.show_start_screen()
	high_scores_panel.toggle()
	queue_free()


func _input(event):
	if (
		(event is InputEventKey and event.pressed) or
		(event is InputEventMouseButton and event.pressed)
	):
		if rocket.is_flying:
			rocket.explode()
		elif event.is_action_pressed("ui_cancel"):
			back_to_start_screen()


func _on_score_form_score_submitted() -> void:
	score_submitted = true
	if explosion_finished:
		back_to_start_screen()


func _on_rocket_explosion_finished() -> void:
	explosion_finished = true
	if score_submitted:
		back_to_start_screen()
