extends ColorRect

onready var _timer: Timer = $Timer

var counter = 0
var bite_chance_fq 

func _ready():
	bite_chance_fq = rand_range(5, 15) 
	_timer.connect('timeout', self, '_on_timer_timeout')

func _process(delta):
	if counter >= bite_chance_fq:
		fish_bite()

func fish():
	show()
	yield(get_tree().create_timer(rand_range(2, 3)), 'timeout')
	print('toy pescando')
	color = 'eb564b'
	_timer.start()

func stop():
	hide()
	print('me aburri')
	color = 'ffffeb'
	counter = 0

func fish_bite():
	print('mordiooo')
	color = '5dde87'
	counter = 0
	bite_chance_fq = rand_range(5, 15) 

func _on_timer_timeout():
	counter += 1
