extends Node2D

export var fishing_surfaces: Array = []

var _animation
var _is_filling = false

func _ready():
	_animation = $AnimationPlayer
	$TempleDoorButton.connect('button_pressed', self, 'fill_tank')
	$TempleDoorButton.connect('button_unpressed', self, 'empty_tank')
	_animation.connect('animation_finished', self, '_on_animation_finished')
	AudioEvent.connect('stream_finished', self, '_on_stream_finished')

func fill_tank():
	_is_filling = true
	AudioEvent.emit_signal('stop_requested', 'Tank', 'Empty_Loop')
	AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_Start', global_position)
	$Holes.set_frame(1)
	_animation.play('Fill')

func empty_tank():
	_is_filling = false
	AudioEvent.emit_signal('stop_requested', 'Tank', 'Fill_Loop')
	AudioEvent.emit_signal('play_requested', 'Tank', 'Empty_Loop', global_position)
	AudioEvent.emit_signal('play_requested', 'Tank', 'Empty_Start', global_position)
	$Holes.set_frame(0)
	_animation.play_backwards('Fill')

func _on_animation_finished(anim):
	if _animation.get_current_animation_position() == _animation.get_current_animation_length():
		activate_tank()
	if _animation.get_current_animation_position() == 0:
		AudioEvent.emit_signal('stop_requested', 'Tank', 'Empty_Loop')
		AudioEvent.emit_signal('play_requested', 'Tank', 'Empty_Tail', global_position)

func activate_tank():
	AudioEvent.emit_signal('stop_requested', 'Tank', 'Fill_Loop')
	AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_Full')
	$TempleDoorButton.is_toggle = true
	for s in fishing_surfaces:
		var surface = get_node(s)
		surface.show()
		surface.monitoring = true
		surface.monitorable = true
		surface._spawn_fishes()

func _on_stream_finished(source, sound):
	if _is_filling:
		if sound == 'Fill_Start':
			AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_Loop', global_position)
		
