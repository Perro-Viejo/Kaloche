extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(String, FILE, "*.tscn") var Next_Scene: String
export(Array, String) var zone_names
export(String) var world_name = 'WORLD'

var _current_zone: String setget _set_current_zone

onready var _zones: Area2D = $WorldLayer/Zones
onready var _player: Player = $WorldLayer/Player
onready var _tween: Tween = $WorldLayer/Tween
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	# Conectar señales de las zonas del mundo pokémon
	_zones.connect('area_shape_entered', self, '_zone_entered', [ true ])
	_zones.connect('area_shape_exited', self, '_zone_entered', [ false ])

	# Establecer valores por defecto
	self._current_zone = ''

	# Verificar si el personaje está dentro de una zona
	yield(get_tree().create_timer(0.2), 'timeout')
	if _current_zone == world_name:
		_player.change_zoom()


func _set_current_zone(val: String) -> void:
	_current_zone = val if val != '' else world_name


func _on_Button_pressed()->void:
	Event.emit_signal("ChangeScene", Next_Scene)


func _zone_entered(
		area_id: int,
		area: Area2D,
		area_shape: int,
		self_shape: int,
		entered: bool
	) -> void:

	var zone: Zone = _zones.get_child(self_shape) as Zone

	if entered:
		self._current_zone = tr(zone.tr_name)
	else:
		self._current_zone = ''

	yield(_player.change_zoom(!entered), 'completed')
	Event.emit_signal('zone_entered', _current_zone)

	if zone.music:
		if entered:
			Event.emit_signal('music_requested', zone.music)
		else:
			Event.emit_signal('music_stoped')
