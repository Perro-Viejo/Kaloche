# D R O P    S T A T E
extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
onready var _owner: Player = owner as Player
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func enter(msg: Dictionary = {}) -> void:
	_owner.grabbing = false

	_owner.play_animation(_owner.STATES.DROP)
	yield(_owner.sprite, 'animation_finished')

	if msg.dir.y != 0:
		if msg.dir.y == -1:
			_owner.can_grab.position.y -= 4
		else:
			_owner.can_grab.position.y += 18
	else:
		_owner.can_grab.position.y += 8
		_owner.can_grab.position.x += 12 * msg.dir.x

	(_owner.can_grab as Pickable).being_grabbed = false
	_owner.can_grab.z_index = 0
	_owner.can_grab = null

	Event.emit_signal('play_requested', 'Player', 'Drop')
	_state_machine.transition_to(_owner.STATES.IDLE)


func exit() -> void:
	_owner.play_animation()
