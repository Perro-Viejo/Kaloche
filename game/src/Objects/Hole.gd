extends Node2D

func _ready():
	$Area2D.connect('area_entered', self, '_on_area_entered')
	

func _on_area_entered(other) -> void:
	if other is Pickable:
		other.hide()
		AudioEvent.emit_signal('play_requested', 'Hole', 'Fall')
		if other.is_in_group('Sacred'):
			yield(get_tree().create_timer(1.9), 'timeout')
			other.respawn($Respawn.global_position)
			if other.name == 'Rocberto':
				AudioEvent.emit_signal('play_requested', 'Rocberto', 'Respawn')
		else:
			other.queue_free()
