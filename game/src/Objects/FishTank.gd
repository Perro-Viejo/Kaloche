extends Node2D

signal tank_activated

const HOOK_SPLASH = preload('res://src/Particles/HookSplash.tscn')

var _is_filling = false
var _is_active = false

onready var _fishing_surfaces: Node2D = $FishingSurfaces
onready var _animation: AnimationPlayer = $AnimationPlayer
onready var _tank_surface: Area2D = $Tank/Surface


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	for s in _fishing_surfaces.get_children():
		var surface := s as FishingSurface
		surface.hide()
		surface.monitoring = false
		surface.monitorable = false
	
	# Desconectar escuchadores de los hijos
	_tank_surface.disconnect_area_listener()
	
	# Conectarse a señales de los hijastros
	_animation.connect('animation_finished', self, '_on_animation_finished')
	_tank_surface.connect('area_entered', self, '_on_area_entered')
	$TempleDoorButton.connect('button_pressed', self, 'fill_tank')
	$TempleDoorButton.connect('button_unpressed', self, 'empty_tank')
	
	# Conectarse a señales del universo de las señales
	AudioEvent.emit_signal('change_volume', 'Spot', 'FishTank', -80)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func fill_tank():
#	_tank_surface.type = Data.SurfaceType.WATER
#	_tank_surface.surface_name = 'Water'
	_is_filling = true
	AudioEvent.emit_signal('stop_requested', 'Tank', 'Empty')
	AudioEvent.emit_signal(
		'play_requested', 
		'Tank', 'Fill', 
		Vector2.ZERO, 
		_animation.get_current_animation_position() if _animation.is_playing() 
		else 0.0)
	$Holes.set_frame(1)
	_animation.play('Fill')
	if _animation.get_current_animation_position() >= 3.6:
		AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_Covered', global_position)
	else:
		AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_Uncovered', global_position)


func empty_tank():
	_is_filling = false
	AudioEvent.emit_signal('stop_requested', 'Tank', 'Fill')
	$Holes.set_frame(0)
	_animation.play_backwards('Fill')
	AudioEvent.emit_signal('play_requested', 'Tank', 'Empty_Start')
	AudioEvent.emit_signal(
		'play_requested', 
		'Tank', 'Empty', 
		Vector2.ZERO, 
		_animation.get_current_animation_length() - _animation.get_current_animation_position() if _animation.is_playing() 
		else 0.0)


func activate_tank():
	AudioEvent.emit_signal('change_volume', 'Spot', 'FishTank', 10)
	AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_End')
	_is_active = true
	DialogEvent.emit_signal('dialog_requested', 'Chapter0.1/DPayaraPond', 'tank_filled')
	emit_signal('tank_activated')
	$TempleDoorButton.is_toggle = true
	for s in _fishing_surfaces.get_children():
		var surface := s as FishingSurface
		surface.show()
		surface.monitoring = true
		surface.monitorable = true


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_animation_finished(anim):
	if _animation.get_current_animation_position() == _animation.get_current_animation_length():
		activate_tank()
#	if _animation.get_current_animation_position() == 0:
#		_tank_surface.type = Data.SurfaceType.ROCK
#		_tank_surface.surface_name = 'Rock'


func _on_area_entered(other) -> void:
	var splash = HOOK_SPLASH.instance()
	if other is Pickable:
		if _is_active or _is_filling:
			add_child(splash)
			splash.global_position = other.global_position
		else:
			yield(get_tree().create_timer(0.5), 'timeout')
		if other.is_in_group('Sacred'):
			other.hide()
			if other.name == 'Rocberto':
				AudioEvent.emit_signal('play_requested', 'Rocberto', 'Disappear')
			yield(get_tree().create_timer(1.5), 'timeout')
			other.respawn($Respawn.global_position)
			if other.name == 'Rocberto':
				AudioEvent.emit_signal('play_requested', 'Rocberto', 'Respawn')
		else:
			if _is_active or _is_filling:
				other.queue_free()
