extends "res://src/StateMachine/State.gd"

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _hook: Hook = null

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables públicas ▒▒▒▒
var min_distance := 75.0 # 24.0
var max_distance := 90.0 # 75.0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _current_direction: int = Direction.RIGHT setget _set_current_direction

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	self._current_direction = Direction.RIGHT if not owner.sprite.flip_h else Direction.LEFT
	
	owner.is_paused = true
	owner.fishing = true

	_hook = owner.hook

	# TODO: Si vamos a renderizar distintos tipos de caña, la definición de estas
	#		debería indicar dónde se pondrá el gancho.
	_hook.show()
	_hook.connect('dropped', _state_machine, 'transition_to_key', ['FishHold'])
	_hook.connect('sent_back', _state_machine, 'transition_to_key', ['Idle'])

	.enter(msg)

func exit() -> void:
	owner.is_paused = false
	_hook.disconnect('dropped', _state_machine, 'transition_to_key')
	_hook.disconnect('sent_back', _state_machine, 'transition_to_key')
	.exit()

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('Drop'):
		# Se usa la dirección seleccionada por el jugador y se calcula la distancia
		# a la que se lanzará el gancho
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
	elif event.is_action_pressed('Up'):
		self._current_direction = Direction.UP
	elif event.is_action_pressed('Right'):
		self._current_direction = Direction.RIGHT
	elif event.is_action_pressed('Down'):
		self._current_direction = Direction.DOWN
	elif event.is_action_pressed('Left'):
		self._current_direction = Direction.LEFT
	elif event.is_action_pressed('Equip'):
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
			owner.sprite.flip_h = false
		Direction.DOWN:
			$LookingDir/Down.show()
			owner.hook.position = Vector2(-2, -10)
		Direction.LEFT:
			$LookingDir/Left.show()
			owner.hook.position = Vector2(6, -6)
			owner.sprite.flip_h = true
