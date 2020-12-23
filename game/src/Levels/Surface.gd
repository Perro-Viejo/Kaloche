class_name Surface
extends Area2D

export var fs_name := ''
export(Data.SurfaceType) var type = Data.SurfaceType.GROUND

var _vertices := []

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
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
	
	add_to_group('Surface')


func is_point_inside_polygon(point: Vector2) -> bool:
	for v in _vertices:
		if Geometry.is_point_in_polygon(point, v):
			return true
	return false


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _assign_sfx(body: Node) -> void:
	pass

func _stop_sfx(body: Node) -> void:
	pass
