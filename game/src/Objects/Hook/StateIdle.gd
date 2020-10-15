# El gancho está colgando en el aire (el jugador está en Prepare) y esperando
# a ser lanzado
extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	owner.target_set = false


func exit() -> void:
	owner.target_set = false


func physics_process(delta: float) -> void:
	if owner.target_set:
		_state_machine.transition_to_key('Throw')
