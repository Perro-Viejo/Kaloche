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

	var picked: Pickable = _owner.can_grab as Pickable
	_owner.grabbing = true
	picked.being_grabbed = true
	# Retroalimentación { ======================================================
	# NOTA: si el jugador no se está moviendo, sí estaría bueno que se espere a
	# que la animación termine para hacer esto
	Event.emit_signal('play_requested', 'Player', 'Grab')
	# ======================================================================== }

	_owner.play_animation(_owner.STATES.GRAB)
#	yield(_owner.sprite, 'animation_finished')

	picked.z_index = _owner.z_index + 1

	_state_machine.transition_to(_owner.STATES.IDLE)


func exit() -> void:
	_owner.play_animation()
