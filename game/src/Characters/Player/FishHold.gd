extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	owner.is_paused = true
	.enter(msg)


func exit() -> void:
	owner.is_paused = false
	.exit()
