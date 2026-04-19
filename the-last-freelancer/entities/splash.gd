class_name Splash extends Node2D

@export var anim_time: float = 1.0

@onready var particles: GPUParticles2D = $Particles
@onready var timer: Timer = $Timer


func display(color: Color) -> void:
	var mat := particles.process_material.duplicate()
	mat.color = color
	particles.process_material = mat
	particles.emitting = true
	particles.one_shot = true
	timer.start(1.5 * anim_time)


func _on_timer_timeout() -> void:
	queue_free()
