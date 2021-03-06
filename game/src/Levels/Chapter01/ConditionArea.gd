extends Area2D

export var pickable_needed = ''

func _ready():
	connect('body_entered', self, '_on_body_entered')

func _on_body_entered(body: Node):
	if body.name == 'Player':
		var _body_dir = body.dir
		if body.grabbing and body.picked_item.name == pickable_needed:
			print('Bien por ti')
		else:
			$Tween.interpolate_property(
			body, 'global_position',
			body.global_position, body.global_position + Vector2(15 * -_body_dir.x, 15 * -_body_dir.y),
			0.4, Tween.TRANS_EXPO, Tween.EASE_OUT
		)
			$Tween.start()
			#Aquí debería sonar un sonido mágico y rechazador
			print('traigame a ', pickable_needed, ' att: Jesucristo ')
