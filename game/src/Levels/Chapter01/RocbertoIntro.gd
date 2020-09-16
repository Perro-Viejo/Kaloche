extends Node2D

var _was_played := false

onready var _rocberto_trigger: Area2D = find_node('RocbertoTrigger')
onready var _rocberto_animations: AnimationPlayer = find_node('RocbertoAnimations')
onready var _rocberto_camera: Camera2D = find_node('RocbertoCamera')

func _ready() -> void:
	# Conectarse a señales de los hijos
	_rocberto_trigger.connect('body_entered', self, '_rocberto_found')

func focus_rocberto() -> void:
	# TODO: Que esto no busque al nodo en el padre sino que lo reciba y lo tenga
	# como propiedad pa' usarlo cuando quiera
	_rocberto_camera.global_position = get_parent().get_node('Rocberto').global_position

func focus_player() -> void:
	PlayerEvent.emit_signal('camera_disabled', false)

func say_hi() -> void:
	DialogEvent.emit_signal('dialog_requested', 'RocbertoIntro')
	DialogEvent.connect('dialog_finished', self, 'focus_player')

func _rocberto_found(body: Node) -> void:
	if _was_played: return
	
	if body.name == 'Player':
		_was_played = true
		
		PlayerEvent.emit_signal('control_toggled', { disable_camera = true })
		var _player_camera: Camera2D = body.get_node('Camera2D')
		_rocberto_camera.global_position = _player_camera.get_camera_screen_center()
		_rocberto_camera.zoom = _player_camera.zoom
		_rocberto_camera.make_current()

		AudioEvent.emit_signal('mx_request', 'Rocberto')
		_rocberto_animations.play('ShowRocberto')
