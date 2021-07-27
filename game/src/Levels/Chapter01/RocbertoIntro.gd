extends Node2D

export var rocberto: NodePath

var _was_played := false
var _player_cam_cfg := {
	pos = Vector2.ZERO,
	zoom = Vector2.ONE
}
var _player_cam: Camera2D

onready var _trigger: Area2D = find_node('RocbertoTrigger')
onready var _rocberto_block: Area2D = find_node('RocbertoBlock')
onready var _animations: AnimationPlayer = find_node('RocbertoAnimations')
onready var _camera: Camera2D = find_node('RocbertoCamera')

func _ready() -> void:
	_was_played = false
	
	# Conectarse a señales de los hijos
	_trigger.connect('body_entered', self, '_rocberto_found')
	_trigger.connect('body_exited', self, '_player_leaves')

func focus_rocberto() -> void:
	_camera.global_position = get_node(rocberto).global_position


func focus_player() -> void:
	_player_cam.zoom = _camera.zoom
	_camera.global_position = _player_cam.get_camera_screen_center()
	yield(get_tree().create_timer(0.05), 'timeout')
	PlayerEvent.emit_signal('camera_disabled', false)


func say_hi() -> void:
#	DialogEvent.emit_signal('dialog_requested', 'RocbertoIntro')
	DialogEvent.emit_signal(
		'dialog_requested', 'Chapter0.1/DRocbertoIntro', 'start_conversation'
	)

	DialogEvent.connect('dialog_finished', self, 'focus_player')


func _rocberto_found(body: Node) -> void:
	if _was_played: return
	
	if body.name == 'Player':
		_was_played = true
		_rocberto_block.active = true

		PlayerEvent.emit_signal('control_toggled', { disable_camera = true })
		_player_cam = body.get_node('Camera2D')
		_player_cam_cfg.pos = _player_cam.get_camera_screen_center()
		_player_cam_cfg.zoom = _player_cam.zoom
		_camera.global_position = _player_cam_cfg.pos
		_camera.zoom = _player_cam_cfg.zoom
		_camera.make_current()

		AudioEvent.emit_signal('mx_request', 'Rocberto')
		_animations.play('ShowRocberto')


func _player_leaves(body: Node) -> void:
	if DialogEvent.is_connected('dialog_finished', self, 'focus_player'):
		DialogEvent.disconnect('dialog_finished', self, 'focus_player')
	if _player_cam != null:
		$Tween.interpolate_property(
			_player_cam, 'zoom',
			_player_cam.zoom, Vector2.ONE,
			0.4, Tween.TRANS_EXPO, Tween.EASE_OUT
		)
		$Tween.start()



# SenderoIniciación.tres
# func despertar() -> void:
# DialogEvent.run(['Player: asdjaldkjas	'], 'completed')
#
# func derrumbe() -> void:
# DialogEvent.run(['Player(sad): Uy... que sueño tan raro'], 'completed')

# func reacción() -> void:
# DialogEvent.run([reacciones[rnd]], 'completed')
