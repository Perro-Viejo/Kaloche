class_name TempleEntrance
extends Node2D
# Controla lo que ocurre con la entrada al templo, desde su estado no activado
# hasta que se abre la puerta.

signal activated

export var zoom_on_enter := true

onready var door_button: SpriteButton = find_node('DoorButton')
onready var _main_collider: Area2D = $MainCollider


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
#	$AnimationPlayer.play('SETUP_ACTIVATE')
	
	door_button.connect('button_pressed', self, '_open_door')
	_main_collider.connect('area_entered', self, '_check_entered', [true])
	_main_collider.connect('area_exited', self, '_check_entered', [false])
	
	WorldEvent.connect('world_entered', self, '_start_vfx')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func activate() -> void:
	$AnimationPlayer.play('Activate', -1, 0.5)


func temple_activated() -> void:
	emit_signal('activated')


func start_front_pyramids() -> void:
	$Fires.start_front_pyramids()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _open_door() -> void:
	PlayerEvent.emit_signal('control_toggled', {is_cutscene = true})
	yield(get_tree().create_timer(0.8), 'timeout')
	$AnimationPlayer.play('SETUP_OPEN_DOOR')
	yield($AnimationPlayer, 'animation_finished')
	yield(get_tree(), 'idle_frame')
	$AnimationPlayer.play('OpenDoor')
	yield($AnimationPlayer, 'animation_finished')
	PlayerEvent.emit_signal('control_toggled')
	DialogEvent.emit_signal('dialog_requested', 'Chapter0.1/DTempleEntrance', 'door_open')


func _check_entered(body: Area2D, entered: bool) -> void:
	if zoom_on_enter and body.name == 'FootArea':
		var player_cam: Camera2D = (body.get_parent() as Player).cam
		
		$Tween.interpolate_property(
			player_cam, 'zoom',
			Vector2.ONE * (1.0 if entered else 2.0),
			Vector2.ONE * (2.0 if entered else 1.0),
			1.0, Tween.TRANS_EXPO, Tween.EASE_OUT
			
		)
		$Tween.start()
		player_cam.offset.y = -100.0 if entered else 0.0


func _start_vfx(_data: Dictionary) -> void:
	pass
