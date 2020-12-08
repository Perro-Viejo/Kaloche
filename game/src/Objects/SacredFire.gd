extends Node2D

var pickable: Pickable = null

onready var sprite := $Sprite

func _ready():
	$FeedArea.connect('area_entered', self, '_on_area_entered')

func _on_area_entered(other) -> void:
	if other.is_in_group('Pickable') and not (other as Pickable).being_grabbed:
		pickable = other as Pickable
		print('tengo ', pickable.name, ' en mi llamaje')
		$FeedArea.set_deferred('monitoring', false)
		$FeedArea.set_deferred('monitorable', false)
		AudioEvent.emit_signal('play_requested','Demon', 'Burn')
		AudioEvent.emit_signal('play_requested','Demon', 'Ignite')
		pickable.set_z_index(-1)
#		yield(get_tree().create_timer(3), 'timeout')
#		pickable.queue_free()
#		AudioEvent.emit_signal('stop_requested','Demon', 'Burn')
#		eat(pickable.is_good, pickable.carbs, pickable.name, sacred)
