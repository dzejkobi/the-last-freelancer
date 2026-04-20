class_name ShieldAbsorb extends Node2D

@export var anim_time: float = 1.0
@export var color_name: String
@export var sound_name: String = "shield_absorb"

var color: Color
var sound: AudioPlayer.Sound

@onready var particles: GPUParticles2D = $Particles
@onready var timer: Timer = $Timer


func setup(pos: Vector2) -> void:
	position = pos
	if color_name:
		color = Colors.get(color_name)
	if sound_name:
		sound = Sounds.get(sound_name)
	Globals.board.entity_layer.add_child(self)


func display() -> void:
	var mat := particles.process_material.duplicate()
	mat.color = color
	particles.process_material = mat
	particles.emitting = true
	particles.one_shot = true
	if sound:
		sound.play({"global_position": global_position})
	timer.start(1.5 * anim_time)


func _on_timer_timeout() -> void:
	queue_free()
