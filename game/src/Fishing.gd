extends ColorRect

onready var _timer: Timer = $Timer

var counter = 0
var fishing_started = false
var bite_check
var hooked
var chance = 50

const FISH = preload("res://src/Pickables/Fish_Pickable.tscn")

func _ready():
	bite_check = rand_range(5, 15)
	_timer.connect('timeout', self, '_on_timer_timeout')

func _process(delta):
	if not fishing_started:
		if counter == 4:
			fish()
			fishing_started = true
	else:
		if counter >= bite_check:
			fish_bite()

func start_fishing():
	show()
	hooked = false
	_timer.start()
	

func fish():
	color = 'eb564b'
	counter = 0
	print('toy pescando')

func stop():
	hide()
	color = 'ffffeb'
	fishing_started = false
	counter = 0
	hooked = false
	_timer.stop()

func fish_bite():
	print('mordiooo')
	counter = 0
	hooked = true
	color = '5dde87'
	yield(get_tree().create_timer(rand_range(0.1, 0.9)),'timeout')
	hooked = false
	fish()
	bite_check = rand_range(5, 15) 

func pull_fish():
	randomize()
	if hooked:
		if randi()%100 <= chance:
			catch_fish()
		else:
			print ('se me jue')
	else:
		print('nada que jalar')
	counter = 0

func catch_fish():
	var fish = FISH.instance()
	get_node('../..').add_child(fish)
	fish.set_global_position(get_global_position())
	fish.jump(get_position())
	hooked = false
	

func _on_timer_timeout():
	counter += 1
