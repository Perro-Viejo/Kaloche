# El gancho está colgando en el aire (el jugador está en Prepare) y esperando
# a ser lanzado
extends "res://src/StateMachine/State.gd"


func enter(msg: Dictionary = {}) -> void:
	owner.target_set = false
	owner.position = owner.dflt_pos
	owner.show_hook(false)


func exit() -> void:
	owner.target_set = false
	owner.show_hook(true)


func physics_process(delta: float) -> void:
	if owner.target_set:
		_state_machine.transition_to_key('Throw')
