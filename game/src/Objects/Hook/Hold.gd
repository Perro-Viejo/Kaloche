# El gancho está esperando a que algo se le enganche
extends "res://src/StateMachine/State.gd"

export var _check_surface_wait := 1.0 # En segundos

var _area_ref: Area2D = null
var _surface_detected := false
var _check_surface_counter := 0.0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	yield(owner, 'ready')
	_area_ref = owner.area

func physics_process(delta: float) -> void:
	_check_surface_counter -= delta
	if _check_surface_counter < 0 and not _surface_detected:
		_sent_back()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	_check_surface_counter = _check_surface_wait
	_area_ref.connect('area_entered', self, '_on_area_entered')
	_area_ref.monitoring = true
	_surface_detected = false

func exit() -> void:
	_surface_detected = false
	_area_ref.disconnect('area_entered', self, '_on_area_entered')
	_area_ref.monitoring = false
	.exit()

func pull_done(rod_strength: float) -> Dictionary:
	_sent_back()
	return {}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_area_entered(body: Area2D) -> void:
	_surface_detected = true
	var surface: Surface = body
	if surface.type == Data.SurfaceType.WATER:
		owner.emit_signal('dropped')
		body.hook_entered(owner)
	else:
		body._hook_ref = null
		_sent_back()

func _sent_back() -> void:
	_state_machine.transition_to_key('Idle')
	owner.emit_signal('sent_back')
