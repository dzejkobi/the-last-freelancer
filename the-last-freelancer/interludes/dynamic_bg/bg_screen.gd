class_name StartScreen extends Control


var char_map: Dictionary[OffScreenChar.BORDER, OffScreenChar] = {
	OffScreenChar.BORDER.LEFT: null,
	OffScreenChar.BORDER.RIGHT: null,
	OffScreenChar.BORDER.BOTTOM: null
}


func enable() -> void:
	process_mode = PROCESS_MODE_INHERIT
	visible = true
	
	
func  disable() -> void:
	process_mode = PROCESS_MODE_DISABLED
	visible = false
	

# Tries to find free border for OffScreenCHaracter.
# It has to be unocuppied and diffrent than previous one.
func get_free_border(_char: OffScreenChar) -> OffScreenChar.BORDER:
	var free_borders: Array[OffScreenChar.BORDER] = []
	
	for border: OffScreenChar.BORDER in char_map.keys():
		if not char_map[border] and border != _char.last_border:
			free_borders.append(border)
	if free_borders.size():
		return free_borders.pick_random()
	else:
		return OffScreenChar.BORDER.NONE
	
	
func search_for_enemy(_char: OffScreenChar) -> OffScreenChar:
	var enemies: Array[OffScreenChar] = []
	for enemy: OffScreenChar in char_map.values():
		if (
			enemy and
			enemy.is_enemy != _char.is_enemy and 
			enemy.state == OffScreenChar.STATE.OBSERVING
		):
			enemies.append(enemy)
	if enemies.size():
		return enemies.pick_random()
	else:
		return null
