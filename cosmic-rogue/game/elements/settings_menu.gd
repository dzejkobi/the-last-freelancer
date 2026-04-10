class_name SettingsMenu extends CenterContainer

@export var is_full_screen: bool = false
@export var music_on: bool = false

var music_player: AudioStreamPlayer

@onready var main_menu: MainMenu = %MainMenu
@onready var back_btn: Button = %BackBtn
@onready var display_btn: Button = %DisplayBtn
@onready var master_vol_slider: HSlider = %MasterVolSlider
@onready var sound_vol_slider: HSlider = %SoundVolSlider
@onready var music_vol_slider: HSlider = %MusicVolSlider


func toggle() -> void:
	visible = not visible
	Globals.board.is_paused = visible
	if visible:
		back_btn.grab_focus()
		main_menu.set_process(false)
	else:
		main_menu.set_process(true)


func toggle_music() -> void:
	music_on = not music_on
	if music_on:
		music_player = Sounds.music.play()
	elif music_player:
		music_player.stop()


func _ready() -> void:
	set_display(is_full_screen)
	master_vol_slider.value = AudioServer.get_bus_volume_linear(
		AudioServer.get_bus_index("Master")
	)
	_on_sound_vol_slider_value_changed(master_vol_slider.value)
	sound_vol_slider.value = AudioServer.get_bus_volume_linear(
		AudioServer.get_bus_index("SFX")
	)
	_on_sound_vol_slider_value_changed(sound_vol_slider.value)
	music_vol_slider.value = AudioServer.get_bus_volume_linear(
		AudioServer.get_bus_index("Music")
	)
	_on_master_vol_slider_value_changed(master_vol_slider.value)
	_on_sound_vol_slider_value_changed(sound_vol_slider.value)
	_on_music_vol_slider_value_changed(music_vol_slider.value)


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		back_btn.pressed.emit()


func _on_back_btn_pressed() -> void:
	toggle()
	main_menu.toggle()


func set_display(full_screen: bool) -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	if full_screen:
		DisplayServer.window_set_size(screen_size)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		display_btn.text = "Display: FULL SCREEN"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var window: Window = get_window()
		window.size = Vector2i(1024, 768)
		window.position = floor((screen_size - window.size) / 2.0)
		display_btn.text = "Display: WINDOWED"


func _on_display_btn_pressed() -> void:
	Sounds.click.play()
	is_full_screen = not is_full_screen
	set_display(is_full_screen)


func _on_master_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Master"),
		value
	)


func _on_sound_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("SFX"),
		value
	)


func _on_music_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Music"),
		value
	)
	if (
		not music_player or
		(value == 0.0 and music_player.playing) or
		(value > 0.0 and not music_player.playing)
	):
		toggle_music()
		
		


func _on_glow_chk_btn_toggled(toggled_on: bool) -> void:
	%BloomLayer.visible = toggled_on


func _on_crt_chk_btn_toggled(toggled_on: bool) -> void:
	%CrtLayer.visible = toggled_on
