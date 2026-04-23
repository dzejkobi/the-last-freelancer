# Sounds

extends Node


var music := AudioPlayer.Music.new(
	"res://assets/music/theme.ogg",
	{
		"volume": 0.5
	}
)


var click := AudioPlayer.Sound.new(
	"res://assets/sounds/click.ogg",
	{
		"volume": 0.6,
		"pitch_scale_variancy": 0.2
	},
	true
)

var enemy_dies := AudioPlayer.Sound.new(
	"res://assets/sounds/enemy_dies.ogg",
	{
		"volume": 0.6,
		"pitch_scale_variancy": 0.2
	},
	true
)

var footstep := AudioPlayer.Sound.new(
	"res://assets/sounds/footstep.ogg",
	{
		"volume": 0.6,
		"pitch_scale_variancy": 0.2
	},
	true
)

var game_over := AudioPlayer.Sound.new(
	"res://assets/sounds/game_over.ogg",
	{
		"volume": 1.0,
		"pitch_scale_variancy": 0.2
	},
	true
)

var laser := AudioPlayer.Sound.new(
	"res://assets/sounds/laser.ogg",
	{
		"volume": 0.7,
		"pitch_scale_variancy": 0.4
	},
	true
)

var shield_absorb := AudioPlayer.Sound.new(
	"res://assets/sounds/shield_absorb.ogg",
	{
		"volume": 1.0,
		"pitch_scale": 1.0,
		"pitch_scale_variancy": 0.2
	},
	true
)

var shield_collect := AudioPlayer.Sound.new(
	"res://assets/sounds/shield_collect.ogg",
	{
		"volume": 1.0,
		"pitch_scale": 0.7,
		"pitch_scale_variancy": 0.2
	},
	true
)

var victory := AudioPlayer.Sound.new(
	"res://assets/sounds/victory.ogg",
	{
		"volume": 1.0,
		"pitch_scale_variancy": 0.2
	},
	true
)
