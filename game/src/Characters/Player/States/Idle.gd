extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	if msg.has('pickup'):
		yield(owner.pickup_item(), 'completed')
		play_animation()

func play_animation() -> bool:
	if owner.has_equiped():
		match owner.current_tool:
			owner.Tools.ROD:
				owner.play_animation('idle-rod')
	else:
		if owner.grabbing:
			owner.play_animation('idle-grab')
		else:
			owner.play_animation('idle')
	return true

func exit() -> void:
	.exit()


func on_tool_equiped(tool_id: int) -> void:
	match tool_id:
		owner.Tools.ROD:
			owner.play_animation('idle-rod')
		_:
			owner.play_animation('idle')
