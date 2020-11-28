extends "res://src/StateMachine/State.gd"

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _hook: Hook = null

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	owner.is_paused = true
	if owner.rod_tip.position.x < 0:
		owner.rod_tip.position = owner.rod_tip_offset
	else:
		owner.rod_tip.position = Vector2(owner.rod_tip_offset.x *-1, owner.rod_tip_offset.y)
	_hook = owner.hook
	_hook.connect('hooked', owner, 'speak', ['¡Mordió!'])
	_hook.connect('tried', owner, 'speak', ['Uy... casi muerde'])
	_hook.connect('sent_back', _state_machine, 'transition_to_key', ['Idle'])

	.enter(msg)


func exit() -> void:
	owner.is_paused = false
	owner.fishing = false
	_hook.disconnect('hooked', owner, 'speak')
	_hook.disconnect('tried', owner, 'speak')
	_hook.disconnect('sent_back', _state_machine, 'transition_to_key')

	.exit()


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('Action'):
		# TODO: Aquí hay que enviar la fuerza de la caña dependiendo de su tipo
		var pull_result := owner.hook.pull_done(1.3) as Dictionary
		
		if not pull_result: return
		if pull_result.escaped:
			var responses = [
				'Pescaito berriondo...',
				'¡Jala arrecho este bicho!',
				'jalo, jalo, jalo...'
			]
			responses.shuffle()
			owner.speak(tr(responses[0]))
		elif pull_result.lost:
			owner.speak(tr('Ta muy gordo este hp'))
		elif pull_result.caught:
			owner.speak(tr('Te atrapé pedazo de mierda'))
			_state_machine.transition_to_key('Idle')
		elif pull_result.fighting:
			AudioEvent.emit_signal('play_requested', 'Fishing', 'pull_fish_fight', _hook.global_position)
			owner.speak(tr('GJRLkgjlerkjglerkgjelgrkj'))
