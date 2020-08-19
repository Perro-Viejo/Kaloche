extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	_parent.is_moving = true
	.enter(msg)

func play_animation() -> bool:
	if _parent.grabbing:
		sprite.play('WalkGrab')
	else:
		sprite.play('Walk')
	return true
	
func exit() -> void:
	_parent.is_moving = false
	.exit()

