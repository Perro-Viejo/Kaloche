extends Actor

export var awake = false
export(Color) var light_color

func _ready():
	if awake:
		wake_up()
	$LightSprite.modulate = light_color
	$InteractionArea.connect('body_entered', self, '_on_body_entered')

func _on_body_entered(body: Node)  -> void:
	if body.name == 'Player':
		sleep()

func wake_up() -> void:
	if $Sprite/VFXHandler:
		$Sprite/VFXHandler.start_vfx(['levitate'])
	$Fire.show()
	$LightSprite.show()
	awake = true
	$Sprite.frame = 0
	$LightMask.texture_scale = 5.7

func sleep() -> void:
	$Fire.hide()
	$LightSprite.hide()
	awake = false
	$Sprite.frame = 1
	$LightMask.texture_scale = 3
