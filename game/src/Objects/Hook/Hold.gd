# El gancho está esperando a que algo se le enganche
extends "res://src/StateMachine/State.gd"

export var _min_bite_freq := 15.0
export var _max_bite_freq := 30.0
export var _check_surface_wait := 1.0 # En segundos

var _hook_check_freq := 0.0
var _counter := 0.0
var _fish := {}
var _area_ref: Area2D = null
var _surface_detected := false
var _check_surface_counter := 0.0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	yield(owner, 'ready')
	_area_ref = owner.area

func physics_process(delta: float) -> void:
	_counter += delta
	if _counter >= _hook_check_freq:
		if _got_hooked():
			_state_machine.transition_to_key('Hooked', _fish)
		else:
			_counter = 0.0
			_hook_check_freq = rand_range(_min_bite_freq, _max_bite_freq)
			owner.emit_signal('tried')
		return

	_check_surface_counter -= delta
	if _check_surface_counter < 0 and not _surface_detected:
		_sent_back()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	_check_surface_counter = _check_surface_wait
	_area_ref.connect('area_entered', self, '_on_area_entered')
	_area_ref.monitoring = true
	_surface_detected = false
	_counter = 0.0
	_hook_check_freq = rand_range(_min_bite_freq, _max_bite_freq)

func exit() -> void:
	_surface_detected = false
	_area_ref.disconnect('area_entered', self, '_on_area_entered')
	_area_ref.monitoring = false
	.exit()

func pull_done(rod_strength: float) -> Dictionary:
	_sent_back()
	return {}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
# Verifica si algo se enganchó al gancho o si hay que volver a esperar un rato
# para volver a verificar
func _got_hooked() -> bool:
	var hooked := false
	var fish: FishData = FishDatabase.get_random_fish()
	if fish:
		_fish = fish.get_data()
		hooked = true
	return hooked

func _on_area_entered(body: Area2D) -> void:
	_surface_detected = true
	var surface: Surface = body
	if surface.type == Data.SurfaceType.WATER:
		owner.emit_signal('dropped')
	else:
		_sent_back()

func _sent_back() -> void:
	_state_machine.transition_to_key('Idle')
	owner.emit_signal('sent_back')
