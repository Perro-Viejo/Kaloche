extends "res://src/StateMachine/State.gd"

func _ready() -> void:
	$AnimatedSprite.connect('frame_changed', self, '_on_frame_changed')
	
func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func play_animation() -> bool:
	if _parent.grabbing:
		$AnimatedSprite.play('IdleGrab')
	else:
		$AnimatedSprite.play('Idle')
	return true


func _on_frame_changed() -> void:
	if $AnimatedSprite.animation == 'Run' \
		or $AnimatedSprite.animation == 'RunGrab':
		match $AnimatedSprite.frame:
			0,2:
				AudioEvent.emit_signal('play_requested', "Player", _parent.fs_id)
				if _parent.fs_id == 'FS_Water':
					match _parent.foot:
						'L':
							$Splash_L.set_emitting(true)
							$Splash_R.restart()
							_parent.foot = 'R'
						'R':
							$Splash_R.set_emitting(true)
							$Splash_L.restart()
							_parent.foot = 'L'
							
func exit() -> void:
	.exit()
