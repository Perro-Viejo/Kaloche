class_name VisibilityDisabler
extends Node2D
# Recorre todos los hijos del nodo y los inhabilita o habilita dependiendo de
# la visibilidad del nodo padre. Esto se aplica a nodos StaticBody2D, ZIndexChanger,
# y Light2D.

export var root_path: NodePath = '../'
export(Array, NodePath) var ignore_childs = []
export var toggle_on_ready := true

var _ids_to_ignore := []

onready var _root: Node2D = get_node(root_path)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	for p in ignore_childs:
		_ids_to_ignore.append(get_node(p).get_instance_id())

	_root.connect('visibility_changed', self, 'toggle_colliders')
	
	# La verificación de estado inicial
	if toggle_on_ready:
		yield(get_parent(), 'ready')
		_toggle_colliders(_root)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func force_disable() -> void:
	_toggle_colliders(_root, true)


func toggle_colliders() -> void:
	_toggle_colliders(_root)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _toggle_colliders(node: Node2D = self, force_disable := false) -> void:
	var target_state: bool = false if force_disable else _root.visible
	
	for c in node.get_children():
		if c is StaticBody2D:
			(c as StaticBody2D).collision_mask = 0 if not target_state else 1
		elif c is Area2D:
			if target_state and (c is CollisionEnabler or c is ZIndexChanger):
				# Para que se configure el nodo en el estado por defecto
				(c as Area2D).monitorable = true
				(c as Area2D).monitoring = true
				c.ready_setup()
			else:
				(c as Area2D).monitorable = target_state
				(c as Area2D).monitoring = target_state
		elif c is Light2D:
			(c as Light2D).enabled = target_state

		if not c.get_children().empty():
			if not _ids_to_ignore.has(c.get_instance_id()):
				_toggle_colliders(c, force_disable)
