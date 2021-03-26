extends Node2D

var _speed_modifier := 2.0


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func open() -> void:
	$AnimationPlayer.play('open', -1, 1 / _speed_modifier)
	AudioEvent.emit_signal('play_requested', 'Temple', 'Door_Open')
	PlayerEvent.emit_signal(
		'camera_shook',
		{
			strength = 1.2,
			duration = $AnimationPlayer.current_animation_length * _speed_modifier,
			remove_control = true
		}
	)
	PlayerEvent.emit_signal('camera_moved', Vector2(0.0, -60.0))
	yield($AnimationPlayer, 'animation_finished')
	$StaticBody2D.queue_free()
	PlayerEvent.emit_signal('camera_moved', Vector2(0.0, 60.0))
	PlayerEvent.emit_signal('control_toggled')
