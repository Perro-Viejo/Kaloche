extends "res://src/Levels/Surface.gd"

export var has_fishes := true
export var max_fish_count := 5
# Cuando ya no queden peces en el agua, tras completarse este tiempo, volverán a
# crearse peces
export var spawn_cooldown := 5 # En minutos
# export var types := []
export var bite_freq := Vector2(15.0, 30.0)


var _timer: Timer = null
var _fishes := []
var _captured_fish_idx := -1
var _bait := ''
var _counter := 0.0
var _hook_check_freq := 0.0
var _hook_ref: Hook = null
var _hooked_monitor_id := -1

const HOOK_SPLASH = preload("res://src/Particles/HookSplash.tscn")
const FISH_SPLASH = preload("res://src/Particles/FishSplash.tscn")

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	_timer = Timer.new()
	_timer.wait_time = spawn_cooldown
	_timer.one_shot = true
	_timer.connect('timeout', self, '_spawn_fishes')
	add_child(_timer)
	
	_spawn_fishes()
	
	PlayerEvent.connect('fish_caught', self, '_fish_splash')

func _process(delta):
	if _bait:
		# Si ya hay un gancho (con cebo) dentro del agua
		_counter += delta
		if _counter >= _hook_check_freq:
			if _got_hooked():
				_bait = ''
				DebugOverlay.remove_monitor(_hooked_monitor_id)
				_hook_ref.hook_success(_fishes[_captured_fish_idx])
				_on_fish_bit()
			else:
				_counter = 0.0
				_hook_check_freq = rand_range(bite_freq.x, bite_freq.y)
				_hook_ref.hook_fail()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func hook_entered(hook: Hook) -> void:
	_hook_ref = hook
	var splash = HOOK_SPLASH.instance()
	add_child(splash)
	splash.set_global_position(hook.global_position)
	AudioEvent.emit_signal('play_requested', 'Fishing', 'rod_fall_long', hook.global_position)
	_bait = hook.bait
	_hook_check_freq = rand_range(bite_freq.x, bite_freq.y)
	_counter = 0.0
	
	# Pal debug
	_hooked_monitor_id = DebugOverlay.add_monitor(
		'\nnext_check', self, '', 'get_hooked_check_time'
	)

#TODO: conectar esta vuelta :(
#func _pull_sfx():
#	AudioEvent.emit_signal('play_requested', 'Fishing', 'pull_fish_fight', _hook_ref.global_position)

func get_hooked_check_time() -> String:
	return '%d s' % int(_hook_check_freq - _counter)

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _spawn_fishes() -> void:
	for c in range(max_fish_count):
		_fishes.append(FishingDatabase.get_random_fish())
		# TODO: llamar una función que genere las sombras de los peces nadando

func _on_fish_bit() -> void:
	_fishes.remove(_captured_fish_idx)
	if _fishes.empty():
		_timer.start()

# Verifica si algo se enganchó al gancho o si hay que volver a esperar un rato
# para volver a verificar
func _got_hooked() -> bool:
	var hooked := false
	var selected_fish: FishData = null
	var highest_chance := 0.0
	var selected_fish_idx := 0

	# 1. Seleccionar el pez que va a ver la carnada
	if _bait:
		var counter := 0
		for f in _fishes:
			var fish: FishData = f as FishData
			if fish.attracted_to.has(_bait) \
				and fish.attracted_to[_bait] > highest_chance:
				highest_chance = fish.attracted_to[_bait]
				selected_fish = fish
				selected_fish_idx = counter
			counter += 1
	else:
		# TODO: Seleccionar un pescado genérico si hay
		pass
	
	if selected_fish:
		# 2. Determinar si el pez seleccionado muerde o no la carnada
		# NOTA: Puede ser que a futuro esto ocurra en dos tiempos distintos, así le
		# 		damos a los peces la oportunidad de tantear la carnada antes de
		#		morderla
		if randf() <= selected_fish.attracted_to[_bait]:
			_captured_fish_idx = selected_fish_idx
		else:
			# TODO: Inhabilitar el pez por un tiempo para que no vuelva a intentar
			#		morder la carnada
			pass
	else:
		_captured_fish_idx = -1

	return _captured_fish_idx > -1


func _fish_splash(position):
	var splash = FISH_SPLASH.instance()
	add_child(splash)
	splash.set_global_position(position)
