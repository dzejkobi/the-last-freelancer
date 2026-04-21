class_name NewGameMenu extends CenterContainer

@onready var go_back_btn: Button = $PanelContainer/VBoxContainer/GoBackBtn
@onready var easy_btn: Button = $PanelContainer/VBoxContainer/EasyBtn
@onready var normal_btn: Button = $PanelContainer/VBoxContainer/NormalBtn
@onready var hard_btn: Button = $PanelContainer/VBoxContainer/HardBtn
@onready var heroic_btn: Button = $PanelContainer/VBoxContainer/HeroicBtn
@onready var comment_label: Label = $PanelContainer/VBoxContainer/CommentLabel


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		go_back_btn.pressed.emit()


func toggle() -> void:
	Sounds.click.play()
	visible = not visible
	if visible:
		normal_btn.grab_focus()


func set_comment_for_button(button: Button) -> void:
	match button:
		go_back_btn:
			comment_label.text = "Are you scared?"
		easy_btn:
			comment_label.text = "Piece of cake..."
		normal_btn:
			comment_label.text = "Balanced experience - recommended"
		hard_btn:
			comment_label.text = "Make no mistakes"
		heroic_btn:
			comment_label.text = "Is this even possible!?"


func clear_comment() -> void:
	comment_label.text = ""


func _on_btn_focus_entered() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused is Button:
		set_comment_for_button(focused)
		
		
func _on_btn_mouse_entered() -> void:
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered is Button:
		set_comment_for_button(hovered)


func _on_go_back_btn_pressed() -> void:
	toggle()
	%MainMenu.toggle()


func start_game_with_difficulty(difficulty: Enums.DIFFICULTY) -> void:
	Globals.board.difficulty = difficulty
	Globals.board.reset()
	toggle()


func _on_easy_btn_pressed() -> void:
	start_game_with_difficulty(Enums.DIFFICULTY.EASY)


func _on_normal_btn_pressed() -> void:
	start_game_with_difficulty(Enums.DIFFICULTY.NORMAL)


func _on_hard_btn_pressed() -> void:
	start_game_with_difficulty(Enums.DIFFICULTY.HARD)
	

func _on_heroic_btn_pressed() -> void:
	start_game_with_difficulty(Enums.DIFFICULTY.HEROIC)
	
