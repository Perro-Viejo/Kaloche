extends ColorRect

enum BAITS {NADA, GUSANO, SANGRE}
export (BAITS) var bait

onready var _timer: Timer = $Timer

var counter = 0
var fishing_started = false
var bite_check
var hooked

export (float) var min_bite_freq = 5
export (float) var max_bite_freq = 15
export (int) var chance = 100
const FISH = preload("res://src/Pickables/Fish_Pickable.tscn")

func _ready():
	print(bait)
	bite_check = rand_range(min_bite_freq, max_bite_freq)
	_timer.connect('timeout', self, '_on_timer_timeout')

func _process(delta):
	if not fishing_started:
		if counter == 4:
			counter = 0
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
	yield(get_tree().create_timer(rand_range(1, 2)),'timeout')
	hooked = false
	fish()
	bite_check = rand_range(min_bite_freq, max_bite_freq) 

func pull_fish():
	randomize()
	if hooked:
		if randi()%100 <= chance:
			catch_fish()
		else:
			stop()
	else:
		stop()

func catch_fish():
	stop()
	var fish = FISH.instance()
	get_node('../..').add_child(fish)
	fish.set_global_position(get_global_position())
	fish.check_bait(bait)
	fish.jump(get_position())
	

func _on_timer_timeout():
	counter += 1
