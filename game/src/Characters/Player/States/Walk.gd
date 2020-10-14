extends 'res://src/StateMachine/State.gd'

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
#func _ready() -> void:
#	$AnimatedSprite.connect('frame_changed', self, '_on_frame_changed')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
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

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_frame_changed() -> void:
	if not _parent.is_moving: return
	if $AnimatedSprite.is_playing() and $AnimatedSprite.animation == 'Walk' \
		or $AnimatedSprite.animation == 'WalkGrab' \
		or $AnimatedSprite.animation == 'WalkFish':
		match $AnimatedSprite.frame:
			0,2:
				AudioEvent.emit_signal('play_requested', 'Player', _parent.fs_id)
				if _parent.fs_id == 'FS_Water':
					match _parent.foot:
						'L':
							_parent.get_node('Splash_L').set_emitting(true)
							_parent.get_node('Splash_R').restart()
							_parent.foot = 'R'
						'R':
							_parent.get_node('Splash_R').set_emitting(true)
							_parent.get_node('Splash_L').restart()
							_parent.foot = 'L'
