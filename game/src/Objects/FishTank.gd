extends Node2D

const HOOK_SPLASH = preload('res://src/Particles/HookSplash.tscn')

export (NodePath) var rod_temple_path = ''

var rod_temple

var _is_filling = false
var _is_active = false

onready var _z_index_changer: Area2D = $ZIndexChanger
onready var _fishing_surfaces: Node2D = $FishingSurfaces
onready var _animation: AnimationPlayer = $AnimationPlayer

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	rod_temple = get_node(rod_temple_path)
	for s in _fishing_surfaces.get_children():
		var surface := s as FishingSurface
		surface.hide()
		surface.monitoring = false
		surface.monitorable = false
	
	# Conectarse a señales de los hijastros
	$Tank/Area2D.connect('area_entered', self, '_on_area_entered')
	$TempleDoorButton.connect('button_pressed', self, 'fill_tank')
	$TempleDoorButton.connect('button_unpressed', self, 'empty_tank')
	_animation.connect('animation_finished', self, '_on_animation_finished')
	AudioEvent.connect('stream_finished', self, '_on_stream_finished')
	_z_index_changer.connect('area_entered', self, '_change_z_index', [true])
	_z_index_changer.connect('area_exited', self, '_change_z_index', [false])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func fill_tank():
	$Tank/Area2D.type = Data.SurfaceType.WATER
	$Tank/Area2D.fs_name = 'Water'
	_is_filling = true
	AudioEvent.emit_signal('stop_requested', 'Tank', 'Empty_Loop')
	AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_Start', global_position)
	$Holes.set_frame(1)
	_animation.play('Fill')

func empty_tank():
	_is_filling = false
	AudioEvent.emit_signal('stop_requested', 'Tank', 'Fill_Loop')
	AudioEvent.emit_signal('play_requested', 'Tank', 'Empty_Loop', global_position)
	AudioEvent.emit_signal('play_requested', 'Tank', 'Empty_Start', global_position)
	$Holes.set_frame(0)
	_animation.play_backwards('Fill')


func activate_tank():
	AudioEvent.emit_signal('stop_requested', 'Tank', 'Fill_Loop')
	AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_Full')
	_is_active = true
	rod_temple.emerge()
	$TempleDoorButton.is_toggle = true
	for s in _fishing_surfaces.get_children():
		var surface := s as FishingSurface
		surface.show()
		surface.monitoring = true
		surface.monitorable = true


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_animation_finished(anim):
	if _animation.get_current_animation_position() == _animation.get_current_animation_length():
		activate_tank()
	if _animation.get_current_animation_position() == 0:
		$Tank/Area2D.type = Data.SurfaceType.ROCK
		$Tank/Area2D.fs_name = 'Rock'
		AudioEvent.emit_signal('stop_requested', 'Tank', 'Empty_Loop')
		AudioEvent.emit_signal('play_requested', 'Tank', 'Empty_Tail', global_position)

func _on_stream_finished(source, sound):
	if _is_filling:
		if sound == 'Fill_Start':
			AudioEvent.emit_signal('play_requested', 'Tank', 'Fill_Loop', global_position)
		


func _change_z_index(body: Area2D, entered: bool) -> void:
	if body.name == 'FootArea':
		$Columns.z_index = 2 if entered else 3
		$Arch.z_index = 2 if entered else 3


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
			yield(get_tree().create_timer(1.5), 'timeout')
			other.respawn($Respawn.global_position)
		else:
			if _is_active or _is_filling:
				other.queue_free()
