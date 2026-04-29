class_name TeleportBeam extends Node2D

@export var anim_time: float = 0.6

@onready var glow: TextureRect = $glow
@onready var beam_in_particles: GPUParticles2D = $BeamInParticles
@onready var beam_out_particles: GPUParticles2D = $BeamOutParticles

var glow_tween: Tween
var callback_fn: Callable


func animate_beam() -> void:
	glow.modulate.a = 0.0
	glow_tween = glow.create_tween()
	glow_tween.tween_property(glow, "modulate:a", 1.0, anim_time / 2)
	glow_tween.tween_property(glow, "modulate:a", 0.0, anim_time / 2)
	glow_tween.tween_callback(_on_anim_finished)


func beam_in(_callback_fn: Callable = func (): pass) -> void:
	callback_fn = _callback_fn
	Sounds.beam_in.play({"global_position": global_position})
	animate_beam()
	beam_in_particles.emitting = true
	

func beam_out(_callback_fn: Callable = func (): pass) -> void:
	callback_fn = _callback_fn
	Sounds.beam_out.play({"global_position": global_position})
	animate_beam()
	beam_out_particles.emitting = true
	

func _on_anim_finished() -> void:
	callback_fn.call()
	queue_free()
