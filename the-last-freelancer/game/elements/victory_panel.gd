extends PanelContainer

@onready var score_label: Label = $VBoxContainer/ScoreLabel


func display() -> void:
	score_label.text = "Final score: %s" % Globals.board.score
	visible = true
	
	
func _unhandled_input(event):
	if (
		visible and (
			event is InputEventKey and event.pressed or
			event is InputEventMouseButton and event.pressed or 
			event is InputEventJoypadButton and event.pressed
		)
	):
		visible = false
		%MainMenu.toggle()
