class_name Player extends Actor


func at_level_start(_data: Dictionary = {}) -> void:
	play_beam_in_animation()


func move_to_cell(to_grid_pos: Vector2i) -> void:
	Sounds.footstep.play({"global_position": global_position})
	super.move_to_cell(to_grid_pos)
	Globals.board.player_movement_started.emit(self)


func wait() -> void:
	super.wait()
	Globals.board.player_movement_started.emit(self)


func die(killer: Actor = null) -> void:
	Sounds.game_over.play()
	super.die(killer)
	Globals.board.game_over(killer)


func finish_level() -> void:
	var tween = anim_sprite.create_tween()
	var beam: TeleportBeam = teleport_beam_scene.instantiate()
	
	Globals.board.movement_man.register_actor(self)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(anim_sprite, "modulate:a", 0.0, beam.anim_time)
	add_child(beam)
	beam.beam_out(func ():
		Globals.board.movement_man.unregister_actor(self)
	)

	
func _movement_finished_callback(waited: bool = false) -> void:
	super._movement_finished_callback(waited)
	await Globals.board.until_no_movement()
	Globals.board.player_movement_finished.emit(self)
	
	
func _on_shield_count_changed(value: int) -> void:
	Globals.board.player_shield_count = value
