class_name Rocket extends Node2D

var time := 0.0

@export var is_flying: bool = true

@onready var rocket_part_1: RigidBody2D = $RocketPart1
@onready var rocket_part_2: RigidBody2D = $RocketPart2
@onready var rocket_part_3: RigidBody2D = $RocketPart3
@onready var rocket_part_4: RigidBody2D = $RocketPart4
@onready var pilot: RigidBody2D = $Pilot
@onready var expl_particles: GPUParticles2D = $ExplParticles

@onready var parts: Array[RigidBody2D] = [
	rocket_part_1, rocket_part_2, rocket_part_3, rocket_part_4
]

@onready var starting_pos: Vector2 = position


func _process(delta):
	if is_flying:
		time += delta
		var offset = Vector2(
			sin(time * 2.0) * 20.0,
			cos(time * 1.5) * 10.0
		)
		position = starting_pos + offset


func explode() -> void:
	is_flying = false
	Sounds.explosion.play({"global_position": global_position})
	expl_particles.one_shot = true
	expl_particles.emitting = true
	
	for part: RigidBody2D in parts:
		part.freeze = false
		part.apply_impulse(
			Vector2.UP.rotated(randf_range(-0.25 * PI, 0.25 * PI))
			* randf_range(700, 900)
		)

	pilot.visible = true
	pilot.freeze = false
	pilot.apply_impulse(
		Vector2.UP.rotated(randf_range(0.1 * PI, 0.15 * PI))
		* randf_range(900, 1000)
	)
