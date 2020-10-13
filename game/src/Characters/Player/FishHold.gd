extends "res://src/StateMachine/State.gd"

func play_animation() -> bool:
	sprite.play('default')
	return true
