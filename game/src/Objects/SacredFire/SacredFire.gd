extends Node2D
# Controla lo que pasa con los fuegos sagrados que pueden consumir objetos y
# dependen de ellos para mantenerse con vida, o ser más fuertes. Es el fuego
# base para Kaloche.

export var lifepoints:= 10
export var max_lifepoints:= 20
export var can_die:= true
export var size_range:= Vector2(0.5, 1)
export (NodePath) var external_position = null

var pickable: Pickable = null
var is_burning:= false
var reject_position

onready var sprite := $Sprite
onready var timer := $Timer
onready var tween := $Tween
onready var feed_area := $FeedArea

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	if external_position == null:
		reject_position = $RejectPosition
	else:
		reject_position = get_node(external_position)
	scale = Vector2.ONE * range_lerp(lifepoints, 0, max_lifepoints, size_range.x, size_range.y)
	feed_area.connect('area_entered', self, '_on_area_entered')
	feed_area.connect('area_exited', self, '_on_area_exited')
	timer.connect('timeout', self, '_on_timer_timeout')
	if can_die:
		timer.start()


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func eat():
	print('Me comi el ', pickable.name)
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
	_destroy_pickable()


func eat_sacred():
#	lifepoints = max_lifepoints
	match pickable.name:
		'Rocberto':
			var rocberto = pickable
			pickable = null
			rocberto.set_z_index(0)
			tween.interpolate_property(
				rocberto, 'global_position',
				rocberto.global_position, global_position + Vector2(0, -200), 0.2,
				Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
			tween.start()
			AudioEvent.emit_signal('play_requested', 'SacredFire', 'Rocberto_Reject', rocberto.global_position)
			$StateMachine.transition_to_state($StateMachine.STATES.IDLE)
			yield(get_tree().create_timer(0.7), 'timeout')
			AudioEvent.emit_signal('play_requested', 'SacredFire', 'Rocberto_Fall', reject_position.global_position)
			yield(get_tree().create_timer(0.4), 'timeout')
			rocberto.global_position.x = reject_position.global_position.x
			tween.interpolate_property(
				rocberto, 'global_position',
				rocberto.global_position, reject_position.global_position, 0.2,
				Tween.TRANS_EXPO, Tween.TRANS_LINEAR)
			tween.start()
			yield(tween, 'tween_completed')
			PlayerEvent.emit_signal('camera_shaked', 
			{
				strength = 1.6,
				duration = 0.2,
			})
			AudioEvent.emit_signal('play_requested', 'SacredFire', 'Rocberto_Impact', reject_position.global_position)
		
		_:
			print('no sé que es pero lo toco jesusito')
			_destroy_pickable()


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_area_entered(other) -> void:
	if other.is_in_group('Pickable') and not (other as Pickable).being_grabbed:
		if is_burning:
			_reject_pickable(other)
		else:
			pickable = other as Pickable
			if pickable.is_good and lifepoints + pickable.carbs >= max_lifepoints:
				_reject_pickable(pickable)
			else:
				print('tengo ', pickable.name, ' en mi llamaje')
				pickable.set_z_index(-1)
				$StateMachine.transition_to_state($StateMachine.STATES.BURN)


func _on_area_exited(other) -> void:
	if other.is_in_group('Pickable') and other.being_grabbed:
		print('me sacaron el ', pickable.name)
		pickable = null
		$StateMachine.transition_to_state($StateMachine.STATES.IDLE)


func _on_timer_timeout():
	if can_die:
		if lifepoints > 0:
			lifepoints -= 1
			scale = Vector2.ONE * range_lerp(lifepoints, 0, max_lifepoints, size_range.x, size_range.y)
		else:
			$Timer.stop()
			$StateMachine.transition_to_state($StateMachine.STATES.DIE)


func _reject_pickable(_pickable):
	_pickable.set_z_index(0)
	tween.interpolate_property(
		_pickable, 'global_position',
		_pickable.global_position, reject_position.global_position,0.1,
		Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	tween.start()
	if _pickable == pickable:
		pickable = null
		$StateMachine.transition_to_state($StateMachine.STATES.IDLE)


func _destroy_pickable():
	WorldEvent.emit_signal('pickable_burnt', pickable)
	pickable.queue_free()
	pickable = null
	$StateMachine.transition_to_state($StateMachine.STATES.IDLE)
