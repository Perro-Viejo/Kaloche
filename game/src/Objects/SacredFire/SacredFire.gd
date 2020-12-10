extends Node2D

export var lifepoints:= 10
export var max_lifepoints:= 20
export var can_die:= true
export var size_range:= Vector2(0.5, 1)

var pickable: Pickable = null
var is_burning:= false

onready var sprite := $Sprite
onready var timer := $Timer
onready var tween := $Tween
onready var feed_area := $FeedArea

func _ready():
	scale = Vector2.ONE * range_lerp(lifepoints, 0, max_lifepoints, size_range.x, size_range.y)
	feed_area.connect('area_entered', self, '_on_area_entered')
	feed_area.connect('area_exited', self, '_on_area_exited')
	timer.connect('timeout', self, '_on_timer_timeout')
	if can_die:
		timer.start()

func _on_area_entered(other) -> void:
	if other.is_in_group('Pickable') and not (other as Pickable).being_grabbed:
		pickable = other as Pickable
		print('tengo ', pickable.name, ' en mi llamaje')
		pickable.set_z_index(-1)
		$StateMachine.transition_to_state($StateMachine.STATES.BURN)

func _on_area_exited(other) -> void:
	if other.is_in_group('Pickable') and other.being_grabbed:
		print('me sacaron el ', pickable.name)
		pickable = null
		$StateMachine.transition_to_state($StateMachine.STATES.IDLE)

func _on_timer_timeout():
	print(lifepoints)
	if can_die:
		if lifepoints > 0:
			lifepoints -= 1
			scale = Vector2.ONE * range_lerp(lifepoints, 0, max_lifepoints, size_range.x, size_range.y)
		else:
			$Timer.stop()
			$StateMachine.transition_to_state($StateMachine.STATES.DIE)

func eat():
	print('Me comi el ', pickable.name)
	if pickable.is_in_group('Sacred'):
		lifepoints = max_lifepoints
	else:
		if pickable.is_good:
			if not lifepoints + pickable.carbs > max_lifepoints:
				lifepoints = lifepoints + pickable.carbs
			else:
				lifepoints = max_lifepoints
		else:
			if not lifepoints - pickable.carbs < 0:
				lifepoints = lifepoints - pickable.carbs
			else:
				lifepoints = 0
	pickable.queue_free()
	pickable = null
	$StateMachine.transition_to_state($StateMachine.STATES.IDLE)
