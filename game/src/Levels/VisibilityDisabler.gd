class_name VisibilityDisabler
extends Node2D
# Recorre todos los hijos del nodo y los inhabilita o habilita dependiendo de
# la visibilidad del nodo padre. Esto se aplica a nodos StaticBody2D, ZIndexChanger,
# y Light2D.

export var root_path: NodePath = '../'
export(Array, NodePath) var ignore_childs = []

var _ids_to_ignore := []

onready var _root: Node2D = get_node(root_path)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	for p in ignore_childs:
		_ids_to_ignore.append(get_node(p).get_instance_id())

	_root.connect('visibility_changed', self, '_toggle_colliders', [_root])
	
	# La verificación de estado inicial
	_toggle_colliders(_root)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func force_toggle() -> void:
	_toggle_colliders(_root, true)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _toggle_colliders(node: Node2D = self, force := false) -> void:
	for c in node.get_children():
		if c is StaticBody2D:
#			(c as StaticBody2D).collision_layer = 0 if not _root.visible else 1
			(c as StaticBody2D).collision_mask = 0 if not _root.visible else 1
		elif c is Area2D:
			(c as Area2D).monitorable = _root.visible
			(c as Area2D).monitoring = _root.visible
		elif c is Light2D:
			(c as Light2D).enabled = _root.visible

		if not c.get_children().empty():
			if not _ids_to_ignore.has(c.get_instance_id()) or force:
				_toggle_colliders(c)
