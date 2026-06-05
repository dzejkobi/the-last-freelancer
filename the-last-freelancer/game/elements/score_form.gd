extends VBoxContainer

@onready var name_edit: LineEdit = $NameEdit
@onready var submit_btn: Button = $SubmitBtn

signal score_submitted()


func set_focus() -> void:
	name_edit.editable = true
	submit_btn.disabled = not name_edit.text.length()
	name_edit.grab_focus()


func _ready() -> void:
	name_edit.text = LootLocker.player_name
	_on_name_edit_text_changed(name_edit.text)


func get_score_metadata() -> Dictionary:
	return {
		"progress": Globals.board.level_man.curr_progress,
		"difficulty": Globals.board.difficulty,
		"platform": Settings.build,
		"victory": Globals.board.is_completed
	}


func _on_name_edit_text_changed(new_text: String) -> void:
	submit_btn.disabled = not new_text


func _on_name_edit_text_submitted(new_text: String) -> void:
	if not new_text.length():
		return
	if new_text != LootLocker.player_name:
		LootLocker.set_player_name(new_text)
	name_edit.editable = false
	submit_btn.disabled = true
	score_submitted.emit()
	LootLocker.submit_score(Globals.board.score, get_score_metadata())


func _on_submit_btn_pressed() -> void:
	_on_name_edit_text_submitted(name_edit.text)
