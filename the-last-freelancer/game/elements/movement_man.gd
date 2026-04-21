class_name MovementMan extends Node

var moving_actors: Array[Actor] = []
var moving_projectiles: Array[Projectile] = []
var in_movement: bool = false

signal movement_started
signal movement_finished


func reset() -> void:
	moving_actors.clear()
	moving_projectiles.clear()
	in_movement = false


func register_actor(actor: Actor) -> void:
	if actor in moving_actors:
		push_error('Actor "%s" is already registered.' % actor)
	moving_actors.append(actor)
	if not in_movement and moving_actors.size():
		in_movement = true
		movement_started.emit()
	
	
func unregister_actor(actor: Actor, ignore_missing: bool = false) -> void:
	if actor not in moving_actors:
		if ignore_missing:
			return
		else:
			push_error('Actor "%s" is not registered.' % actor)
			return
	moving_actors.erase(actor)
	if in_movement and not (moving_actors.size() or moving_projectiles.size()):
		in_movement = false
		movement_finished.emit()
	
	
func register_projectile(projectile: Projectile) -> void:
	if projectile in moving_projectiles:
		push_error('Projectile "%s" is already registered.' % projectile)
	moving_projectiles.append(projectile)
	if not in_movement and moving_projectiles.size():
		in_movement = true
		movement_started.emit()
	
	
func unregister_projectile(projectile: Projectile) -> void:
	if projectile not in moving_projectiles:
		push_error('Projectile "%s" is not registered.' % projectile)
	moving_projectiles.erase(projectile)
	if in_movement and not (moving_actors.size() or moving_projectiles.size()):
		in_movement = false
		movement_finished.emit()
