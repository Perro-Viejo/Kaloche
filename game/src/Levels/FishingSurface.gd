class_name FishingSurface
extends "res://src/Levels/Surface.gd"

"""
El orden de las variables:
signals
enums
constants
exported variables
public variables
private variables
onready variables
"""

const HOOK_SPLASH = preload("res://src/Particles/HookSplash.tscn")
const FISH_SPLASH = preload("res://src/Particles/FishSplash.tscn")
const FIGHT_SPLASH = preload("res://src/Particles/FightSplash.tscn")
const FISH_SHADOW = preload("res://src/Particles/FishShadow.tscn")

export var has_fishes := true
export var max_fish_count := 5
# Cuando ya no queden peces en el agua, tras completarse este tiempo, volverán a
# crearse peces
export var spawn_cooldown := 5 # En minutos
# export var types := []
export var bite_freq := Vector2(15.0, 30.0)

var _timer: Timer = null
var _fishes := []
var _captured_fish_idx := -1
var _bait := ''
var _counter := 0.0
var _hook_check_freq := 0.0
var _hook_ref: Hook = null
var _hooked_monitor_id := -1
var _fish_examininig := false
var _selected_fish: FishData = null
var _selected_fish_idx := 0
var _fish_examine_wait := 0.0
var _fish_examine_wait_range := Vector2(3.0, 5.0)
var _fish_examine_debug_id := -1
var _lake_fishes_debug := -1
var _fish_shadow: Node2D = null
var _polygons_2d := []
var _vertices := []
var _can_receive := true

onready var _shadows := Node2D.new() # Para agrupar los nodos de las sombras
onready var _tween := Tween.new()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	_shadows.name = 'Shadows'
	
	for chld in get_children():
		if chld is CollisionPolygon2D:
			_polygons_2d.append(chld)
	
			# La posición del CollisionPolygon2D es su centro, así que las
			# coordenadas de sus vértices deben ser relativas al mismo. Por
			# eso hay que manipular el arreglo de Vector2 para que cada vértice
			# se "traslade" en relación a ese centro.
			var translated_vertices: PoolVector2Array = PoolVector2Array()
			for vtx in chld.polygon:
				translated_vertices.append(vtx + chld.position)
			_vertices.append(translated_vertices)
	
	_timer = Timer.new()
	_timer.wait_time = spawn_cooldown
	_timer.one_shot = true
	_timer.connect('timeout', self, '_spawn_fishes')

	add_child(_timer)
	add_child(_shadows)
	add_child(_tween)

	_spawn_fishes()
	
	PlayerEvent.connect('fish_caught', self, '_on_fish_caught')
	
	connect('area_entered', self, '_on_area_entered')

func _process(delta):
	if _fish_examininig and _fish_examine_wait > 0.0:
		# Reducir el temporizador de la animación de la sombra del pez
		# examinando la carnada
		_fish_examine_wait -= delta
	elif _bait:
		# Si ya hay un gancho (con cebo) dentro del agua
		_counter += delta
		if _counter >= _hook_check_freq:
			if _got_hooked():
				DebugOverlay.remove_monitor(_hooked_monitor_id)
				_reset_bait()
				_on_fish_bit()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func hook_entered(hook: Hook) -> void:
	_hook_ref = hook
	_hook_ref.connect('sent_back', self, 'hook_exited')
	_hook_ref.connect('fish_fled', self, '_show_shadows')
	
	_hook_ref.surface_ref = self
	
	var splash = HOOK_SPLASH.instance()
	add_child(splash)
	splash.set_global_position(hook.global_position)
	AudioEvent.emit_signal(
		'play_requested', 'Fishing', 'rod_fall_long', hook.global_position
	)
	_bait = hook.bait
	_hook_check_freq = rand_range(bite_freq.x, bite_freq.y)
	_counter = 0.0
	_captured_fish_idx = -1
	_fish_examininig = false
	_selected_fish = null
	_selected_fish_idx = 0
	
	# PROBANDO: Ocultar los peces que se mueven cuando caiga el gancho para que nada
	# ocupe la atención del jugador aparte del pez que mirará el cebo.
	_tween.interpolate_property(
		_shadows, 'modulate:a',
		1.0, 0.0,
		0.8, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	_tween.start()
	
	# Pal debug
	_hooked_monitor_id = DebugOverlay.add_monitor(
		'\npez saldrá en', self, '', 'get_hooked_check_time'
	)

func hook_exited(hook: Hook = null) -> void:
	_reset_bait()
	_hook_ref.surface_ref = null
	_hook_ref.disconnect('fish_fled', self, '_show_shadows')
	_hook_ref = null
	_remove_shadow() # Quitar la sombra del pez que tantea la carnada
	
	# Volver a mostrar las sombras de los peces nadando después de un rato. Si
	# no se están viendo, hacerlos aparecer después de X segundos, de lo contrario,
	# hacerlos aparecer de inmediato.
	_show_shadows()

	# DEBUG
	DebugOverlay.remove_monitor(_hooked_monitor_id)

#TODO: conectar esta vuelta :(
#func _pull_sfx():
#	AudioEvent.emit_signal('play_requested', 'Fishing', 'pull_fish_fight', _hook_ref.global_position)


func get_hooked_check_time() -> String:
	return '%ds' % int(_hook_check_freq - _counter + 1)


func get_fishes_list() -> String:
	var names := []
	for f in _fishes:
		var fish: FishData = f as FishData
		names.append(fish.name)
	return String(names)


func get_fish_examine_wait() -> float:
	return stepify(_fish_examine_wait, 1.0) + 1.0


func is_point_inside_polygon(point: Vector2) -> bool:
	for v in _vertices:
		if Geometry.is_point_in_polygon(point, v):
			return true
	return false

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _spawn_fishes() -> void:
	for c in range(max_fish_count):
		var fish: FishData = FishingDatabase.get_random_fish()
		_fishes.append(fish)
		
		# Coger un vértice al azar y obtener un punto aleatorio entre dicho
		# vértice y el centro del polígono.
		randomize()

		var target_polygon: CollisionPolygon2D = _polygons_2d[0]
		var vertex: Vector2 = _vertices[0][randi() % _vertices[0].size()]
		# Gracias >>>
		# https://math.stackexchange.com/questions/1965497/how-can-i-find-a-random-position-between-two-points
		var u := rand_range(0.0, 0.4)
		var spawn_point: Vector2 = (1 - u) * target_polygon.position + (u * vertex)
		var shadow = FISH_SHADOW.instance()

		shadow.position = spawn_point
		shadow.surface_ref = self
		shadow.size = fish.size_str

		_shadows.add_child(shadow)

	_show_shadows()

	# DEBUG
	_lake_fishes_debug = DebugOverlay.add_monitor('\npeces', self, '', 'get_fishes_list')

func _on_fish_bit() -> void:
	_fishes.remove(_captured_fish_idx)
	
	var shadow_to_remove: FishShadow = _shadows.get_child(_captured_fish_idx)
	_shadows.remove_child(shadow_to_remove)
	shadow_to_remove.queue_free()

	if _fishes.empty():
		DebugOverlay.remove_monitor(_lake_fishes_debug)
		_timer.start()

# Verifica si algo se enganchó al gancho o si hay que volver a esperar un rato
# para volver a verificar
func _got_hooked() -> bool:
	# 1. Seleccionar el pez que va a ver la carnada
	if not _selected_fish:
		_selected_fish = null
		_selected_fish_idx = 0

		var highest_chance := 0.0
		var counter := 0
		for f in _fishes:
			var fish: FishData = f as FishData

			if _bait != 'Nada' and  fish.attracted_to.has(_bait) \
				and fish.attracted_to[_bait] > highest_chance:
				highest_chance = fish.attracted_to[_bait]
				_selected_fish = fish
				_selected_fish_idx = counter
			elif _bait == 'Nada' and fish.type == fish.Type.GEN:
				_selected_fish = fish
				_selected_fish_idx = counter

			counter += 1

	if _selected_fish:
		if not _fish_examininig:
			# 1.1. Poner al pez a examinar la carnada
			_fish_examininig = true
			_fish_examine_wait = _fish_examine_wait_range.x
			_fish_examine_debug_id = DebugOverlay.add_monitor(
				'\nexaminando carnada', self, '', 'get_fish_examine_wait'
			)
			# ubicar y reproducir animación de la sombra
			var vec
			var rot
			if _hook_ref.dflt_pos.x < 0:
				vec = Vector2.RIGHT
				rot = 0
			else:
				rot = 180
				vec = Vector2.LEFT
			_fish_shadow = FISH_SHADOW.instance()
			_fish_shadow.global_position = _hook_ref.global_position + vec * 4
			_fish_shadow.rotation_degrees = rot
			_fish_shadow.get_node('AnimationPlayer').play('examine_md')
			_fish_shadow.is_examining = true
			add_child(_fish_shadow)
		else:
			_remove_shadow()

			# 2. Determinar si el pez seleccionado muerde o no la carnada
			if randf() <= _selected_fish.attracted_to[_bait]:
				_captured_fish_idx = _selected_fish_idx
				_hook_ref.hook_success(_fishes[_captured_fish_idx])
			else:
				# TODO: Inhabilitar el pez por un tiempo para que no vuelva a intentar
				#		morder la carnada
				_counter = 0.0
				_fish_examininig = false
				_hook_check_freq = rand_range(bite_freq.x, bite_freq.y)
				_hook_ref.hook_fail()
				_show_shadows()

	return _captured_fish_idx > -1

func _on_fish_caught(position):
	var splash = FISH_SPLASH.instance()
	add_child(splash)
	splash.set_global_position(position)
	
	_show_shadows()
	_can_receive = false
	yield(get_tree().create_timer(0.5), 'timeout')
	_can_receive = true

func _fight_splash(position):
	var splash = FIGHT_SPLASH.instance()
	add_child(splash)
	splash.set_global_position(position)


func _remove_shadow() -> void:
	if _fish_shadow:
		DebugOverlay.remove_monitor(_fish_examine_debug_id)
		remove_child(_fish_shadow)
		_fish_shadow.queue_free()


func _show_shadows() -> void:
	_tween.stop_all()
	_tween.interpolate_property(
		_shadows, 'modulate:a',
		_shadows.modulate.a, 1.0,
		1.2, Tween.TRANS_SINE, Tween.EASE_OUT,
		0.0 if _shadows.modulate.a > 0.0 else 3.0
	)
	_tween.start()


func _reset_bait() -> void:
	_bait = ''
	_hook_ref.disconnect('sent_back', self, 'hook_exited')

func _on_area_entered(other) -> void:
	if _can_receive and other is Pickable:
		var splash = HOOK_SPLASH.instance()
		add_child(splash)
		splash.position = other.position
		if other.is_in_group('Sacred'):
			other.respawn()
		else:
			other.queue_free()
