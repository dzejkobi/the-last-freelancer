class_name Tank extends Actor


static func get_dir_name(_direction: Vector2i) -> String:
	match _direction:
		Vector2i.UP:
			return "up"
		Vector2i.RIGHT:
			return "right"
		Vector2i.DOWN:
			return "down"
		Vector2i.LEFT:
			return "left"
		_:
			push_error('Unknown direction vector "%s".' % _direction)
			return ""


func _movement_finished_callback() -> void:
	anim_sprite.play("idle_%s" % get_dir_name(direction))
	position = Grid.grid_pos_to_pos(grid_pos)
	is_moving = false
	Globals.board.movement_man.unregister_actor(self)


func play_movement_animation() -> void:
	anim_sprite.play("moving_%s" % get_dir_name(direction))


func find_enemies_in_range() -> Array[Actor]:
	var player = Globals.board.player
	
	if (grid_pos.x == player.grid_pos.x or grid_pos.y == player.grid_pos.y):
		return [player]
	else:
		return []
		
		
func shoot(target: Actor) -> void:
	var timer := get_tree().create_timer(0.4 * movement_time)
	var player: Player = Globals.board.player
	
	timer.timeout.connect(func ():
		var dir_name: String
		if grid_pos.x == player.grid_pos.x:
			direction = Vector2i.DOWN if grid_pos.y < player.grid_pos.y \
				else Vector2i.UP
		elif grid_pos.y == player.grid_pos.y:
			direction = Vector2i.RIGHT if grid_pos.x < player.grid_pos.x \
				else Vector2i.LEFT
		dir_name = get_dir_name(direction)
		if prev_grid_pos == grid_pos:
			anim_sprite.play("idle_%s" % dir_name)
		else:
			anim_sprite.play("moving_%s" % dir_name)
		super.shoot(target)
	)
