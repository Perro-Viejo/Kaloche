extends ColorRect

enum BAITS {NADA, GUSANO, SANGRE}
export (BAITS) var bait

onready var _timer: Timer = $Timer
onready var _tween: Tween = get_node("../Tween")

var counter = 0
var fishing_started = false
var bite_check
var hooked
var original_pos
var end_pos = Vector2(0,0)

export (float) var min_bite_freq = 5
export (float) var max_bite_freq = 15
export (int) var chance = 100
const FISH = preload("res://src/Pickables/Fish_Pickable.tscn")

func _ready():
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
	#se alista y lanza el anzuelo
	show()
	hooked = false
	_timer.start()
	
	original_pos = rect_position
	#ver donde esta mirando la caña 
	if rect_position.y > 1:
		end_pos = Vector2(0, rand_range(8,15))
	elif rect_position.y < 1:
		end_pos = Vector2(0, rand_range(-8,-15))
	
	if rect_position.x > 0 and rect_position.y == 1:
		end_pos = Vector2(rand_range(8,15), 0)
	elif rect_position.x < 0 and rect_position.y == 1:
		end_pos = Vector2(rand_range(-8,-15), 0)
		
	_tween.interpolate_property(
		self, "rect_position",
		rect_position, rect_position + end_pos , 1.2,
		Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	_tween.start()
	

func fish():
	#Cae el anzuelo y empieza a pescar
	color = 'eb564b'
	print('toy pescando')

func stop():
	hide()
	rect_position = original_pos
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
