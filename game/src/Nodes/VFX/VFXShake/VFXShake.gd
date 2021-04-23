class_name VFXShake
extends VFXInterface
# Hace temblar a un nodo. Si fixed_strength es verdadero, entonces el movimiento
# se hace con el valor fijo de la fuerza. De lo contrario, el movimiento se hará
# con un valor aleatorio, cuyo valor máximo será el definido en la fuerza.

export var shake_strength := Vector2.ZERO
export var fixed_strength := false

const NAME := 'shake'

var _init_position: Vector2


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func start() -> void:
	# Mover el nodo hacia el rango positivo de la fuerza
	tween.interpolate_property(
		target, 'position',
		_init_position,
		_init_position + Vector2(
			_get_base() * shake_strength.x,
			_get_base() * shake_strength.y
		),
		speed, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	# Mover el nodo hacia el rango negativo de la fuerza
	tween.interpolate_property(
		target, 'position',
		_init_position,
		_init_position - Vector2(
			_get_base() * shake_strength.x,
			_get_base() * shake_strength.y
		),
		speed, Tween.TRANS_LINEAR, Tween.EASE_OUT,
		speed * 2
	)

	tween.start()
	started()


func stop() -> void:
	target.position = _init_position
	.stop()


func target_set() -> void:
	_init_position = target.position


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _get_base() -> float:
	if fixed_strength: return 1.0
	
	# El rand_rage se hace así para que funcione la ida y vuelta del shake cuando
	# se hace una fuerza fija (sin randomización).
	randomize()
	return rand_range(0.0, 1.0)
