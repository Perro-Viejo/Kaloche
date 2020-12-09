extends Node2D

var pickable: Pickable = null
var is_burning:= false

onready var sprite := $Sprite
onready var feed_area := $FeedArea
onready var timer := $Timer

func _ready():
	feed_area.connect('area_entered', self, '_on_area_entered')
	feed_area.connect('area_exited', self, '_on_area_exited')

func _on_area_entered(other) -> void:
	if other.is_in_group('Pickable') and not (other as Pickable).being_grabbed:
		pickable = other as Pickable
		print('tengo ', pickable.name, ' en mi llamaje')
		pickable.set_z_index(-1)
		$StateMachine.transition_to_state($StateMachine.STATES.BURN)
#		eat(pickable.is_good, pickable.carbs, pickable.name, sacred)

func _on_area_exited(other) -> void:
	if other.is_in_group('Pickable') and other.being_grabbed:
		print('me sacaron el ', pickable.name)
		pickable = null
#		feed_area.set_deferred('monitoring', true)
#		feed_area.set_deferred('monitorable', true)
		$StateMachine.transition_to_state($StateMachine.STATES.IDLE)

func eat():
	print('Me comi el ', pickable.name)
	pickable.queue_free()
	pickable = null
	$StateMachine.transition_to_state($StateMachine.STATES.IDLE)
