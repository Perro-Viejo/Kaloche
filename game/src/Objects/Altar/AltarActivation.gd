extends Node2D

var _was_played := false
var _player_cam_cfg := {
	pos = Vector2.ZERO,
	zoom = Vector2.ONE
}
var _player_cam: Camera2D

onready var _animations: AnimationPlayer = find_node('AltarAnimations')
onready var _camera: Camera2D = find_node('AltarCamera')

func _ready() -> void:
	_was_played = false
	# Conectarse a señales de los hijos
#	_trigger.connect('body_entered', self, '_rocberto_found')
#	_trigger.connect('body_exited', self, '_player_leaves')

func show_door():
	_was_played = true
	_player_cam = find_node('Player').get_node('Camera2D')
	PlayerEvent.emit_signal('control_toggled', { disable_camera = true })
	_player_cam_cfg.pos = _player_cam.get_camera_screen_center()
	_player_cam_cfg.zoom = _player_cam.zoom
	_camera.global_position = _player_cam_cfg.pos
	_camera.zoom = _player_cam_cfg.zoom
	_camera.make_current()

	_animations.play('ShowDoor')

#func focus_target() -> void:
#	_camera.global_position = $Target.global_position

#func focus_player() -> void:
#	_player_cam.zoom = _camera.zoom
#	_camera.global_position = _player_cam.get_camera_screen_center()
#	yield(get_tree().create_timer(0.05), 'timeout')
#	PlayerEvent.emit_signal('camera_disabled', false)
#
#func say_hi() -> void:
#	DialogEvent.emit_signal('dialog_requested', 'RocbertoIntro')
#	DialogEvent.connect('dialog_finished', self, 'focus_player')
#
#func _rocberto_found(body: Node) -> void:
#	if _was_played: return
#
#	if body.name == 'Player':
#		_was_played = true
#
#		PlayerEvent.emit_signal('control_toggled', { disable_camera = true })
#		_player_cam = body.get_node('Camera2D')
#		_player_cam_cfg.pos = _player_cam.get_camera_screen_center()
#		_player_cam_cfg.zoom = _player_cam.zoom
#		_camera.global_position = _player_cam_cfg.pos
#		_camera.zoom = _player_cam_cfg.zoom
#		_camera.make_current()
#
#		AudioEvent.emit_signal('mx_request', 'Rocberto')
#		_animations.play('ShowRocberto')
#
#
#func _player_leaves(body: Node) -> void:
#	$Tween.interpolate_property(
#		_player_cam, 'zoom',
#		_player_cam.zoom, Vector2.ONE,
#		0.4, Tween.TRANS_EXPO, Tween.EASE_OUT
#	)
#	$Tween.start()
