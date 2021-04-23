class_name VFXInterface
extends Resource
# Sirve como Interfaz para los recursos de VFX, esto es, define los métodos y
# propiedades comunes a todos los VFX pero no implementa nada.
# (!) No usar este nodo para definir efectos. 

export var speed := 1.0
export var repeat := -1
export var delay := 0.0

var tween: Tween
var target: Node2D setget _set_target

var _count := 0


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func target_set() -> void:
	pass


func start() -> void:
	pass


func started() -> void:
	yield(tween, 'tween_all_completed')

	if repeat < 0 or repeat - _count > 0:
		yield(tween, 'tween_all_completed')
		if repeat > 0: _count += 1
		start()
	else:
		stop()


func stop() -> void:
	tween.remove_all()
	tween.queue_free()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _set_target(val: Node2D) -> void:
	target = val
	if is_instance_valid(target):
		target_set()
