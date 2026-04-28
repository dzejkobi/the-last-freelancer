class_name OffScreenChar extends Node2D

enum STATE {
	UNKNOWN = 0,
	WAITING = 1,
	SHOWING = 2,
	OBSERVING = 3,
	COOLDOWN = 4,
	HIDING = 5
}

enum BORDER {
	NONE = 0,
	LEFT = 1,
	RIGHT = 2,
	BOTTOM = 3
}

const BulletScene = preload("res://interludes/dynamic_bg/off_screen_bullet.tscn")

@export var color_name: String = "recruiter_color"
@export var is_enemy: bool = true
@export var anim_time: float = 0.5
@export var observing_time: float = 2.0
@export var waiting_time: float = 2.0
@export var cooldown_time: float = 0.5
@export var time_variance: float = 0.3
@export var anim_sprite: AnimatedSprite2D
@export var shoot_interval: float = 0.2

@onready var screen: BGScreen = get_parent()

var state: STATE
var start_pos: Vector2
var end_pos: Vector2
var full_size: Vector2 = Vector2.ZERO
var state_timer: SceneTreeTimer
var last_border: BORDER = BORDER.NONE
var time_until_shoot: float = 0.0


func get_full_size() -> Vector2:
	var tex := anim_sprite.sprite_frames\
		.get_frame_texture(anim_sprite.animation, anim_sprite.frame)
	return tex.get_size() * anim_sprite.scale


func _ready() -> void:
	full_size = get_full_size()
	if color_name:
		anim_sprite.modulate = Colors.get(color_name)
	start_waiting(randf_range(0.0, waiting_time * 2))


func shoot(enemy: OffScreenChar) -> void:
	var bullet: OffScreenBullet = BulletScene.instantiate()
	bullet.setup(position, Colors.get(color_name))
	screen.add_child(bullet)
	Sounds.laser.play({
		"global_position": bullet.global_position,
		"volume": 0.2, 
		"pitch_scale": 0.8,
		"pitch_scale_variancy": 0.4
	})
	
	var timer := get_tree().create_timer(0.4 * bullet.move_to(enemy.position))
	timer.timeout.connect(enemy.start_hiding)


func _process(delta: float) -> void:
	if state == STATE.OBSERVING:
		time_until_shoot -= delta
		if time_until_shoot <= 0:
			var enemy: OffScreenChar = screen.search_for_enemy(self)
			if not enemy:
				time_until_shoot = shoot_interval
			else:
				shoot(enemy)
				start_cooldown()
		


func _start_state(
	_state: STATE, _time: float, _callback: Callable, force: bool = false
) -> float:
	var state_time: float = randf_range(
		_time - time_variance, _time + time_variance
	)
	if _state <= state and not force:
		# We only want to progres to the further states
		return -1.0
	state = _state
	state_timer = get_tree().create_timer(state_time)
	state_timer.timeout.connect(_callback)
	return state_time


func start_waiting(_waiting_time: float = waiting_time) -> void:
	_start_state(STATE.WAITING, _waiting_time, start_showing, true)
	
	
func start_showing() -> void:
	var border := screen.get_free_border(self)
	
	if border != BORDER.NONE:
		var state_time := \
			_start_state(STATE.SHOWING, anim_time, start_observing)
		if state_time < 0:
			return
		setup(border)
		last_border = border
		screen.char_map[border] = self
		var tween := self.create_tween()
		tween.tween_property(self, "position", end_pos, state_time)
	else:
		start_waiting()
	
	
func start_observing() -> void:
	time_until_shoot = shoot_interval
	_start_state(STATE.OBSERVING, observing_time, start_hiding)


func start_cooldown() -> void:
	_start_state(STATE.COOLDOWN, cooldown_time, start_hiding)

	
func start_hiding() -> void:
	var state_time := _start_state(
		STATE.HIDING,
		anim_time,
		start_waiting
	)
	
	screen.char_map[last_border] = null
	if state_time < 0:
		return
	
	var tween := self.create_tween()
	tween.tween_property(self, "position", start_pos, state_time)


func _set_rotation() -> void:
	if position.x < 0.33 * screen.size.x:
		anim_sprite.rotation = deg_to_rad(10.0)
	elif position.x < 0.66 * screen.size.x:
		anim_sprite.rotation = 0.0
	else:
		anim_sprite.rotation = -deg_to_rad(10.0)


func setup(where: BORDER) -> void:
	assert(
		full_size != Vector2.ZERO,
		"OffScreenChar's full_size hasn't yet been set."
	)
	match where:
		BORDER.LEFT:
			start_pos = Vector2(
				0 - full_size.x,
				randf_range(2 * full_size.y, screen.size.y - full_size.y)
			)
			end_pos = Vector2(
				start_pos.x + 1.1 * full_size.x,
				start_pos.y
			)
		BORDER.RIGHT:
			start_pos = Vector2(
				screen.size.x + full_size.x,
				randf_range(2 * full_size.y, screen.size.y - full_size.y)
			)
			end_pos = Vector2(
				start_pos.x - 1.1 * full_size.x,
				start_pos.y
			)
		BORDER.BOTTOM:
			start_pos = Vector2(
				randf_range(full_size.x, screen.size.x - 2 * full_size.x),
				screen.size.y + full_size.y
			)
			end_pos = Vector2(
				start_pos.x,
				start_pos.y - 1.2 * full_size.y
			)
	
	position = start_pos
	_set_rotation()
