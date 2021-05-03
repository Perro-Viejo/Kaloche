
extends Node2D
# Contiene la lógica para algunas cosas generales del Capítulo 0.1.
# Nombres de las zonas:
# - Pórtico espanta Heliodoro (colibrí pequeño)
# - Camino del regender (esfuerzo)
# - Altar Ceremonial 
# - Jardín de los Arrayanes
# - Jardín de los Curubos
# - Estanque del Payara (pez endémico)
# - Cámara de conjuros
# - Santuario de los ahogados
# - Pozo de los cantos ahogados
# - Templo del SacaPayara (caña de pescar)
# - Sendero de la iniciación
# - Puente del nacimiento/renacimiento

export var dev_entry_point: NodePath

var _follow_b_tween: Tween
var _points := []

onready var _rocberto: Pickable = find_node('Rocberto')
onready var _zone_positions: Node2D = find_node('ZonePositions')
onready var _player: Player = find_node('Player')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	for c in _zone_positions.get_children():
		_points.append(c)
	
	WorldEvent.connect('zone_position_requested', self, '_go_to_position')
	
	WorldEvent.emit_signal('world_entered', {
		points = _points
	})
	
	DebugOverlay.visible = Data.get_data(Data.SHOW_DEBUG)
	
	if OS.has_feature('editor') and get_node_or_null(dev_entry_point):
		_player.global_position = get_node(dev_entry_point).global_position


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_OverlayArea_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.name == 'Player':
		pass


func _on_OverlayArea_body_shape_exited(body_id, body, body_shape, area_shape):
	if body.name == 'Player':
		pass


func _go_to_position(id: int) -> void:
	for c in _zone_positions.get_children():
		if c.get_instance_id() == id:
			_player.global_position = c.global_position
			return
