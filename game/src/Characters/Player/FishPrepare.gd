extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	_parent.fishing = true
	_parent._hook.visible = true
	_parent._hook.position -= Vector2(5, 5)
	(_parent._hook as Hook).connect(
		'dropped', _state_machine, 'transition_to_key', ['FishHold']
	)
	.enter(msg)

func exit() -> void:
	_parent._hook.disconnect(
		'dropped', _state_machine, 'transition_to_key'
	)
	.exit()

func _unhandled_input(event: InputEvent) -> void:
	if _parent.is_paused: return

	if event.is_action_pressed('Drop'):
		_parent._hook.target_pos = Vector2(150, 0)

func play_animation() -> bool:
	sprite.play('default')
	return true
