extends "res://src/StateMachine/State.gd"

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables públicas ▒▒▒▒
var min_distance := 75.0 # 24.0
var max_distance := 90.0 # 75.0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _hook: Hook = null
var _listening_input := false
var _current_direction: int = Direction.RIGHT setget _set_current_direction
var _current_bait: BaitData = null
var _timer: Timer = null

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	_timer = Timer.new()
	_timer.wait_time = 0.2
	_timer.one_shot = true
	_timer.connect('timeout', self, '_enable_input_listening')
	add_child(_timer)

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	self._current_direction = Direction.RIGHT if not owner.sprite.flip_h else Direction.LEFT
	
	owner.is_paused = true
	owner.fishing = true
	
	_hook = owner.hook
	
	_hook.bait = _current_bait.name if _current_bait else ''

	# TODO: Si vamos a renderizar distintos tipos de caña, la definición de estas
	#		debería indicar dónde se pondrá el gancho.
	_hook.show()
	_hook.connect('dropped', _state_machine, 'transition_to_key', ['FishHold'])
	_hook.connect('sent_back', _state_machine, 'transition_to_key', ['Idle'])
	
	_listening_input = false
	_timer.start()

	.enter(msg)

func exit() -> void:
	owner.is_paused = false
	_listening_input = false

	_hook.disconnect('dropped', _state_machine, 'transition_to_key')
	_hook.disconnect('sent_back', _state_machine, 'transition_to_key')

	.exit()

func unhandled_input(event: InputEvent) -> void:
	if not _listening_input: return

	if event.is_action_pressed('Action'):
		# Se usa la dirección seleccionada por el jugador y se calcula la distancia
		# a la que se lanzará el gancho
		AudioEvent.emit_signal('play_requested', 'Fishing', 'rod_throw')
		randomize()
		var distance := rand_range(min_distance, max_distance)
		var hook_pos := Vector2.ZERO

		match _current_direction:
			Direction.UP:
				hook_pos = Vector2(0, distance * -1)
			Direction.RIGHT:
				hook_pos = Vector2(distance, 12)
			Direction.DOWN:
				hook_pos = Vector2(0, distance)
			Direction.LEFT:
				hook_pos = Vector2(distance * -1, 12)

		owner.hook.target_pos = hook_pos
		
	elif event.is_action_pressed('Drop'):
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
		_state_machine.transition_to_key('Idle')

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _set_current_direction(dir: int) -> void:
	_current_direction = dir
	
	for color_rect in $LookingDir.get_children():
		color_rect.hide()

	match _current_direction:
		Direction.UP:
			$LookingDir/Up.show()
			owner.hook.position = Vector2(-2, 8)
		Direction.RIGHT:
			$LookingDir/Right.show()
			owner.hook.position = Vector2(-6, -6)
			owner.rod_tip.position.x = owner.rod_tip_pos.x
			owner.sprite.flip_h = false
		Direction.DOWN:
			$LookingDir/Down.show()
			owner.hook.position = Vector2(-2, -10)
		Direction.LEFT:
			$LookingDir/Left.show()
			owner.hook.position = Vector2(6, -6)
			owner.rod_tip.position.x = -owner.rod_tip_pos.x
			owner.sprite.flip_h = true
			


func _enable_input_listening() -> void:
	_listening_input = true
