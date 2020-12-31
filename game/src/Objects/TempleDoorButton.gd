extends Node2D
# ⠿⠿⠿⠿ Variables ⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿
signal button_pressed
signal button_unpressed

var _pressed := false

export var is_toggle := true
export var needs_grabbing := true

export var pickable_needed := ''

# ⠿⠿⠿⠿ Functions ⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿
func _ready() -> void:
	$Area2D.connect('body_entered', self, '_on_pressed')
	$Area2D.connect('body_exited', self, '_on_unpressed')

func _on_pressed(body: Node) -> void:
	if not _pressed and body.name == 'Player':
		if body.grabbing == needs_grabbing:
			if pickable_needed == '' or body.picked_item.name == pickable_needed:
				_pressed = true
				$Area2D.disconnect('body_entered', self, '_on_pressed')
				$Area2D.connect('body_entered', self, '_on_unpressed')
				
				$AnimationPlayer.play('press')
				AudioEvent.emit_signal('play_requested','Button','Down', position)
				yield(get_tree().create_timer(0.1), 'timeout')
				emit_signal('button_pressed')

func _on_unpressed(body: Node) -> void:
	if not is_toggle:
		if _pressed and body.name == 'Player':
			_pressed = false
			$Area2D.connect('body_entered', self, '_on_pressed')
			$Area2D.disconnect('body_entered', self, '_on_unpressed')
			
			$AnimationPlayer.play_backwards('press')
			AudioEvent.emit_signal('play_requested','Button','Up', position)
			yield(get_tree().create_timer(0.1), 'timeout')
			emit_signal('button_unpressed')
