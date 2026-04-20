class_name Collectable extends Entity

@export var for_player: bool = false
@export var for_enemy: bool = false
@export var collect_sound_name: String = ""

var collect_sound: AudioPlayer.Sound


func _ready() -> void:
	super._ready()
	if collect_sound_name:
		collect_sound = Sounds.get(collect_sound_name)


func play_collect_animation() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(cleanup)


func is_collectable_by(actor: Actor) -> bool:
	return (
		(actor is Player and for_player) or
		actor.is_enemy and for_enemy
	)


func collect_by(_actor: Actor) -> void:
	if collect_sound:
		collect_sound.play({"global_position": global_position})
	play_collect_animation()
	cleanup()
