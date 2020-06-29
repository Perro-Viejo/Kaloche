extends ColorRect

onready var _timer: Timer = $Timer

var counter = 0
var fishing_started = false
var bite_chance_fq 

func _ready():
	bite_chance_fq = rand_range(5, 15)
	_timer.connect('timeout', self, '_on_timer_timeout')

func _process(delta):
	if counter >= bite_chance_fq:
		fish_bite()

func fish():
	show()
	_timer.start()
	print('toy pescando')
	color = 'eb564b'

func stop():
	hide()
	print('me aburri')
	color = 'ffffeb'
	counter = 0
	_timer.stop()

func fish_bite():
	print('mordiooo')
	color = '5dde87'
	counter = 0
	yield(get_tree().create_timer(rand_range(0.1, 0.9)),'timeout')
	fish()
	bite_chance_fq = rand_range(5, 15) 

func pull_fish():
	if color == Color('5dde87'):
		print('agarre el hp')
	else:
		print('se volo el perro')
func _on_timer_timeout():
	counter += 1
