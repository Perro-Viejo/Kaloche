class_name TempleEntrance
extends Node2D
# Controla lo que ocurre con la entrada al templo, desde su estado no activado
# hasta que se abre la puerta.

signal activated

onready var door_button: SpriteButton = find_node('DoorButton')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	door_button.connect('button_pressed', self, '_open_door')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func activate() -> void:
	$AnimationPlayer.play('Activate')


func temple_activated() -> void:
	emit_signal('activated')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _open_door() -> void:
	$AnimationPlayer.play('SETUP_OPEN_DOOR')
	yield($AnimationPlayer, 'animation_finished')
	yield(get_tree(), 'idle_frame')
	$AnimationPlayer.play('OpenDoor')
