# Algo se enganchó en el gancho
extends "res://src/StateMachine/State.gd"

export var min_fish_size := 0.2
export var max_fish_size := 1.3

var _fish_size := 0.0
var _fish_resistance := 0.0
var _fish_sprite: Texture = null
var _fish_name := ''
var _catch_sfx := ''
var _can_damage_fish := false
var _catch_chance := 1.0
var _oportunity_cooldown := 0
var _can_damage_fish_debug := -1
var _fish_pos := Vector2.ZERO
var _fight_cooldown := 0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready() -> void:
	_fish_pos = Vector2(rand_range(-3, 3), rand_range(-3, 3))
	set_process(false)

func _process(delta) -> void:
	# Aquí se mueve el pescado forcejeando con el Teotriste
	_fight_cooldown += 1
	if _fight_cooldown >= rand_range(15, 60):
		owner.position = owner.target_pos + _fish_pos
		_fight_cooldown = 0
		_fish_pos = Vector2(rand_range(-3, 3), rand_range(-3, 3))
	
	# Esto es pa' que el jugador no pueda jalar la caña como loco
	_oportunity_cooldown -= 1
	if _oportunity_cooldown <= 0:
		_can_damage_fish = true
		if _oportunity_cooldown <= rand_range(-30, -10):
			_can_damage_fish = false
			_oportunity_cooldown = rand_range(5, 60)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	_fish_size = msg.size
	_fish_resistance = msg.resistance
	_fish_sprite = msg.sprite
	_fish_name = msg.name
	_catch_sfx = msg.catch_sfx
	
	_can_damage_fish_debug = DebugOverlay.add_monitor(
		'\nvulnerable', self, ':_can_damage_fish'
	)
	
	owner.play_animation('waveB')
	owner.emit_signal('hooked')
	
	set_process(true)


func exit() -> void:
	DebugOverlay.remove_monitor(_can_damage_fish_debug)
	_can_damage_fish_debug = -1
	set_process(false)
	.exit()


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
	
	PlayerEvent.emit_signal('fish_caught', global_position)
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
