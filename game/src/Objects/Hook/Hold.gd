# El gancho está esperando a que algo se le enganche
extends "res://src/StateMachine/State.gd"

# Determina cuánto tiempo pasará antes de verificar la superficie en la que
# cayó el gancho para saber si es o no una zona de pesca
export var _idle_anim_interval := Vector2(0.5, 2.0)
export var _wave_anim_interval := Vector2(3.6, 12.9)

var _pull_done := false

onready var _small_wave_timer: Timer = Timer.new()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	yield(owner, 'ready')

	# El timerocho
	_small_wave_timer.wait_time = _wave_anim_interval.x
	_small_wave_timer.one_shot = true
	_small_wave_timer.connect('timeout', self, '_show_small_wave')
	add_child(_small_wave_timer)
	
	owner.connect('tried', self, '_on_hook_failed')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func enter(msg: Dictionary = {}) -> void:
	_pull_done = false
	
	_play_sfx()
	_check_surface()


func exit() -> void:
#	Juan: no se si debería estar esta animación por que tiene un espacio antes
#	que le quita impacto a la mordida, puede ser quitar el espacio o hacer una 
#	animación específica para este con el mismo sprite
 
#	owner.play_animation('waveB')

	if owner.surface_ref:
		if owner.surface_ref.type == Data.SurfaceType.WATER:
			_small_wave_timer.stop()
		
		if _pull_done and owner.surface_ref.is_in_group('FishingSurface'):
			owner.surface_ref.hook_exited(owner)
			

#	owner.surface_ref = null
	.exit()


func pull_done(rod_strength: float) -> Dictionary:
	_pull_done = true
	owner.play_animation('waveB')
	_sent_back()
	return {}


func surface_updated() -> void:
	_check_surface()


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _sent_back() -> void:
	owner.emit_signal('sent_back')
	_state_machine.transition_to_key('Idle')


func _show_small_wave() -> void:
	owner.play_animation('waveA', 1.5)
	_small_wave_timer.start()


# Un pez se fijó en el cebo pero al final no lo mordió porque los peces no son
# tan pendejos a veces
func _on_hook_failed() -> void:
	_small_wave_timer.stop()
	owner.play_animation('waveB')
	# Esperar X segundos antes de retomar el ciclo de mostrar la onda pequeña
	_small_wave_timer.wait_time = 4.0
	_small_wave_timer.start()


func _play_sfx() -> void:
	AudioEvent.emit_signal(
		'play_requested', 'Hook', owner.surface_type, owner.global_position
	)


func _check_surface() -> void:
	if owner.surface_ref:
		if owner.surface_ref.type == Data.SurfaceType.WATER:
			_small_wave_timer.start()
			owner.play_animation('waveB', 3.0)
			owner.emit_signal('dropped')
			if owner.surface_ref.is_in_group('FishingSurface'):
				owner.surface_ref.hook_entered(owner)
			return
		else:
			owner.surface_ref.hook_ref = null
	_sent_back()
