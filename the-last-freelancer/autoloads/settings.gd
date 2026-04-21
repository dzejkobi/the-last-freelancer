# Settings

extends Node

enum BuildKind {
	UNKNOWN=0,
	WINDOWS=1,
	WEB=2,
	MAC=3
}

@export var config_path: String = "user://settings.cfg"
@export var build: BuildKind

var master_vol: float
var sfx_vol: float
var music_vol: float

var brightness: float
var fullscreen_on: bool
var bloom_on: bool
var crt_on: bool

var menu_key_name: String = "ESC"


func ensure_dir(path: String):
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())


func set_build() -> void:
	if build == BuildKind.WEB:
		var action_name := "ui_cancel"
		var events = InputMap.action_get_events(action_name)
		var key_event := InputEventKey.new()

		for event in events:
			if event is InputEventKey:
				InputMap.action_erase_event(action_name, event)

		key_event.physical_keycode = KEY_F1
		InputMap.action_add_event(action_name, key_event)
		menu_key_name = "F1"


func _ready() -> void:
	set_build()


func save():
	var config = ConfigFile.new()
	config.set_value("audio", "master_vol", master_vol)
	config.set_value("audio", "sfx_vol", sfx_vol)
	config.set_value("audio", "music_vol", music_vol)
	config.set_value("video", "brightness", brightness)
	config.set_value("video", "fullscreen", fullscreen_on)
	config.set_value("video", "bloom", bloom_on)
	config.set_value("video", "crt", crt_on)
	ensure_dir(config_path)
	config.save(config_path)


func load():
	var config = ConfigFile.new()
	var err = config.load(config_path)
	if err != OK:
		push_warning("No settings file, using defaults.")

	master_vol = config.get_value("audio", "master_vol", 1.0)
	sfx_vol = config.get_value("audio", "sfx_vol", 1.0)
	music_vol = config.get_value("audio", "music_vol", 1.0)
	brightness = config.get_value("video", "brightness", 1.2)
	fullscreen_on = config.get_value("video", "fullscreen", false)
	bloom_on = config.get_value("video", "bloom", true)
	crt_on = config.get_value("video", "crt", true)
