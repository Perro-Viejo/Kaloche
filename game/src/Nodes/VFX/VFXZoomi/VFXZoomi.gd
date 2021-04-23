class_name VFXZoomi
extends VFXInterface

export var max_scale := 2.0
export var min_scale := 0.5

const NAME := 'zoomi'

var _init_scale: Vector2


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func start() -> void:
	tween.interpolate_property(
		target, 'scale',
		_init_scale, _init_scale * max_scale,
		speed, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	tween.interpolate_property(
		target, 'scale',
		_init_scale * max_scale, _init_scale * min_scale,
		speed * 2, Tween.TRANS_LINEAR, Tween.EASE_OUT,
		speed
	)
	tween.interpolate_property(
		target, 'scale',
		_init_scale * min_scale, _init_scale,
		speed, Tween.TRANS_LINEAR, Tween.EASE_IN,
		(speed * 2) + speed
	)
	tween.start()

	started()


func stop() -> void:
	target.scale = _init_scale
	.stop()


func target_set() -> void:
	_init_scale = target.scale
