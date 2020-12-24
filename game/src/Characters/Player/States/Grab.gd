# G R A B    S T A T E
extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var grab_cooldown = 0.5

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func enter(msg: Dictionary = {}) -> void:
	if not owner.node_to_interact:
		_state_machine.transition_to_state(_state_machine.STATES.IDLE)
		return

	var picked: Pickable = owner.node_to_interact as Pickable
	owner.grabbing = true
	owner.picked_item = picked
	picked.being_grabbed = true
	picked.z_index = owner.z_index + 1
	
	# Retroalimentación { ======================================================
	# NOTA: si el jugador no se está moviendo, sí estaría bueno que se espere a
	# que la animación termine para hacer esto
	AudioEvent.emit_signal('play_requested', 'Player', 'Grab')
	# ======================================================================== }

	_state_machine.transition_to_state(
		_state_machine.STATES.IDLE,
		{ pickup = true } if picked.is_in_group('Pickup') else {}
	)
