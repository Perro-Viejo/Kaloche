class_name VFXLevitate
extends VFXInterface

export var distance := 5.0

const NAME := 'levitate'

var _init_position: Vector2

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func start() -> void:
	tween.interpolate_property(
		target, 'position:y',
		_init_position.y, _init_position.y + distance,
		speed, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	tween.interpolate_property(
		target, 'position:y',
		_init_position.y + distance, _init_position.y - distance,
		speed * 2, Tween.TRANS_SINE, Tween.EASE_OUT,
		speed
	)
	tween.interpolate_property(
		target, 'position:y',
		_init_position.y - distance, _init_position.y,
		speed, Tween.TRANS_LINEAR, Tween.EASE_IN,
		(speed * 2) + speed
	)
	tween.start()
	
	started()


func stop() -> void:
	target.position = _init_position
	tween.remove_all()
	tween.queue_free()


func target_set() -> void:
	_init_position = target.position
