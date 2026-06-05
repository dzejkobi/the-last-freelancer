extends PanelContainer

@onready var killer_label: Label = $VBoxContainer/KillerLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var hint_label: Label = $VBoxContainer/HintLabel
@onready var score_form: VBoxContainer = $VBoxContainer/ScoreForm


func display(killer: Actor = null) -> void:
	killer_label.text = \
		"by: %s" % (killer.verbose_name if killer else "Something")
	level_label.text = "at level: %s" % Globals.board.level_man.curr_progress
	score_label.text = "your score: %s" % Globals.board.score
	if killer and killer.hint.length():
		hint_label.visible = true
		hint_label.text = "Did you know?:\n%s" % killer.hint
	else:
		hint_label.visible = false
	visible = true
	score_form.set_focus()


func _unhandled_input(event):
	if (
		visible and (
			event.is_action_pressed("ui_cancel") or
			event is InputEventJoypadButton and event.pressed
			# event is InputEventMouseButton and event.pressed
		)
	):
		visible = false
		%MainMenu.toggle()


func _on_score_form_score_submitted() -> void:
	if visible:
		visible = false
		%HighScoresPanel.toggle()
