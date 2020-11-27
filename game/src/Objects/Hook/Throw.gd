# Se lanzó el gancho
extends "res://src/StateMachine/State.gd"

var _tween: Tween
var gravity

func _ready() -> void:
	
	_tween = Tween.new()
	add_child(_tween)
	_tween.connect('tween_completed', self, '_go_to_hold')

func enter(msg: Dictionary = {}) -> void:
	owner.thrown = true
	gravity = owner.string.gravity
	owner.string.gravity = -gravity
	_tween.interpolate_property(
		_parent, 'position',
		_parent.position, _parent.position + _parent.target_pos , .4	,
		Tween.TRANS_LINEAR, Tween.TRANS_SINE)
	_tween.start()
	_tween.interpolate_property(
		_parent, 'time',
		0, 1 , .4,
		Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	_tween.start()

func _go_to_hold(obj: Object, path: NodePath) -> void:
	# El gancho ya cayó al agua, entonces pasa al estado hold
	owner.string.gravity = gravity
	_state_machine.transition_to_key('Hold')
	owner.thrown = false
