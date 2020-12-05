extends Node2D

var _animation

func _ready():
	_animation = $AnimationPlayer
	$TempleDoorButton.connect('button_pressed', self, 'fill_tank')
	$TempleDoorButton.connect('button_unpressed', self, 'empty_tank')
	_animation.connect('animation_finished', self, 'deactivate_button')

func fill_tank():
	$Holes.set_frame(1)
	_animation.play('Fill')

func empty_tank():
	$Holes.set_frame(0)
	_animation.play_backwards('Fill')

func deactivate_button(anim):
	if _animation.get_current_animation_position() == _animation.get_current_animation_length():
		$TempleDoorButton.is_toggle = true
