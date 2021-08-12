extends Area2D

export var pickable_needed = 'Rocberto'

export var reject_force = 10

func _ready():
	connect('body_entered', self, '_on_body_entered')

func _on_body_entered(body: Node):
	if body.name == 'Player':
		var _body_dir = body.dir
		if body.grabbing and body.picked_item.name == pickable_needed:
			# Aquí va a hacer algo para el fin del DEMO, Cambia de escena
			print('Éxito en tu vida y próspero 2022')
		else:
			$Tween.interpolate_property(
				body, 'global_position',
				body.global_position, body.global_position + Vector2(reject_force * -_body_dir.x, reject_force * -_body_dir.y),
				0.4, Tween.TRANS_EXPO, Tween.EASE_OUT
			)
			$Tween.start()
