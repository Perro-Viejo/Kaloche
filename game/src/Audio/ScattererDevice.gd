extends Node2D

export (Vector2) var freq_range = Vector2.ONE

var listener
var target_pos
var _timer
var offset = Vector2.ZERO


func _ready():
	_timer = $Timer
	_timer.connect('timeout', self, 'tick')
	$Area2D.connect('area_entered', self, '_on_area_entered')
	$Area2D.connect('area_exited', self, '_on_area_exited')

func _process(delta):
	if listener:
		target_pos = listener.get_global_position()

func _on_area_entered(other):
	if other.get_name() == 'PlayerArea':
		listener = other
		_timer.start()
func _on_area_exited(other):
	if other.get_name() == 'PlayerArea':
		_timer.stop()

func tick():
	for emitters in $Emitters.get_children():
		emitters.count_tick(target_pos)
