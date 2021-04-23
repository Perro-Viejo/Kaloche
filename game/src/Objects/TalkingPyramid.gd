extends Actor

var awake = false

func _ready():
	$InteractionArea.connect('body_entered', self, '_on_body_entered')

func _on_body_entered(body: Node)  -> void:
	if body.name == 'Player':
		sleep()

func wake_up() -> void:
	awake = true
	$Sprite.frame = 0
	$LightMask.texture_scale = 5.7

func sleep() -> void:
	awake = false
	$Sprite.frame = 1
	$LightMask.texture_scale = 3
