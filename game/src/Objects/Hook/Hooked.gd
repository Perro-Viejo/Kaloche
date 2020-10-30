# Algo se enganchó en el gancho
extends "res://src/StateMachine/State.gd"

export var min_fish_size := 0.2
export var max_fish_size := 1.3

var _fish_size := 0.0
var _fish_resistance := 0.0
var _fish_sprite: Texture = null
var _fish_name := ''
var _catch_sfx := ''
var _can_damage_fish := true
var _catch_chance := 1.0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	_fish_size = msg.size
	_fish_resistance = msg.resistance
	_fish_sprite = msg.sprite
	_fish_name = msg.name
	_catch_sfx = msg.catch_sfx
	
	owner.emit_signal('hooked')


func pull_done(rod_strength: float) -> Dictionary:
	var result = {
		caught = false,
		escaped = false, # Se voló por la probabilidad
		lost = false,
		fighting = true
	}
	
	if _can_damage_fish:
		_fish_resistance -= 1
		if randf() <= _catch_chance:
			if _fish_size <= rod_strength:
				if _fish_resistance < 1:
					result.caught = true
					_catch_fish()
					_state_machine.transition_to_key('Idle')
			else:
				if _fish_resistance < 1:
					result.lost = true
					_state_machine.transition_to_key('Idle')
					AudioEvent.emit_signal(
						'play_requested',
						'Fishing',
						'pull_fish_none',
						owner.position
					)
		else:
			if randi() % 100 <= 15:
				result.escaped = true
	
	return result

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
# Instancia el pez pescado y lo manda pa' detrás del Teotriste
func _catch_fish() -> void:
	var fish := preload('res://src/Pickables/Fish_Pickable.tscn').instance() as FishPickable
	var _game: Node = get_node('/root/Game')
	if _game:
		(_game as Game).CurrentSceneInstance.add_child(fish)
	else:
		get_node('/root').add_child(fish)
	
	fish.tr_code = _fish_name
	fish.get_node('Sprite').texture = _fish_sprite
	fish.global_position = global_position
	fish.jump(Vector2(35, position.y))

	AudioEvent.emit_signal(
		'play_requested',
		'Fishing',
		'pull_fish_' + _catch_sfx,
		global_position
	)
