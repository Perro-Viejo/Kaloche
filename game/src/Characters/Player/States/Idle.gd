extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func play_animation() -> bool:
	if _parent.has_equiped():
		match _parent.current_tool:
			_parent.Tools.ROD:
				$AnimatedSprite.play('IdleRod')
	else:
		if _parent.grabbing:
			$AnimatedSprite.play('IdleGrab')
		elif _parent.fishing:
			$AnimatedSprite.play('IdleFish')
		else:
			$AnimatedSprite.play('Idle')
	return true

func exit() -> void:
	.exit()


func on_tool_equiped(tool_id: int) -> void:
	match tool_id:
		_parent.Tools.ROD:
			$AnimatedSprite.play('IdleRod')
		_:
			$AnimatedSprite.play('Idle')
