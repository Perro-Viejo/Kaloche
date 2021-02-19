extends Node2D

export (NodePath) var _player = ''
export (NodePath) var _targetA = ''
export (NodePath) var _targetB = ''
export (NodePath) var _targetC = ''


var _was_played := false
var _player_cam_cfg := {
	pos = Vector2.ZERO,
	zoom = Vector2.ONE
}
var _player_cam: Camera2D
var _current_target 
var _prev_position := Vector2.ZERO
var _temple_button

onready var _animations: AnimationPlayer = find_node('AltarAnimations')
onready var _camera: Camera2D = find_node('AltarCamera')
onready var _tween: Tween = $Tween
onready var _targets := [
	{
		_target = get_node(_targetA),
		_time = 12,
		_trans = Tween.TRANS_LINEAR,
		_ease = Tween.EASE_OUT,
		_yield = 0
	},
	{
		_target = get_node(_targetB),
		_time = 6,
		_trans = Tween.TRANS_SINE,
		_ease = Tween.EASE_IN,
		_yield = 1
	},
	{
		_target = get_node(_targetC),
		_time = 16,
		_trans = Tween.TRANS_LINEAR,
		_ease = Tween.EASE_OUT,
		_yield = 0
	}
]

func _ready() -> void:
	_was_played = false
	_current_target = _targets.pop_front()
	#Conectarse a señales de los hijos
	_tween.connect('tween_completed', self, 'next_target')

func show_door(button_ref):
	_temple_button = button_ref
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
	_tween.interpolate_property(
		_camera, 'global_position',
		_prev_position, target._target.global_position,
		target._time, target._trans, target._ease
	)
	_tween.start()

func next_target(_object, _key) -> void:
	if _was_played == true:
		yield(get_tree().create_timer(0.3), 'timeout')
		_player_cam.position = _camera.position
		_player_cam.make_current()
		PlayerEvent.emit_signal('control_toggled', { disable_camera = true })
		queue_free()
		return
	_prev_position = _current_target._target.global_position
	if _targets.empty():
		yield(get_tree().create_timer(0.8), 'timeout')
		_temple_button.activate()
		_current_target = {
			_target = _player_cam,
			_time = 2,
			_trans = Tween.TRANS_EXPO,
			_ease = Tween.EASE_OUT,
			_yield = 3
		}
		_was_played = true
		move_camera(_current_target)
	else:
		_current_target = _targets.pop_front()
		move_camera(_current_target)
