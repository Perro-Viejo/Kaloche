extends Node2D

export var fishing_surfaces: Array = []

var _animation

func _ready():
	_animation = $AnimationPlayer
	$TempleDoorButton.connect('button_pressed', self, 'fill_tank')
	$TempleDoorButton.connect('button_unpressed', self, 'empty_tank')
	_animation.connect('animation_finished', self, '_on_animation_finished')

func fill_tank():
	$Holes.set_frame(1)
	_animation.play('Fill')

func empty_tank():
	$Holes.set_frame(0)
	_animation.play_backwards('Fill')

func _on_animation_finished(anim):
	if _animation.get_current_animation_position() == _animation.get_current_animation_length():
		activate_tank()
		

func activate_tank():
	$TempleDoorButton.is_toggle = true
	for s in fishing_surfaces:
		var surface = get_node(s)
		surface.show()
		surface.monitoring = true
		surface.monitorable = true
		surface._spawn_fishes()
