extends Node2D
# ⠿⠿⠿⠿ Variables ⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿

onready var _rocberto: Pickable = find_node('Rocberto')
onready var _rocberto_trigger: Area2D = find_node('RocbertoTrigger')
onready var _rocberto_animations: AnimationPlayer = find_node('RocbertoAnimations')
onready var _rocberto_camera: Camera2D = find_node('RocbertoCamera')

# ⠿⠿⠿⠿ Functions ⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿
func _ready() -> void:
	$ParallaxForeground/ParallaxTrees.show()
	
	# Conectarse a señales de los hijos
	_rocberto_trigger.connect('body_entered', self, '_rocberto_found')

func _on_OverlayArea_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.name == 'Player':
		pass
#		$Player/AnimationPlayer.play('idle')
#		$Player/Overlay.show()


func _on_OverlayArea_body_shape_exited(body_id, body, body_shape, area_shape):
	if body.name == 'Player':
		pass
#		$Player/AnimationPlayer.stop()
#		$Player/Overlay.hide()

func _rocberto_found(body: Node) -> void:
	if body.name == 'Player':
		PlayerEvent.emit_signal('control_toggled', { disable_camera = true })
		_rocberto_camera.global_position = find_node('Player').get_node('Camera2D').global_position
		_rocberto_camera.current = true
		_rocberto_animations.play('ShowRocberto')
		AudioEvent.emit_signal('mx_request', 'Rocberto')
