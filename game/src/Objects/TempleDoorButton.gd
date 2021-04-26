class_name SpriteButton
extends Node2D

signal button_pressed
signal button_unpressed

export var is_toggle := true
export var needs_grabbing := true
export var pickable_needed := ''

var _pressed := false


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	$Area2D.connect('area_entered', self, '_on_pressed')
	$Area2D.connect('area_exited', self, '_on_unpressed')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func activate():
	show()
	$Area2D.monitorable = true
	$Area2D.monitoring = true


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_pressed(body: Area2D) -> void:
	if not _pressed and body.name == 'FootArea':
		var player: Player = body.get_parent()

		if needs_grabbing and player.grabbing:
			if pickable_needed == '' or player.picked_item.name == pickable_needed:
				_pressed = true
		elif needs_grabbing and not player.grabbing:
			AudioEvent.emit_signal('play_requested','Button','Block', position)
		elif not needs_grabbing:
			_pressed = true
		
		if _pressed:
			$Area2D.disconnect('area_entered', self, '_on_pressed')
#			$Area2D.connect('body_entered', self, '_on_unpressed')

			$AnimationPlayer.play('new_press')
			AudioEvent.emit_signal('play_requested','Button','Down', position)

			yield(get_tree().create_timer(0.1), 'timeout')
			emit_signal('button_pressed')


func _on_unpressed(body: Area2D) -> void:
	if not is_toggle:
		if _pressed and body.name == 'FootArea':
			_pressed = false

			$Area2D.connect('body_entered', self, '_on_pressed')
			$Area2D.disconnect('area_exited', self, '_on_unpressed')

			$AnimationPlayer.play_backwards('press')

			AudioEvent.emit_signal('play_requested','Button','Up', position)

			yield(get_tree().create_timer(0.1), 'timeout')
			emit_signal('button_unpressed')
