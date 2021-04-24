class_name VFXGrow
extends VFXInterface

const NAME := 'grow'

export var scale_to := Vector2.ONE


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func start() -> void:
	tween.interpolate_property(
		target, 'scale',
		Vector2.ZERO, scale_to,
		speed, Tween.TRANS_SINE, Tween.EASE_OUT,
		start_delay
	)
	tween.start()
	
	started()


func stop() -> void:
	.stop()


func target_set() -> void:
	target.scale = Vector2.ZERO
