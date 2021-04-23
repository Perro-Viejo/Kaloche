extends "res://src/StateMachine/State.gd"


func enter(msg: Dictionary = {}) -> void:
	owner.tween.connect('tween_completed', self, '_on_tween_completed')
	owner.tween.interpolate_property(
		owner.sprite, ":scale",
		owner.sprite.scale, Vector2.ZERO,
		2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.0
	)
	owner.tween.start()
func _on_tween_completed(obj, key) -> void:
	owner.tween.disconnect('tween_completed', self, '_on_tween_completed')
	owner.queue_free()
