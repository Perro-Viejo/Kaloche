extends Node2D

func _ready():
	$Area2D.connect('area_entered', self, '_on_area_entered')
	

func _on_area_entered(other) -> void:
	if other is Pickable:
		if other.is_in_group('Sacred'):
			other.hide()
			yield(get_tree().create_timer(1.5), 'timeout')
			other.respawn($Respawn.global_position)
		else:
			other.queue_free()
