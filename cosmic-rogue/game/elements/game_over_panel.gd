extends PanelContainer

@onready var killer_label: Label = $VBoxContainer/KillerLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var hint_label: Label = $VBoxContainer/HintLabel


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
	
	
func _unhandled_input(event):
	if (
		visible and (
			event is InputEventKey and event.pressed or
			event is InputEventMouseButton and event.pressed
		)
	):
		visible = false
		%MainMenu.toggle()
