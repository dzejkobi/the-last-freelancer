class_name ShieldInfoContainer extends PanelContainer

@onready var icon_container: HBoxContainer = $HBoxContainer/IconContainer


func update_shield_display(shield_count: int):
	for i: int in icon_container.get_child_count():
		icon_container.get_child(i).visible = i < shield_count
