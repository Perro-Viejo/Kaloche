# F I S H    S T A T E
extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	_state_machine.transition_to_key('Fish/Prepare')
#	_parent.fishing_spot.start_fishing()
	
func exit() -> void:
	_parent.fishing = false
#	_parent.fishing_spot.stop()
