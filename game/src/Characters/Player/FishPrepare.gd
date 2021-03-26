extends "res://src/StateMachine/State.gd"

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

var min_distance := 75.0 # 24.0
var max_distance := 90.0 # 75.0
var aim_distance := Vector2.ZERO
var distance := 0.0
var hook_target_pos := Vector2.ZERO
var can_change_bait := false

var _hook: Hook = null
var _listening_input := false
var _current_direction: int = Direction.RIGHT setget _set_current_direction
var _current_bait: BaitData = FishingDatabase.get_bait(0)
var _timer: Timer = null

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	_timer = Timer.new()
	_timer.wait_time = 0.2
	_timer.one_shot = true
	_timer.connect('timeout', self, '_enable_input_listening')
	add_child(_timer)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func enter(msg: Dictionary = {}) -> void:
	_determine_distance()
	
	owner.is_paused = true
	owner.fishing = true
	
	_hook = owner.hook
	_hook.bait = _current_bait.name if _current_bait else ''

	self._current_direction = Direction.RIGHT if not owner.sprite.flip_h else Direction.LEFT

	# TODO: Si vamos a renderizar distintos tipos de caña, la definición de estas
	#		debería indicar dónde se pondrá el gancho.
	_hook.show()
	_hook.connect('dropped', _state_machine, 'transition_to_key', ['FishHold'])
	_hook.connect(
		'sent_back',
		_state_machine,
		'transition_to_key',
		['Idle', { fishing_failed = true } ]
	)
	_listening_input = false
	_timer.start()

	.enter(msg)


func exit() -> void:
	owner.hook_target.hide()
	owner.is_paused = false
	_listening_input = false

	_hook.disconnect('dropped', _state_machine, 'transition_to_key')
	_hook.disconnect('sent_back', _state_machine, 'transition_to_key')

	.exit()


func unhandled_input(event: InputEvent) -> void:
	if not _listening_input: return

	if event.is_action_pressed('Action'):
		_listening_input = false

		# Se usa la dirección seleccionada por el jugador y se calcula la distancia
		# a la que se lanzará el gancho
		AudioEvent.emit_signal('play_requested', 'Fishing', 'rod_throw')

		owner.hook.target_pos = hook_target_pos
	elif event.is_action_pressed('Drop'):
		if can_change_bait:
			_current_bait = FishingDatabase.get_next_bait()
			_hook.bait = _current_bait.name if _current_bait else ''
	elif event.is_action_pressed('Up'):
		self._current_direction = Direction.UP
	elif event.is_action_pressed('Right'):
		self._current_direction = Direction.RIGHT
	elif event.is_action_pressed('Down'):
		self._current_direction = Direction.DOWN
	elif event.is_action_pressed('Left'):
		self._current_direction = Direction.LEFT
	elif event.is_action_pressed('Equip') and not owner.hook.thrown:
		owner.hook_target.position = Vector2.ZERO
		_state_machine.transition_to_key('Idle')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _set_current_direction(dir: int) -> void:
	_current_direction = dir

	match _current_direction:
		Direction.RIGHT:
			owner.hook.position = Vector2(-6, -6)
			owner.rod_tip.position.x = owner.rod_tip_pos.x
			owner.sprite.flip_h = false
			if distance:
				hook_target_pos = Vector2(distance, 12)
				aim_distance = Vector2(distance + _hook.position.x - 6,0)
		Direction.LEFT:
			owner.hook.position = Vector2(6, -6)
			owner.rod_tip.position.x = -owner.rod_tip_pos.x
			owner.sprite.flip_h = true
			if distance:
				hook_target_pos = Vector2(distance * -1, 12)
				aim_distance = Vector2(distance * -1 - _hook.position.x + 18,0)

	(owner.hook as Hook).surface_ref = null
	owner.hook_target.position = aim_distance
	owner.hook_target.show()


# Determina la distancia a la que caerá el gancho cuando sea lanzado
func _determine_distance():
	randomize()
	distance = rand_range(min_distance, max_distance)


func _enable_input_listening() -> void:
	_listening_input = true
