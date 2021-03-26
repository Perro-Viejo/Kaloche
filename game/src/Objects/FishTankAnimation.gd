extends Node2D

export (NodePath) var _player = ''
export (NodePath) var _targetA = ''
export (NodePath) var _targetB = ''

var _was_played := false
var _player_cam_cfg := {
	pos = Vector2.ZERO,
	zoom = Vector2.ONE
}
var _player_cam: Camera2D
var _current_target 
var _prev_position := Vector2.ZERO
var _rod_temple: Node2D
var _is_camera_shaking := false
var _camera_shake_amount := 15.0
var _shake_timer := 0.0

onready var _animations: AnimationPlayer = find_node('FishTankAnimations')
onready var _camera: Camera2D = find_node('FishTankCamera')
onready var _tween: Tween = $Tween
onready var _targets := [
	{
		_target = get_node(_targetA),
		_time = 4,
		_trans = Tween.TRANS_LINEAR,
		_ease = Tween.EASE_OUT,
		_yield = 0
	},
	{
		_target = get_node(_targetB),
		_time = 3,
		_trans = Tween.TRANS_QUAD,
		_ease = Tween.EASE_OUT,
		_yield = 0
	},
]


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	_was_played = false
	_current_target = _targets.pop_front()
	#Conectarse a señales de los hijos
	_tween.connect('tween_completed', self, 'next_target')


func _process(delta) -> void:
	if _is_camera_shaking:
		_shake_timer -= delta
		_camera.offset = Vector2(
			rand_range(-1.0, 1.0) * _camera_shake_amount,
			rand_range(-1.0, 1.0) * _camera_shake_amount
		)

		if _shake_timer <= 0.0:
			_is_camera_shaking = false
			_camera.offset = Vector2.ZERO


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func reveal_rod(rod_temple_ref: Node2D):
	_rod_temple = rod_temple_ref
	_player_cam = get_node(_player).get_node('Camera2D')
	PlayerEvent.emit_signal('control_toggled', { disable_camera = true })
	_player_cam_cfg.pos = _player_cam.get_camera_screen_center()
	_player_cam_cfg.zoom = _player_cam.zoom
	_camera.global_position = _player_cam_cfg.pos
	_camera.zoom = _player_cam_cfg.zoom
	_camera.make_current()
	_prev_position = _camera.global_position
	yield(get_tree().create_timer(0.6), 'timeout')
	move_camera(_current_target)


func move_camera(target) -> void:
	yield(get_tree().create_timer(target._yield), 'timeout')
	if target._target.name == 'TargetA':
		yield(get_tree().create_timer(1.7), 'timeout')
		AudioEvent.emit_signal('play_requested', 'TempleRod', 'Whoosh')
	_tween.interpolate_property(
		_camera, 'global_position',
		_prev_position, target._target.global_position,
		target._time, target._trans, target._ease
	)
	_tween.start()
	if _was_played:
		_tween.interpolate_property(
			_camera, 'zoom',
			Vector2(0.7,0.7), _player_cam_cfg.zoom,
			2, Tween.TRANS_EXPO, Tween.EASE_IN
		)
		yield(get_tree().create_timer(2), 'timeout')
		AudioEvent.emit_signal('mx_request', 'RodTemple')


func next_target(_object, key) -> void:
	if key == ':zoom': return
	if _was_played == true:
		_tween.disconnect('tween_completed', self, 'next_target')
		yield(get_tree().create_timer(0.3), 'timeout')
		_player_cam.position = _camera.position
		_player_cam.make_current()
		_tween.start()
		PlayerEvent.emit_signal('control_toggled', { disable_camera = true })
		queue_free()
	_prev_position = _current_target._target.global_position
	if _targets.empty():
		_tween.interpolate_property(
			_camera, 'zoom',
			Vector2.ONE, Vector2(0.7,0.7),
			4.8, Tween.TRANS_LINEAR, Tween.EASE_OUT
		)
		_tween.start()
		yield(get_tree().create_timer(0.7), 'timeout')
		AudioEvent.emit_signal('play_requested', 'TempleRod', 'Emerge')
		yield(get_tree().create_timer(0.1), 'timeout')
		_rod_temple.emerge()
		_shake_camera(
		{
			strength = 1.5,
			duration = 7.5,
		})
		_current_target = {
			_target = _player_cam,
			_time = _rod_temple.get_emerge_animation_length(),
			_trans = Tween.TRANS_EXPO,
			_ease = Tween.EASE_OUT,
			_yield = _rod_temple.get_emerge_animation_length()
		}
		_was_played = true
		move_camera(_current_target)
	else:
		_current_target = _targets.pop_front()
		move_camera(_current_target)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _shake_camera(props: Dictionary) -> void:
	if props.has('strength'):
		_camera_shake_amount = props.strength
	if props.has('duration'):
		_shake_timer = props.duration
	_is_camera_shaking = true
