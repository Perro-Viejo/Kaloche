class_name VFXZoomi
extends Resource

export var max_scale := 2.0
export var min_scale := 0.5
export var speed := 1.0
export var repeat := -1

var _count := 0
var _target: Node2D
var _tween: Tween
var _init_scale: Vector2

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func setup(props: Dictionary) -> void:
	_target = props.target
	_tween = props.tween
	_init_scale = props.init_scale


func start_zoomi() -> void:
	_tween.interpolate_property(
		_target, 'scale',
		_init_scale, _init_scale * max_scale,
		speed, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	_tween.interpolate_property(
		_target, 'scale',
		_init_scale * max_scale, _init_scale * min_scale,
		speed * 2, Tween.TRANS_LINEAR, Tween.EASE_OUT,
		speed
	)
	_tween.interpolate_property(
		_target, 'scale',
		_init_scale * min_scale, _init_scale,
		speed, Tween.TRANS_LINEAR, Tween.EASE_IN,
		(speed * 2) + speed
	)
	_tween.start()
	
	if repeat < 0 or (repeat + 1) - _count > 0:
		yield(_tween, 'tween_all_completed')
		if repeat > 0: _count += repeat
		start_zoomi()
