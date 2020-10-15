# El gancho está esperando a que algo se le enganche
extends "res://src/StateMachine/State.gd"

export var _min_bite_freq := 15.0
export var _max_bite_freq := 30.0

var _hook_check_freq := 0.0
var _counter := 0
var _fish := {}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func physics_process(delta: float) -> void:
	_counter += delta
	if _counter >= _hook_check_freq:
		if _got_hooked():
			_state_machine.transition_to_key('Hooked', _fish)
		else:
			_counter = 0
			_hook_check_freq = rand_range(_min_bite_freq, _max_bite_freq)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	_parent.emit_signal('dropped')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
# Verifica si algo se enganchó al gancho o si hay que volver a esperar un rato
# para volver a verificar
func _got_hooked() -> bool:
	var fish: FishData = FishDatabase.get_random_fish()
	_fish = fish.get_data()
	return true
