# El gancho está esperando a que algo se le enganche
extends "res://src/StateMachine/State.gd"

# Determina cuánto tiempo pasará antes de verificar la superficie en la que
# cayó el gancho para saber si es o no una zona de pesca
export var _check_surface_wait := 1.0 # En segundos
export var _idle_anim_interval := Vector2(0.5, 2.0)
export var _wave_anim_interval := Vector2(3.6, 12.9)

var _area_ref: Area2D = null
var _surface_detected := false
var _check_surface_counter := 0.0

onready var _timer: Timer = Timer.new()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	yield(owner, 'ready')
	_area_ref = owner.area

	# El timerocho
	_timer.wait_time = _wave_anim_interval.x
	_timer.one_shot = true
	_timer.connect('timeout', self, '_on_timeout')
	add_child(_timer)
	
	owner.connect('tried', self, '_on_hook_failed')

func physics_process(delta: float) -> void:
	_check_surface_counter -= delta
	if _check_surface_counter < 0 and not _surface_detected:
		_sent_back()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	_check_surface_counter = _check_surface_wait
	_area_ref.connect('area_entered', self, '_on_area_entered')
	_area_ref.connect('area_exited', self, '_on_area_exited')
	_area_ref.monitoring = true
	_surface_detected = false
	owner.play_animation('idle', 1.5)
	_timer.start()

func exit() -> void:
	_surface_detected = false
	_area_ref.disconnect('area_entered', self, '_on_area_entered')
	_area_ref.disconnect('area_exited', self, '_on_area_exited')
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

func _on_area_exited(body: Area2D) -> void:
	var surface: Surface = body
	if surface.type == Data.SurfaceType.WATER:
		body.hook_exited(owner)

func _sent_back() -> void:
	_state_machine.transition_to_key('Idle')
	owner.emit_signal('sent_back')

func _on_timeout() -> void:
	owner.play_animation('waveA', 1.5)
	_timer.start()

# Un pez se fijó en el cebo pero al final no lo mordió porque los peces no son
# tan pendejos a veces
func _on_hook_failed() -> void:
	_timer.stop()
	owner.play_animation('waveB')
	# Esperar X segundos antes de retomar el ciclo de mostrar la onda pequeña
	_timer.wait_time = 4.0
	_timer.start()
