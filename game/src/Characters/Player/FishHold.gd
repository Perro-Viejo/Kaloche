extends "res://src/StateMachine/State.gd"

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _hook: Hook = null

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	owner.is_paused = true
	if owner.rod_tip.position.x < 0:
		owner.rod_tip.position = owner.rod_tip_offset
	else:
		owner.rod_tip.position = Vector2(
			owner.rod_tip_offset.x *-1, owner.rod_tip_offset.y
		)
	_hook = owner.hook
	_hook.connect('hooked', self, '_on_fish_hooked')
#	-> Aquí era cuando el pez no mordía
#	_hook.connect('tried', owner, 'speak', ['Uy... casi muerde'])
	_hook.connect('sent_back', _state_machine, 'transition_to_key', ['Idle'])
	_hook.connect('fish_fled', self, '_on_fish_fled')

	.enter(msg)


func exit() -> void:
	owner.is_paused = false
	owner.fishing = false
	owner.hook_target.position = Vector2.ZERO
	_hook.disconnect('hooked', self, '_on_fish_hooked')
#	_hook.disconnect('tried', owner, 'speak')
	_hook.disconnect('sent_back', _state_machine, 'transition_to_key')
	_hook.disconnect('fish_fled', self, '_on_fish_fled')

	.exit()


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('Action'):
		# TODO: Aquí hay que enviar la fuerza de la caña dependiendo de su tipo
		var pull_result := owner.hook.pull_done(1.3) as Dictionary
		
		if not pull_result:
			return
		#Juan: ¿creo que este se puede quitar?
		if pull_result.escaped:
			var responses = [
				'Pescaito berriondo...',
				'¡Jala arrecho este bicho!',
				'jalo, jalo, jalo...'
			]
			responses.shuffle()
			owner.speak(tr(responses[0]))
		elif pull_result.lost:
			owner.fishing_zoom(false)
			owner.speak(tr('Ta muy gordo este hp'))
		elif pull_result.caught:
			owner.fishing_zoom(false)
			owner.speak(tr('Te atrapé pedazo de mierda'))
			_state_machine.transition_to_key('Idle')
		elif pull_result.fighting:
			owner.fishing_zoom(true)
#			
#			-> Estas eran las respuestas de la pelea
#			var responses = [
#				'Pescaito berriondo...',
#				'¡Jala arrecho este bicho!',
#				'jalo, jalo, jalo...',
#				'GJRLkgjlerkjglerkgjelgrkj'
#			]
#			responses.shuffle()
#			randomize()
#			var ran_num = randf()
#			if ran_num <= 0.1: 
#				owner.speak(tr(responses[0]))


func _on_fish_fled() -> void:
	owner.fishing_zoom(false)
	owner.speak(tr('Se voló el bagrese...'))
	_state_machine.transition_to_key('Idle')

func _on_fish_hooked() -> void:
	owner.react()
