# El gancho está colgando en el aire (el jugador está en Prepare) y esperando
# a ser lanzado
extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	pass


func physics_process(delta: float) -> void:
	if _parent.target_pos:
		_state_machine.transition_to_key('Throw')
