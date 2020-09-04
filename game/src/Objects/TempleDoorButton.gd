extends Node2D
# ⠿⠿⠿⠿ Variables ⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿
signal button_pressed

var _pressed := false

# ⠿⠿⠿⠿ Functions ⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿
func _ready() -> void:
	$Area2D.connect('body_entered', self, '_on_pressed')

func _on_pressed(body: Node) -> void:
	if not _pressed and body.name == 'Player':
		_pressed = true
		$Area2D.disconnect('body_entered', self, '_on_pressed')
		
		$AnimationPlayer.play('press')
		yield(get_tree().create_timer(0.1), 'timeout')
		emit_signal('button_pressed')
