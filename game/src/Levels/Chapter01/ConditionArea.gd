extends Area2D

export var pickable_needed = ''

export var reject_force = 0

export var active = true

func _ready():
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')

func _on_body_entered(body: Node):
	if active:
		if body.name == 'Player':
			var _body_dir = body.dir
			if body.grabbing and body.picked_item.name == pickable_needed:
				pass
			else:
				# Esto  empuja el jugador cuando no tiene el pickable
				$Tween.interpolate_property(
				body, 'global_position',
				body.global_position, body.global_position + Vector2(reject_force * -_body_dir.x, reject_force * -_body_dir.y),
				0.4, Tween.TRANS_EXPO, Tween.EASE_OUT
			)
				$Tween.start()

				# TODO: Aquí debería sonar un sonido mágico y rechazador

func _on_body_exited(body: Node):
	if active:
		if body.name == 'Player':
			pass
