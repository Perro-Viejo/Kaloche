extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	_parent.is_moving = true
	.enter(msg)

func play_animation() -> bool:
	if _parent.grabbing:
		sprite.play('WalkGrab')
	elif _parent.fishing:
		sprite.play('WalkFish')
	else:
		sprite.play('Walk')
	return true
	
func exit() -> void:
	_parent.is_moving = false
	.exit()
