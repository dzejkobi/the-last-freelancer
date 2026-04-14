extends PanelContainer

@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var killer_label: Label = $VBoxContainer/KillerLabel


func display(killer: Actor = null) -> void:
	killer_label.text = \
		"by: %s" % (killer.verbose_name if killer else "Something")
	level_label.text = "at level: %s" % Globals.board.level_man.curr_progress
	score_label.text = "your score: %s" % Globals.board.score
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
