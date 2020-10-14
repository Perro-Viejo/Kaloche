extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func play_animation() -> bool:
	if _parent.has_equiped():
		match _parent.current_tool:
			_parent.Tools.ROD:
				owner.play_animation('idle-rod')
	else:
		if _parent.grabbing:
			owner.play_animation('idle-grab')
		else:
			owner.play_animation('idle')
	return true

func exit() -> void:
	.exit()


func on_tool_equiped(tool_id: int) -> void:
	match tool_id:
		_parent.Tools.ROD:
			owner.play_animation('idle-rod')
		_:
			owner.play_animation('idle')
