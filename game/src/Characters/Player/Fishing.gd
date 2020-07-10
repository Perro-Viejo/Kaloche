class_name Fishing
extends ColorRect

enum BAITS {NADA, GUSANO, SANGRE}
export (BAITS) var bait
export (float) var min_bite_freq = 5
export (float) var max_bite_freq = 15
export (int) var chance = 100
export (float) var min_fish_size = 0.3
export (float) var max_fish_size = 1.2

onready var _timer: Timer = $Timer
onready var _tween: Tween = get_node("../Tween")
onready var _move: Node = get_node("../StateMachine/Move")

var counter = 0
var fishing_started = false
var bite_check
var hooked
var end_pos = Vector2.ZERO

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
	#pone el anzuelo en la dirección correcta
	if _move._last_dir.y == 0:
		if _move._last_dir.x < 0:
			rect_position = Vector2(-10, 1)
		else:
			rect_position = Vector2(7, 1)
	elif _move._last_dir.x == 0:
		if _move._last_dir.y < 0:
			rect_position = Vector2(-2, -10)
		else:
			rect_position = Vector2(-2, 8)
	show()
	hooked = false
	_timer.start()
	
	#ver donde esta mirando la caña 
	if rect_position.y > 1:
		end_pos = Vector2(0, rand_range(8,15))
	elif rect_position.y < 1:
		end_pos = Vector2(0, rand_range(-8,-15))

	if rect_position.x > 0 and rect_position.y == 1:
		end_pos = Vector2(rand_range(8,15), 0)
	elif rect_position.x < 0 and rect_position.y == 1:
		end_pos = Vector2(rand_range(-8,-15), 0)
#
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
	fish.scale = Vector2.ONE * rand_range(min_fish_size, max_fish_size)
	fish.jump(get_position())

func switch_bait():
	stop()
	bait += 1
	if bait >= BAITS.size():
		bait = 0
	var bait_message
	match BAITS.keys()[bait]:
		'NADA':
			bait_message = "Probemos nanai a ver que sale..."
		'GUSANO':
			bait_message = "Gusanito pal río."
		'SANGRE':
			bait_message = "Sangre de mula pal pescao."
	get_parent().speak(tr(bait_message))

func _on_timer_timeout():
	counter += 1
