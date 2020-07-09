# D R O P    S T A T E
extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
onready var _owner: Player = owner
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func enter(msg: Dictionary = {}) -> void:
	_owner.grabbing = false

	var picked: Pickable = _owner.node_to_interact as Pickable
	picked.being_grabbed = false
	picked.z_index = 0

	# Retroalimentación { ======================================================
	# NOTA: si el jugador no se está moviendo, sí estaría bueno que se espere a
	# que la animación termine para hacer esto
	picked.position.y += 8
	# Que suelte lo que tiene agarrado en la dirección en la que está mirando --
	picked.position.x += 12 * (-1 if _owner.sprite.flip_h else 1)
	# --------------------------------------------------------------------------
	Event.emit_signal('play_requested', 'Player', 'Drop')
	# ======================================================================== }

	_owner.play_animation(_owner.STATES.DROP)
#	yield(_owner.sprite, 'animation_finished')

	picked = null
	_owner.node_to_interact = null

	_state_machine.transition_to(_owner.STATES.IDLE)


func exit() -> void:
	_owner.play_animation()
