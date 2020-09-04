extends Node2D



func _on_OverlayArea_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.name == 'Player':
		pass
#		$Player/AnimationPlayer.play('idle')
#		$Player/Overlay.show()


func _on_OverlayArea_body_shape_exited(body_id, body, body_shape, area_shape):
	if body.name == 'Player':
		pass
#		$Player/AnimationPlayer.stop()
#		$Player/Overlay.hide()
