class_name SettingsMenu extends CenterContainer

@export var music_on: bool = false

var music_player: AudioStreamPlayer

@onready var main_menu: MainMenu = %MainMenu
@onready var back_btn: Button = %BackBtn
@onready var display_btn: Button = %DisplayBtn
@onready var master_vol_slider: HSlider = %MasterVolSlider
@onready var sfx_vol_slider: HSlider = %SfxVolSlider
@onready var music_vol_slider: HSlider = %MusicVolSlider
@onready var bloom_chk_btn: CheckButton = %BloomChkBtn
@onready var crt_chk_btn: CheckButton = %CrtChkBtn
@onready var brightness_slider: HSlider = %BrightnessSlider


func toggle() -> void:
	visible = not visible
	Globals.board.is_paused = visible
	if visible:
		back_btn.grab_focus()
		main_menu.set_process(false)
	else:
		Settings.save()
		main_menu.set_process(true)


func toggle_music() -> void:
	music_on = not music_on
	if music_on:
		music_player = Sounds.music.play()
	elif music_player:
		music_player.stop()


func _ready() -> void:
	Settings.load()
	set_display(Settings.fullscreen_on)
	brightness_slider.value = Settings.brightness
	_on_brightness_slider_value_changed(brightness_slider.value)
	master_vol_slider.value = Settings.master_vol
	_on_master_vol_slider_value_changed(master_vol_slider.value)
	sfx_vol_slider.value = Settings.sfx_vol
	_on_sfx_vol_slider_value_changed(sfx_vol_slider.value)
	music_vol_slider.value = Settings.music_vol
	_on_music_vol_slider_value_changed(music_vol_slider.value)
	bloom_chk_btn.button_pressed = Settings.bloom_on
	_on_bloom_chk_btn_toggled(Settings.bloom_on)
	crt_chk_btn.button_pressed = Settings.crt_on
	_on_crt_chk_btn_toggled(Settings.crt_on)


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		back_btn.pressed.emit()


func _on_back_btn_pressed() -> void:
	toggle()
	main_menu.toggle()


func set_display(fullscreen_on: bool) -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	Settings.fullscreen_on = fullscreen_on
	if fullscreen_on:
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
	Settings.fullscreen_on = not Settings.fullscreen_on
	set_display(Settings.fullscreen_on)


func _on_master_vol_slider_value_changed(value: float) -> void:
	Settings.master_vol = value
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Master"),
		value
	)


func _on_sfx_vol_slider_value_changed(value: float) -> void:
	Settings.sfx_vol = value
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("SFX"),
		value
	)


func _on_music_vol_slider_value_changed(value: float) -> void:
	Settings.music_vol = value
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


func _on_bloom_chk_btn_toggled(toggled_on: bool) -> void:
	Settings.bloom_on = toggled_on
	%BloomLayer.visible = toggled_on


func _on_crt_chk_btn_toggled(toggled_on: bool) -> void:
	Settings.crt_on = toggled_on
	%CrtLayer.visible = toggled_on


func _on_brightness_slider_value_changed(value: float) -> void:
	Settings.brightness = value
	%AdjustmentsLayer/Adjustments.material\
		.set_shader_parameter("brightness", value)
