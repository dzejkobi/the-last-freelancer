class_name MainMenu extends CenterContainer

@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var resume_btn: Button = %ResumeBtn
@onready var new_game_btn: Button = %NewGameBtn


func set_focus() -> void:
	if not resume_btn.disabled:
		resume_btn.grab_focus()
	else:
		new_game_btn.grab_focus()


func _ready() -> void:
	set_focus()


func toggle() -> void:
	Sounds.click.play()
	visible = not visible
	Globals.board.is_paused = visible
	if visible:
		resume_btn.disabled = not Globals.board.is_set
		set_focus()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()


func _on_resume_btn_pressed() -> void:
	toggle()


func _on_new_game_btn_pressed() -> void:
	Globals.board.reset()
	toggle()


func _on_settings_btn_pressed() -> void:
	toggle()
	settings_menu.toggle()


func _on_quit_btn_pressed() -> void:
	Sounds.click.play()
	get_tree().quit()
