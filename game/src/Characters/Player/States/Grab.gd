# G R A B    S T A T E
extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var grab_cooldown = 0.5

onready var _owner: Player = owner as Player
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func enter(msg: Dictionary = {}) -> void:
	if not _owner.can_grab:
		_state_machine.transition_to(_owner.STATES.IDLE)
		return

	_owner.play_animation(_owner.STATES.GRAB)
	yield(_owner.sprite, 'animation_finished')

	_owner.can_grab.z_index = _owner.z_index + 1
	_owner.grabbing = true
	(_owner.can_grab as Pickable).being_grabbed = true
	Event.emit_signal('play_requested', 'Player', 'Grab')
