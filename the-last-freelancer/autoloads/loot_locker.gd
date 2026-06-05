extends Node

@export var game_api_key := "dev_4c7279f1a3e9457dae79fca5822b1e21"
@export var game_api_domain := "https://xt9x1cs6.api.lootlocker.io/"
@export var leaderboard_keys := {
	Enums.DIFFICULTY.EASY: "tlf_easy",
	Enums.DIFFICULTY.NORMAL: "tlf_normal",
	Enums.DIFFICULTY.HARD: "tlf_hard",
	Enums.DIFFICULTY.HEROIC: "tlf_heroic"
}
"tlf_scores"
@export var player_cfg_path: String = "user://player.cfg"

var player_id: String
var player_name: String


func _handle_http_response(response) -> bool:
	if !response.success:
		printerr(
			'LootLocker failed with reason: %s'
			% response.error_data.to_string()
		)
		return false
	return true


func fix_encoding(text: String) -> String:
	"""
	LootLockerSDK improperly decodes Unicode characters in file:
	res://addons/LootLockerSDK/Game/Internals/LootLockerInternal_HTTPClient.gd
	line 106:		var text = rb.get_string_from_ascii()
	should be:	 	var text = rb.get_string_from_utf8()
	This is workarround to compensate that.
	"""
	var bytes := PackedByteArray()
	for c in text:
		bytes.append(c.unicode_at(0))
	return bytes.get_string_from_utf8()


func load_player_data() -> void:
	var config = ConfigFile.new()
	var err = config.load(player_cfg_path)
	
	player_id = config.get_value(
		"player", "player_id", str(ResourceUID.create_id())
	)
	player_name = config.get_value("player", "player_name", "")
	
	if err != OK:
		push_warning("No player config file, using defaults.")
		save_player_data()
	
	
func save_player_data() -> void:
	var config = ConfigFile.new()
	config.set_value("player", "player_id", player_id)
	config.set_value("player", "player_name", player_name)
	Helpers.ensure_dir(player_cfg_path)
	config.save(player_cfg_path)


func setup() -> void:
	load_player_data()


func login() -> bool:
	var response = await LL_Authentication.GuestSession\
		.new(player_id).send()

	if !response.success:
		printerr(
			"LootLocker Guest login failed with reason: %s" %
			response.error_data.to_string()
		)
		return false
		
	player_name = response.player_name

	return true
	

func set_player_name(_player_name: String) -> bool:
	var response = await LL_Players.SetPlayerName \
		.new(_player_name).send()
	
	if not _handle_http_response(response):
		return false
	
	player_name = _player_name
	save_player_data()
	return true
	

func submit_score(score: int, metadata: Dictionary = {}) -> bool:
	var response = await LL_Leaderboards.SubmitScore.new(
		leaderboard_keys[metadata["difficulty"]], score, player_id,
		JSON.stringify(metadata)
	).send()
	return _handle_http_response(response)


func get_scores(difficulty: Enums.DIFFICULTY, count: int) -> Array:
	var response = await LL_Leaderboards.GetScoreList.new(
		leaderboard_keys[difficulty], count
	).send()
	var success := _handle_http_response(response)
	var body: Dictionary
	var scores: Array[Dictionary] = []
	
	if success:
		body = JSON.parse_string(fix_encoding(response.raw_response_body))
		if body["items"]:
			for item: Dictionary in body["items"]:
				scores.append(item)
		return scores
	
	else:
		return []
