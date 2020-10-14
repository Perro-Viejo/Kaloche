extends "res://src/StateMachine/State.gd"

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables públicas ▒▒▒▒
var min_distance := 24.0
var max_distance := 75.0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _current_direction: int = Direction.RIGHT setget _set_direction

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	owner.is_paused = true
	owner.fishing = true
	owner.hook.visible = true
	owner.hook.position -= Vector2(5, 5)
	(owner.hook as Hook).connect(
		'dropped', _state_machine, 'transition_to_key', ['FishHold']
	)
	.enter(msg)

func exit() -> void:
	owner.is_paused = false
	owner.hook.disconnect(
		'dropped', _state_machine, 'transition_to_key'
	)
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
			Direction.DOWN:
				hook_pos = Vector2(0, distance)
			Direction.LEFT:
				hook_pos = Vector2(distance * -1, 0)
			Direction.RIGHT:
				hook_pos = Vector2(distance, 0)

		owner.hook.target_pos = hook_pos
	elif event.is_action_pressed('Up'):
		self._current_direction = Direction.UP
	elif event.is_action_pressed('Right'):
		self._current_direction = Direction.RIGHT
	elif event.is_action_pressed('Down'):
		self._current_direction = Direction.DOWN
	elif event.is_action_pressed('Left'):
		self._current_direction = Direction.LEFT

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _set_direction(dir: int) -> void:
	_current_direction = dir
	
	for color_rect in $LookingDir.get_children():
		color_rect.hide()

	match _current_direction:
		Direction.UP:
			$LookingDir/Up.show()
			owner.hook.position = Vector2(-2, 8)
		Direction.RIGHT:
			$LookingDir/Right.show()
			owner.hook.position = Vector2(-10, 1)
			owner.sprite.flip_h = false
		Direction.DOWN:
			$LookingDir/Down.show()
			owner.hook.position = Vector2(-2, -10)
		Direction.LEFT:
			$LookingDir/Left.show()
			owner.hook.position = Vector2(7, 1)
			owner.sprite.flip_h = true
