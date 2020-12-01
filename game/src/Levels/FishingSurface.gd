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
var _fish_examininig := false
var _selected_fish: FishData = null
var _selected_fish_idx := 0
var _fish_examine_wait := 0.0
var _fish_examine_wait_range := Vector2(3.0, 5.0)
var _fish_examine_debug_id := -1
var _fish_shadow: Node2D = null

const HOOK_SPLASH = preload("res://src/Particles/HookSplash.tscn")
const FISH_SPLASH = preload("res://src/Particles/FishSplash.tscn")
const FISH_SHADOW = preload("res://src/Particles/FishShadow.tscn")

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
	if _fish_examininig and _fish_examine_wait > 0.0:
		# Reducir el temporizador de la animación de la sombra del pez
		# examinando la carnada
		_fish_examine_wait -= delta
	elif _bait:
		# Si ya hay un gancho (con cebo) dentro del agua
		_counter += delta
		if _counter >= _hook_check_freq:
			if _got_hooked():
				DebugOverlay.remove_monitor(_hooked_monitor_id)
				_hook_ref.disconnect('sent_back', self, 'hook_exited')
				_bait = ''
				_on_fish_bit()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func hook_entered(hook: Hook) -> void:
	_hook_ref = hook
	_hook_ref.connect('sent_back', self, 'hook_exited')
	
	var splash = HOOK_SPLASH.instance()
	add_child(splash)
	splash.set_global_position(hook.global_position)
	AudioEvent.emit_signal(
		'play_requested', 'Fishing', 'rod_fall_long', hook.global_position
	)
	_bait = hook.bait
	_hook_check_freq = rand_range(bite_freq.x, bite_freq.y)
	_counter = 0.0
	_captured_fish_idx = -1
	_fish_examininig = false
	_selected_fish = null
	_selected_fish_idx = 0
	
	# Pal debug
	_hooked_monitor_id = DebugOverlay.add_monitor(
		'\npez saldrá en', self, '', 'get_hooked_check_time'
	)

func hook_exited(hook: Hook = null) -> void:
	_bait = ''
	_hook_ref.disconnect('sent_back', self, 'hook_exited')
	_hook_ref = null
	_remove_shadow()
	DebugOverlay.remove_monitor(_hooked_monitor_id)

#TODO: conectar esta vuelta :(
#func _pull_sfx():
#	AudioEvent.emit_signal('play_requested', 'Fishing', 'pull_fish_fight', _hook_ref.global_position)

func get_hooked_check_time() -> String:
	return '%d s' % int(_hook_check_freq - _counter)

func get_fishes_list() -> String:
	var names := []
	for f in _fishes:
		var fish: FishData = f as FishData
		names.append(fish.name)
	return String(names)
	
func get_fish_examine_wait() -> float:
	return stepify(_fish_examine_wait, 0.01)

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _spawn_fishes() -> void:
	for c in range(max_fish_count):
		_fishes.append(FishingDatabase.get_random_fish())
		# TODO: llamar una función que genere las sombras de los peces nadando
	DebugOverlay.add_monitor('\npeces', self, '', 'get_fishes_list')

func _on_fish_bit() -> void:
	_fishes.remove(_captured_fish_idx)
	if _fishes.empty():
		_timer.start()

# Verifica si algo se enganchó al gancho o si hay que volver a esperar un rato
# para volver a verificar
func _got_hooked() -> bool:
	# 1. Seleccionar el pez que va a ver la carnada
	if not _selected_fish:
		_selected_fish = null
		_selected_fish_idx = 0

		var highest_chance := 0.0
		var counter := 0
		for f in _fishes:
			var fish: FishData = f as FishData

			if _bait != 'Nada' and  fish.attracted_to.has(_bait) \
				and fish.attracted_to[_bait] > highest_chance:
				highest_chance = fish.attracted_to[_bait]
				_selected_fish = fish
				_selected_fish_idx = counter
			elif _bait == 'Nada' and fish.type == fish.Type.GEN:
				_selected_fish = fish
				_selected_fish_idx = counter

			counter += 1

	if _selected_fish:
		if not _fish_examininig:
			# 1.1. Poner al pez a examinar la carnada
			_fish_examininig = true
			_fish_examine_wait = _fish_examine_wait_range.x
			_fish_examine_debug_id = DebugOverlay.add_monitor(
				'\nexaminando carnada', self, '', 'get_fish_examine_wait'
			)
			# ubicar y reproducir animación de la sombra
			var vec
			var rot
			if _hook_ref.dflt_pos.x < 0:
				vec = Vector2.RIGHT
				rot = 0
			else:
				rot = 180
				vec = Vector2.LEFT
			_fish_shadow = FISH_SHADOW.instance()
			_fish_shadow.global_position = _hook_ref.global_position + vec * 4
			_fish_shadow.rotation_degrees = rot
			_fish_shadow.get_node('AnimationPlayer').play('examine_md')
			add_child(_fish_shadow)
		else:
			_remove_shadow()

			# 2. Determinar si el pez seleccionado muerde o no la carnada
			if randf() <= _selected_fish.attracted_to[_bait]:
				_captured_fish_idx = _selected_fish_idx
				_hook_ref.hook_success(_fishes[_captured_fish_idx])
			else:
				# TODO: Inhabilitar el pez por un tiempo para que no vuelva a intentar
				#		morder la carnada
				_counter = 0.0
				_fish_examininig = false
				_hook_check_freq = rand_range(bite_freq.x, bite_freq.y)
				_hook_ref.hook_fail()

	return _captured_fish_idx > -1


func _fish_splash(position):
	var splash = FISH_SPLASH.instance()
	add_child(splash)
	splash.set_global_position(position)


func _remove_shadow() -> void:
	if _fish_shadow:
		DebugOverlay.remove_monitor(_fish_examine_debug_id)
		remove_child(_fish_shadow)
		_fish_shadow.queue_free()
