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
var _bait_data := {}
var _counter := 0.0
var _hook_check_freq := 0.0
var _hook_ref: Hook = null

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	_timer = Timer.new()
	_timer.wait_time = spawn_cooldown
	_timer.one_shot = true
	_timer.connect('timeout', self, '_spawn_fishes')
	add_child(_timer)

	_spawn_fishes()

func _process(delta):
	if _bait_data:
		# Si ya hay un gancho (con cebo) dentro del agua
		_counter += delta
		if _counter >= _hook_check_freq:
			if _got_hooked():
				_bait_data = {}
				_hook_ref.hook_success(_fishes[_captured_fish_idx])
				_on_fish_captured()
			else:
				_counter = 0.0
				_hook_check_freq = rand_range(bite_freq.x, bite_freq.y)
				_hook_ref.hook_fail()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func hook_entered(hook: Hook) -> void:
	_hook_ref = hook
	_bait_data = hook.bait_data
	_hook_check_freq = rand_range(bite_freq.x, bite_freq.y)
	_counter = 0.0
	prints('Nos cayó %s' % _bait_data.type)

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _spawn_fishes() -> void:
	for c in range(max_fish_count):
		_fishes.append(FishDatabase.get_random_fish())
		# TODO: llamar una función que genere las sombras de los peces nadando

func _on_fish_captured() -> void:
	_fishes.remove(_captured_fish_idx)
	if _fishes.empty():
		_timer.start()

# Verifica si algo se enganchó al gancho o si hay que volver a esperar un rato
# para volver a verificar
func _got_hooked() -> bool:
	var hooked := false
	# TODO: Hacer la lógica para determinar qué pez mordió el anzuelo
	_captured_fish_idx = -1
	if randf() > 0.2:
		_captured_fish_idx = randi() % _fishes.size()
	return _captured_fish_idx > -1
