# AudioPlayer

extends Node

@export var stream_count: int = 16

@onready var sfx_players: Node = %SFXPlayers
@onready var music_player: AudioStreamPlayer = %MusicPlayer

var audio_listener: AudioListener2D


const DEFAULT_PLAY_ATTRS := {
	"volume": 1.0,
	"volume_variancy": 0.0,
	"pitch_scale": 1.0,
	"pitch_scale_variancy": 0.0,
}


class BaseSound:
	var path: String
	var stream: AudioStream
	var default_play_attrs: Dictionary
	
	func load_stream(_path: String) -> void:
		stream = load(_path)
	
	func _init(
		_path: String,
		_default_play_attrs: Dictionary = {},
		autoload: bool = true
	) -> void:
		path = _path
		default_play_attrs = _default_play_attrs.duplicate()
		for key: String in DEFAULT_PLAY_ATTRS.keys():
			if key not in default_play_attrs:
				default_play_attrs[key] = DEFAULT_PLAY_ATTRS[key]
		if autoload:
			load_stream(path)


class Sound extends BaseSound:

	func play(attrs: Dictionary = {}) -> AudioStreamPlayer2D:
		if not stream:
			push_error("The stream has not been loaded.")
		var player: AudioStreamPlayer2D = AudioPlayer.get_player()
		if not player:
			push_warning('No free audio stream.')
			return null

		for key: String in default_play_attrs.keys():
			if key not in attrs:
				attrs[key] = default_play_attrs[key]
				
		player.stream = stream
		player.volume_db = linear_to_db(
			randf_range(
				attrs["volume"] - 0.5 * attrs["volume_variancy"],
				attrs["volume"] + 0.5 * attrs["volume_variancy"]
			) if attrs.get("volume_variancy") else attrs["volume"]
		)
		player.pitch_scale = randf_range(
			attrs["pitch_scale"] - 0.5 * attrs["pitch_scale_variancy"],
			attrs["pitch_scale"] + 0.5 * attrs["pitch_scale_variancy"]
		) if attrs["pitch_scale_variancy"] else attrs["pitch_scale"]
		
		player.global_position = attrs.get("global_position", Vector2.ZERO)
		player.max_distance = attrs.get("max_distance", 2000.0) 
		player.play()
		return player


class Music extends BaseSound:
	
	func play(attrs: Dictionary = {}) -> AudioStreamPlayer:
		if not stream:
			push_error("The stream has not been loaded.")
		var player: AudioStreamPlayer = AudioPlayer.music_player
		
		if not player:
			push_warning('Music player is not available.')
			return null

		for key: String in default_play_attrs.keys():
			if key not in attrs:
				attrs[key] = default_play_attrs[key]
				
		player.stream = stream
		player.volume_db = linear_to_db(attrs["volume"])
		player.pitch_scale = attrs["pitch_scale"]
		player.play()
		return player


func _ready() -> void:
	var player: AudioStreamPlayer2D
	for i: int in range(stream_count):
		player = AudioStreamPlayer2D.new()
		player.bus = "SFX"
		sfx_players.add_child(player)


func setup(_audio_listener: AudioListener2D) -> void:
	audio_listener = _audio_listener
	

func get_player() -> AudioStreamPlayer2D:
	for player: AudioStreamPlayer2D in sfx_players.get_children():
		if not player.playing:
			return player
	return null
	
	
