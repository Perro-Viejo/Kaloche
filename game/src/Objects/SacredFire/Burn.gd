extends "res://src/StateMachine/State.gd"

var pickable_life = 120

func _process(delta):
	if owner.is_burning and owner.pickable and owner.pickable.can_burn:
		if pickable_life > 0:
			pickable_life -= 1
			print(pickable_life)
		else:
			if owner.pickable.is_in_group('Sacred'):
				owner.eat_sacred()
			else:
				owner.eat()
func enter(msg: Dictionary = {}) -> void:
	pickable_life = owner.pickable.carbs * 30
	owner.is_burning = true
	owner.timer.set_paused(true)
	if owner.pickable.is_in_group('Sacred'):
		owner.sprite.modulate = '00e1ff'
	else:
		owner.sprite.modulate = 'f63737'
	owner.sprite.scale = owner.sprite.scale * Vector2(1.2, 1.2)
	AudioEvent.emit_signal('play_requested','Demon', 'Burn')
	AudioEvent.emit_signal('play_requested','Demon', 'Ignite')

func exit() -> void:
	owner.is_burning = false
	owner.timer.set_paused(false)
	owner.sprite.modulate = 'ffffff'
	owner.sprite.scale = Vector2.ONE
	AudioEvent.emit_signal('play_requested','Demon', 'Ignite')
	AudioEvent.emit_signal('stop_requested','Demon', 'Burn')

