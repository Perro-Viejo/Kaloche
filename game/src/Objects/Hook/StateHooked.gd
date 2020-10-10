# Algo se enganchó en el gancho
extends "res://src/StateMachine/State.gd"

export var min_fish_size := 0.2
export var max_fish_size := 1.3

var _fish_size := 0.0
var _fish_resistance := 0.0
var _can_damage_fish := false
var _catch_chance := 0.0
var _rod_strength := 0.0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	_fish_size = rand_range(min_fish_size, max_fish_size)

	# La resistencia del pez depende de su tamaño
	if _fish_size <= 0.5:
		_fish_resistance = rand_range(1, 3)
	elif _fish_size > 0.5 and _fish_size <= 1 :
		_fish_resistance = rand_range(3, 7)
	elif _fish_size > 1:
		_fish_resistance = rand_range(7, 12)


func pull_done() -> void:
	if _can_damage_fish:
		_fish_resistance -= 1
		if randi() % 100 <= _catch_chance:
			if _fish_size <= _rod_strength:
				if _fish_resistance < 1:
					_catch_fish()
			else:
				if _fish_resistance < 1:
#					TODO: Poner estas dos en el Player
#					get_parent().speak(tr("Ta muy gordo este hp"))
#					AudioEvent.emit_signal("play_requested", "Fishing", "pull_fish_none", get_parent().position + (rect_position + end_pos))
					_fish_size = rand_range(min_fish_size, max_fish_size)
					_state_machine.transition_to_key('Idle')
		else:
			if randi() % 100 <= 15:
				pass
#				TODO: Notificar al Player que se escapó el pescado
#				var responses = ["Pescaito berriondo...","¡Jala arrecho este bicho!","jalo, jalo, jalo..."]
#				responses.shuffle()
#				get_parent().speak(tr(responses[0]))

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _catch_fish() -> void:
	pass
