class_name VFXGrow
extends VFXInterface

const NAME := 'grow'


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func start() -> void:
	tween.interpolate_property(
		target, 'scale',
		Vector2.ZERO, Vector2.ONE,
		speed, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	tween.start()
	
	started()


func stop() -> void:
	.stop()


func target_set() -> void:
	target.scale = Vector2.ZERO
