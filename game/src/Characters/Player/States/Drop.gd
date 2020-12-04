# D R O P    S T A T E
extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	owner.grabbing = false

	var picked: Pickable = owner.node_to_interact as Pickable
	picked.being_grabbed = false
	_parent.picked_item = null
	picked.z_index = 0

	# Retroalimentación { ======================================================
	# NOTA: si el jugador no se está moviendo, sí estaría bueno que se espere a
	# que la animación termine para hacer esto
	picked.position.y += 8
	# Que suelte lo que tiene agarrado en la dirección en la que está mirando --
	picked.position.x += 12 * (-1 if owner.sprite.flip_h else 1)
	# --------------------------------------------------------------------------
	AudioEvent.emit_signal('play_requested', 'Player', 'Drop')
	# ======================================================================== }

	picked = null
	owner.node_to_interact = null

	_state_machine.transition_to_state(_state_machine.STATES.IDLE)
