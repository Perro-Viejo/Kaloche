class_name Fishing
extends ColorRect

enum BAITS {NADA, GUSANO, SANGRE}
enum RODS {SHORT, MED, LONG}
export (BAITS) var bait
export (RODS) var current_rod
export (int) var chance = 100
export (float) var min_bite_freq = 5
export (float) var max_bite_freq = 15
export (float) var min_fish_size = 0.3
export (float) var max_fish_size = 1.2

onready var _timer: Timer = $Timer
onready var _tween: Tween = get_node("../Tween")
onready var _move: Node = get_node("../StateMachine/Move")

var counter = 0
var fishing_started = false
var fish_size
var bite_check
var hooked_time
var hooked
var line_length
var max_line_length = 8
var min_line_length = 15
var end_pos = Vector2.ZERO
var _fish_splash

const FISH = preload("res://src/Pickables/Fish_Pickable.tscn")

func _ready():
	hooked_time = rand_range(18, 50)
	bite_check = rand_range(min_bite_freq, max_bite_freq)
	_timer.connect('timeout', self, '_on_timer_timeout')

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('Testiar'):
		switch_rod()
	

func _process(delta):
	if not fishing_started:
		if counter == 4:
			counter = 0
			fish()
			fishing_started = true
	else:
		if counter >= bite_check:
			fish_bite()
	
	if hooked:
		hooked_time -= 1
		if hooked_time <= 0:
			hooked = false
			hooked_time = rand_range(18, 50)
			fish()
			bite_check = rand_range(min_bite_freq, max_bite_freq)

func start_fishing():
	randomize()
	fish_size = rand_range(min_fish_size, max_fish_size)
	line_length = rand_range(min_line_length, max_line_length)
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
		end_pos = Vector2(0, line_length)
	elif rect_position.y < 1:
		end_pos = Vector2(0, line_length * -1)

	if rect_position.x > 0 and rect_position.y == 1:
		end_pos = Vector2(line_length, 0)
	elif rect_position.x < 0 and rect_position.y == 1:
		end_pos = Vector2(line_length * -1, 0)
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
	_fish_splash.position = get_position()
	_fish_splash.set_emitting(true)
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
			bait_message = "Gusanito en la caña pal río."
		'SANGRE':
			bait_message = "Sangre de mula en un ganchito pal pescao."
	get_parent().speak(tr(bait_message))

func switch_rod():
	current_rod += 1
	if current_rod >= RODS.size():
		current_rod = 0
	
	match RODS.keys()[current_rod]:
		'SHORT':
			min_line_length = 8
			max_line_length = 15
			min_fish_size = 0.2
			max_fish_size = 0.5
		'MED':
			min_line_length = 20
			max_line_length = 35
			min_fish_size = 0.6
			max_fish_size = 0.9
		'LONG':
			min_line_length = 40
			max_line_length = 55
			min_fish_size = 0.9
			max_fish_size = 1.3
	get_parent().speak(tr("saque la caña " + RODS.keys()[current_rod]))

func _on_timer_timeout():
	counter += 1
