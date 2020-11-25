# Se lanzó el gancho
extends "res://src/StateMachine/State.gd"

var _tween: Tween

func _ready() -> void:
	_tween = Tween.new()
	add_child(_tween)
	_tween.connect('tween_completed', self, '_go_to_hold')

func enter(msg: Dictionary = {}) -> void:
	_tween.interpolate_property(
		_parent, 'position',
		_parent.position, _parent.position + _parent.target_pos , .8,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.start()
#	get_node('../../RigidBody2D').apply_impulse(owner.position, Vector2(150, -40))
#	get_node('../../RigidBody2D').gravity_scale = 1

func _go_to_hold(obj: Object, path: NodePath) -> void:
	# El gancho ya cayó al agua, entonces pasa al estado hold
	_state_machine.transition_to_key('Hold')
