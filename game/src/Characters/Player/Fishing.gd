class_name Fishing
extends ColorRect

enum BAITS {NADA, GUSANO, SANGRE}
enum RODS {SHORT, MED, LONG}
export (BAITS) var bait
export (RODS) var current_rod
export (int) var chance = 40
export (float) var min_bite_freq = 15
export (float) var max_bite_freq = 30
export (float) var min_fish_size = 0.2
export (float) var max_fish_size = 1.3

onready var _timer: Timer = $Timer
onready var _tween: Tween = get_node("../Tween")
onready var _move: Node = get_node("../StateMachine/Move")

var counter = 0
var fishing_started = false
var fish_size
var bite_check
var hooked_time
var hooked_time_range = [350, 550]
var hooked
var fish_pull = Vector2(0, 1) 
var pull_points
var pull_cooldown = 0
var can_pull = false
var oportunity_cooldown
var line_length
var rod_strength = 0.6
var rod_multiplier = 1
var max_line_length = 8
var min_line_length = 15
var original_pos
var end_pos = Vector2.ZERO
var _fish_splash

const FISH = preload("res://src/Pickables/Fish_Pickable.tscn")

func _ready():
	fish_pull = Vector2(rand_range(-3, 3), rand_range(-3, 3))
	hooked_time = rand_range(hooked_time_range[0], hooked_time_range[1])
	oportunity_cooldown = rand_range(5, 60)
	bite_check = rand_range(min_bite_freq, max_bite_freq)
	_timer.connect('timeout', self, '_on_timer_timeout')
	WorldEvent.connect('rod_selected', self, 'switch_rod')


func _process(delta):
	if not fishing_started:
		if counter == 2:
			counter = 0
			fish()
			fishing_started = true
	else:
		if counter >= bite_check:
			fish_bite()
	
	if hooked:
		#Aquí el pez se mueve para pelear
		pull_cooldown += 1
		if pull_cooldown >= rand_range(15, 60):
			rect_position += fish_pull
			pull_cooldown = 0
			fish_pull = Vector2(rand_range(-3, 3), rand_range(-3, 3))
		
		#Aquí se ve el tiempo que dura enganchado el pez
		hooked_time -= 1
		if hooked_time <= 0:
			get_parent().speak(tr("Se voló el bagrese..."))
			AudioEvent.emit_signal('play_requested', 'Fishing', 'escape', get_parent().global_position)
			AudioEvent.emit_signal("play_requested", "Fishing", "pull_fish_none", get_parent().position + (rect_position + end_pos))
			_timer.set_pause_mode(false)
			hooked = false
			hooked_time = rand_range(hooked_time_range[0], hooked_time_range[1]) * rod_multiplier
			rect_position = original_pos
			stop()
			bite_check = rand_range(min_bite_freq, max_bite_freq)
		#Esto muestra en que momento es vulnerable el pez pa jalarlo
		#debe ser borrado prontox
#		if hooked:
#			oportunity_cooldown -= 1
#			if oportunity_cooldown <= 0:
#				color = '5dde87'
#				can_pull = true
#				if oportunity_cooldown <= rand_range(-30, -10):
#					color = 'ff96d7'
#					can_pull = false
#					oportunity_cooldown = rand_range(5, 60)
				

func start_fishing():
	randomize()
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
	
	# TODO: Llamar a Hook.throw
#	_tween.interpolate_property(
#		self, "rect_position",
#		rect_position, rect_position + end_pos , 1.2,
#		Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
#	_tween.start()
#	AudioEvent.emit_signal("play_requested", "Fishing", "rod_throw")
	

func fish():
	#Cae el anzuelo y empieza a pescar
	color = 'eb564b'
	print('toy pescando')
	var rod_sound
	rod_sound = RODS.keys()[current_rod].to_lower()
	AudioEvent.emit_signal("play_requested", "Fishing", "rod_fall_"+ rod_sound, get_parent().position + (rect_position + end_pos))

func stop():
	hide()
	color = 'ffffeb'
	fishing_started = false
	counter = 0
	hooked = false
	_timer.stop()
	AudioEvent.emit_signal("stop_requested", "Fishing", "rod_throw")

func fish_bite():
	
	#determina el tamaño del pez  que va a salir
	fish_size = rand_range(min_fish_size, max_fish_size)
	
	#cambia variables dependiendo el tamaño del pez
	if fish_size <= 0.5:
		pull_points = rand_range(1, 3)
	elif fish_size > 0.5 and fish_size <= 1 :
		pull_points = rand_range(3, 7)
	elif fish_size > 1:
		pull_points = rand_range(7, 12)
	_timer.set_pause_mode(true)
	original_pos = rect_position
	counter = 0
	hooked = true
	color = 'ff96d7'

func pull_fish():
	if fishing_started:
		randomize()
		if hooked:
			if can_pull:
				pull_points -= 1
				if randi()%100 <= chance:
					if fish_size <= rod_strength:
						if pull_points < 1:
							catch_fish()
					else:
						if pull_points < 1:
							get_parent().speak(tr("Ta muy gordo este hp"))
							AudioEvent.emit_signal("play_requested", "Fishing", "pull_fish_none", get_parent().position + (rect_position + end_pos))
							fish_size = rand_range(min_fish_size, max_fish_size)
							stop()
				else:
					if randi()%100 <= 15:
						var responses = ["Pescaito berriondo...","¡Jala arrecho este bicho!","jalo, jalo, jalo..."]
						responses.shuffle()
						get_parent().speak(tr(responses[0]))
		else:
			stop()

func catch_fish():
	hooked = false
	_fish_splash.position = get_position()
	_fish_splash.set_emitting(true)
	var fish_size_sfx
	if fish_size <= 0.5:
		fish_size_sfx = "small"
	elif fish_size >= 0.6 and fish_size <= 0.9:
		fish_size_sfx = "med"
	else: 
		fish_size_sfx = "large"
	print (fish_size_sfx)
	AudioEvent.emit_signal("play_requested", "Fishing", "pull_fish_"+ fish_size_sfx, get_parent().position + (rect_position + end_pos))
	
	stop()
	var fish = FISH.instance()
	get_node('../..').add_child(fish)
	fish.set_global_position(get_global_position())
	fish.check_bait(bait)
	fish.scale = Vector2.ONE * fish_size
	fish.jump(get_position())

func switch_bait():
	stop()
	bait += 1
	if bait >= BAITS.size():
		bait = 0
	var bait_message
	
	match BAITS.keys()[bait]:
		'NADA':
			bait_message = "Probemos anzuelo vacío..."
		'GUSANO':
			bait_message = "Gusanito en el anzuelo y pal río."
		'SANGRE':
			bait_message = "Sangre de mula en el gusanito pal pescao."
	get_parent().speak(tr(bait_message))

func switch_rod(rod):
	current_rod = int(rod)
	
	match RODS.keys()[current_rod]:
		'SHORT':
			chance = 40
			min_line_length = 8
			max_line_length = 15
			rod_strength = 0.6
			rod_multiplier = 1
			hooked_time_range = [350, 500]
		'MED':
			chance = 50
			min_line_length = 20
			max_line_length = 35
			rod_strength = 0.9
			rod_multiplier = 1.5
			hooked_time_range = [500, 900]
		'LONG':
			chance = 60
			min_line_length = 40
			max_line_length = 55
			rod_strength = 1.3
			rod_multiplier = 2
			hooked_time_range = [600, 1000]

func _on_timer_timeout():
	counter += 1
