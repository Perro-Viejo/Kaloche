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
		_parent.position, _parent.position + _parent.target_pos , 1.2,
		Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	_tween.start()
	AudioEvent.emit_signal('play_requested', 'Fishing', 'rod_throw')

func _go_to_hold(obj: Object, path: NodePath) -> void:
	# El gancho ya cayó al agua, entonces pasa al estado hold
	_state_machine.transition_to_key('Hold')
