class_name InputController extends Node

@onready var actor: Actor = get_parent()

var stacked_action_name: String = ""


func _ready() -> void:
	Globals.board.movement_man.movement_finished.connect(_at_movement_finished)


func execute_movement_action(action_name: String) -> void:
	var direction: Vector2i
	var to_grid_pos: Vector2i
	
	if action_name == "ui_left":
		direction = Vector2i.LEFT
	elif action_name == "ui_right":
		direction = Vector2i.RIGHT
	elif action_name == "ui_up":
		direction = Vector2i.UP
	elif action_name == "ui_down":
		direction = Vector2i.DOWN
	elif action_name == "ui_accept":
		actor.wait()
		return
	else:
		push_error('Unsupported action "%s".' % action_name)
		return

	to_grid_pos = actor.grid_pos + direction
	if actor.is_movement_valid(to_grid_pos):
		actor.move_to_cell(to_grid_pos)


func _unhandled_input(_event: InputEvent) -> void:
	if Globals.board.is_paused or not actor:
		return

	elif Globals.board.movement_man.in_movement:
		if not stacked_action_name:
			for action_str in [
				"ui_left", "ui_right", "ui_up", "ui_down", "ui_accept"
			]:
				if Input.is_action_just_pressed(action_str):
					stacked_action_name = action_str
		return
	
	for action_name: String in [
		"ui_left", "ui_right", "ui_up", "ui_down", "ui_accept"
	]:
		if Input.is_action_just_pressed(action_name):
			execute_movement_action(action_name)


func _at_movement_finished() -> void:
	if not actor.is_dying:
		Globals.board.update_statuses()
		if stacked_action_name:
			execute_movement_action(stacked_action_name)
			stacked_action_name = ""
