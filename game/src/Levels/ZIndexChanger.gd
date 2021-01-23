extends Area2D
class_name ZIndexChanger

export var zindex_on_entered := 0
export var zindex_on_exited := 4
export(Array, NodePath) var involved_nodes := []

var _involved_nodes := []


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	for p in involved_nodes:
		_involved_nodes.append(get_node(p))
	connect('area_entered', self, '_change_z_index', [true])
	connect('area_exited', self, '_change_z_index', [false])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _change_z_index(body: Area2D, entered: bool) -> void:
	if body.name == 'FootArea':
		var target_zindex := zindex_on_entered if entered else zindex_on_exited
		get_parent().z_index = target_zindex
		for n in _involved_nodes:
			if n:
				# Esto corrige un error que puede ocurrir si el nodo guardado en
				# el arreglo ha sido eliminado
				n.z_index = target_zindex
