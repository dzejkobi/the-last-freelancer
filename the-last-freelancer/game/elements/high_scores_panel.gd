class_name HighScoresPanel extends CenterContainer

@onready var main_menu: MainMenu = %MainMenu
@onready var back_btn: Button = %BackBtn
@onready var grid_cnt: GridContainer = %GridCnt
@onready var loading_label: Label = %LoadingLabel
@onready var scroll_container: ScrollContainer = %ScrollContainer

var my_score_control: Control

signal loading_started
signal loading_finished


func make_grid_cell(
	text: String, min_width: int = -1, max_width: int = -1
) -> Label:
	var label := Label.new()

	label.text = text
	if min_width > 0 and max_width > 0:
		assert(min_width <= max_width)
	if min_width > 0:
		label.custom_minimum_size.x = min_width
	if max_width > 0:
		label.custom_minimum_size.x = max_width
		label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
	return label


func populate_scores(scores) -> void:
	var i: int = 1
	var player: Dictionary
	var player_label: Control
	var meta_str: String
	var meta: Dictionary
	var difficulty: String
	var platform: String
	var progress: String
	
	for entry: Dictionary in scores:
		player = entry.get("player", {})
		meta_str = entry.get("metadata", "{}")
		if not len(meta_str) or meta_str[0] != "{":
			meta_str = "{}"
		meta = JSON.parse_string(meta_str)
		difficulty = Enums.DIFFICULTY.keys()[meta.get("difficulty", 0)]\
			.to_lower().capitalize()
		platform = Settings.BuildKind.keys()[meta.get("platform", 0)]\
			.to_lower().capitalize()
		progress = meta.get("progress", "?")
		if meta.get("victory", false):
			progress = "Victory!"
		
		grid_cnt.add_child(make_grid_cell(str(i)))
		player_label = make_grid_cell(player.get("name", "?"))
		grid_cnt.add_child(player_label)
		if (
			str(int(player.get("id", "-1"))) == LootLocker.player_id and
			not my_score_control
		):
			my_score_control = player_label
		grid_cnt.add_child(make_grid_cell(difficulty))
		grid_cnt.add_child(make_grid_cell(platform))
		grid_cnt.add_child(make_grid_cell(progress))
		grid_cnt.add_child(make_grid_cell(str(int(entry.get("score")))))
		i += 1


func update_data() -> void:
	loading_started.emit()
	my_score_control = null
	
	for child in grid_cnt.get_children():
		child.queue_free()

	# Header
	grid_cnt.add_child(make_grid_cell("#"))
	grid_cnt.add_child(make_grid_cell("Player", 150, 150))
	grid_cnt.add_child(make_grid_cell("Difficulty"))
	grid_cnt.add_child(make_grid_cell("Platform"))
	grid_cnt.add_child(make_grid_cell("Progress", 150, 150))
	grid_cnt.add_child(make_grid_cell("Score"))

	var scores = []
	for difficulty: int in (range(1, 5)):
		scores = await LootLocker.get_scores(difficulty, 100)
		populate_scores(scores)

	loading_finished.emit()


func toggle() -> void:
	visible = not visible
	Globals.board.is_paused = visible
	if visible:
		update_data()
		back_btn.grab_focus()
		main_menu.set_process(false)
	else:
		Settings.save()
		main_menu.set_process(true)


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		back_btn.pressed.emit()
		

func _on_back_btn_pressed() -> void:
	toggle()
	main_menu.toggle()
	

func _on_loading_started() -> void:
	loading_label.visible = true


func _on_loading_finished() -> void:
	loading_label.visible = false
	if my_score_control:
		scroll_container.ensure_control_visible(my_score_control)
