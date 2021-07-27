extends Node2D


func _ready():
	$Area2D.connect('body_entered', self, '_on_body_entered')


func _on_body_entered(body: Node):
	if body.name == 'Player':
		AudioEvent.emit_signal('play_requested', 'Bridge', 'Break', global_position)
		$AnimationPlayer.play('Break')
		$Area2D.set_deferred('monitoring', false)
		yield(get_tree().create_timer(0.6), 'timeout')
		DialogEvent.emit_signal('dialog_requested', 'Chapter0.1/DInitiationPath', 'bridge_broke')
