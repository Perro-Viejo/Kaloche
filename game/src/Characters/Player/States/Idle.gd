extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func play_animation() -> bool:
	if _parent.grabbing:
		$AnimatedSprite.play('IdleGrab')
	elif _parent.fishing:
		$AnimatedSprite.play('IdleFish')
	else:
		$AnimatedSprite.play('Idle')
	return true

func exit() -> void:
	.exit()
