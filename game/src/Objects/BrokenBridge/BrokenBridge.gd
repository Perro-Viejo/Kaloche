extends Node2D


func _ready():
	$Area2D.connect('body_entered', self, '_on_body_entered')


func _on_body_entered(body: Node):
	if body.name == 'Player':
		AudioEvent.emit_signal('play_requested', 'Bridge', 'Break', global_position)
		$AnimationPlayer.play('Break')
		$Area2D.set_deferred('monitoring', false)
