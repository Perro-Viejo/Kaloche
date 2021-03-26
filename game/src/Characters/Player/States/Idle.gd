extends "res://src/StateMachine/State.gd"


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	if msg.has('fishing_failed'):
		# El gancho cayó en una superficie en la que no se puede pescar
		owner.hook_target.position = Vector2.ZERO

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


func on_tool_equiped(tool_id: int) -> void:
	match tool_id:
		owner.Tools.ROD:
			owner.play_animation('idle-rod')
		_:
			owner.play_animation('idle')
