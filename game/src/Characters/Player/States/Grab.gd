# G R A B    S T A T E
extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var grab_cooldown = 0.5

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func enter(msg: Dictionary = {}) -> void:
	if not _parent.node_to_interact:
		_state_machine.transition_to_state(_state_machine.STATES.IDLE)
		return

	var picked: Pickable = _parent.node_to_interact as Pickable
	_parent.grabbing = true
	picked.being_grabbed = true
	# Retroalimentación { ======================================================
	# NOTA: si el jugador no se está moviendo, sí estaría bueno que se espere a
	# que la animación termine para hacer esto
	AudioEvent.emit_signal('play_requested', 'Player', 'Grab')
	# ======================================================================== }

	picked.z_index = _parent.z_index + 1
	_state_machine.transition_to_state(_state_machine.STATES.IDLE)
