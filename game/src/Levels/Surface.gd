class_name Surface
extends Area2D

const HOOK_WAVE = preload('res://src/Particles/WaterWave.tscn')

export var surface_name := ''
export(Data.SurfaceType) var type = Data.SurfaceType.GROUND
export var speed_multiplier := Vector2.ONE

# FIX: Esto no debería estar aquí sino en las clases que hereden de Surface
# y vayan a tener en cuenta el hook pa' algo.
var hook_ref: Hook = null

var _vertices := []

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	for chld in get_children():
		if chld is CollisionPolygon2D:
			# La posición del CollisionPolygon2D es su centro, así que las
			# coordenadas de sus vértices deben ser relativas al mismo. Por
			# eso hay que manipular el arreglo de Vector2 para que cada vértice
			# se 'traslade' en relación a ese centro.
			var translated_vertices: PoolVector2Array = PoolVector2Array()
			for vtx in chld.polygon:
				translated_vertices.append(vtx + chld.position)
			_vertices.append(translated_vertices)
	
	connect('body_entered', self, '_assign_sfx')
	connect('body_exited', self, '_stop_sfx')
	connect('area_entered', self, '_on_area_entered')

	add_to_group('Surface')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func is_point_inside_polygon(point: Vector2) -> bool:
	for v in _vertices:
		if Geometry.is_point_in_polygon(point, v):
			return true
	return false


# FIX: Este método debería estar sólo en las clases que hereden de esta y vayan
# a recibir el gancho o a generar ondas.
func show_wave(wave, speed = 1.0):
	var water_wave = HOOK_WAVE.instance()
	add_child(water_wave)
	if hook_ref:
		water_wave.set_global_position(hook_ref.global_position + Vector2(2, 5))
	water_wave.play_animation(wave, speed)


# Se usa por si quiere controlarse lo que pasa en el evento 'area_entered' desde
# fuera de este nodo.
func disconnect_area_listener() -> void:
	disconnect('area_entered', self, '_on_area_entered')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _assign_sfx(body: Node) -> void:
	pass


func _stop_sfx(body: Node) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	pass
