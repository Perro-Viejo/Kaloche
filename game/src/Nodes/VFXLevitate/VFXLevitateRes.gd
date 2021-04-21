class_name VFXLevitateRes
extends Resource

export var distance := 5.0
export var speed := 1.0
export var repeat := -1

var _count := 0
var _target: Node2D
var _tween: Tween
var _init_pos: Vector2

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func setup(props: Dictionary) -> void:
	_target = props.target
	_tween = props.tween
	_init_pos = props.init_pos


func start_floating() -> void:
	_tween.interpolate_property(
		_target, 'position:y',
		_init_pos.y, _init_pos.y + distance,
		speed, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	_tween.interpolate_property(
		_target, 'position:y',
		_init_pos.y + distance, _init_pos.y - distance,
		speed * 2, Tween.TRANS_SINE, Tween.EASE_OUT,
		speed
	)
	_tween.interpolate_property(
		_target, 'position:y',
		_init_pos.y - distance, _init_pos.y,
		speed, Tween.TRANS_LINEAR, Tween.EASE_IN,
		(speed * 2) + speed
	)
	_tween.start()
	
	if repeat < 0 or (repeat + 1) - _count > 0:
		yield(_tween, 'tween_all_completed')
		if repeat > 0: _count += repeat
		start_floating()


func stop_floating() -> void:
	_tween.remove_all()
