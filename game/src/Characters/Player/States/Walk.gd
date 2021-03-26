extends 'res://src/StateMachine/State.gd'

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func enter(msg: Dictionary = {}) -> void:
	_parent.is_moving = true
	.enter(msg)


func play_animation() -> bool:
	if _parent.has_equiped():
		match _parent.current_tool:
			_parent.Tools.ROD:
				owner.play_animation('run-rod')
	else:
		if _parent.grabbing:
			owner.play_animation('run-grab')
		else:
			owner.play_animation('run')
	return true


func exit() -> void:
	_parent.is_moving = false
	.exit()


func on_tool_equiped(tool_id: int) -> void:
	match tool_id:
		owner.Tools.ROD:
			owner.play_animation('run-rod')
		_:
			owner.play_animation('run')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _play_fs() -> void:
	AudioEvent.emit_signal('play_requested', 'Player', 'FS_' + _parent.fs_id)

	if _parent.fs_id == 'Water':
		match _parent.foot:
			'L':
				_parent.get_node('Splash_L').set_emitting(true)
				_parent.get_node('Splash_R').restart()
				_parent.foot = 'R'
			'R':
				_parent.get_node('Splash_R').set_emitting(true)
				_parent.get_node('Splash_L').restart()
				_parent.foot = 'L'

	if _parent.has_equiped():
		AudioEvent.emit_signal('play_requested', 'Player', 'Gak_Rod')
