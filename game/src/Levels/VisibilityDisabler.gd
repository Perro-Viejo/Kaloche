class_name VisibilityDisabler
extends Node2D
# Recorre todos los hijos del nodo y los inhabilita o habilita dependiendo de
# la visibilidad del nodo padre. Esto se aplica a nodos StaticBody2D, ZIndexChanger,
# y Light2D.

export var root_path: NodePath = '../'
export(Array, NodePath) var ignore_childs = []
export var toggle_on_ready := true
export var check_root := false

var _ids_to_ignore := []

onready var _root: Node2D = get_node(root_path)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	for p in ignore_childs:
		_ids_to_ignore.append(get_node(p).get_instance_id())

	_root.connect('visibility_changed', self, 'toggle_colliders')
	
	# La verificación de estado inicial
	if toggle_on_ready:
		yield(get_parent(), 'ready')
		toggle_colliders()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func force_disable() -> void:
	_toggle_colliders(_root, true)


func toggle_colliders() -> void:
	_toggle_colliders(_root)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _toggle_colliders(node: Node2D = self, force_disable := false) -> void:
	var target_state: bool = false if force_disable else _root.visible
	
	# Esto se usa en los casos en los que este nodo se asignó como hijo de un
	# nodo de los tipos: StaticBody2D, Area2D y Light2D
	if check_root and node.get_instance_id() == _root.get_instance_id():
		_check_node(_root, target_state)
	
	for c in node.get_children():
		_check_node(c, target_state)

		if not c.get_children().empty():
			if not _ids_to_ignore.has(c.get_instance_id()):
				_toggle_colliders(c, force_disable)


# Inhabilita o habilita un nodo si es de los tipos: StaticBody2D, Area2D y Light2D
func _check_node(node: Node2D, target_state: bool) -> void:
	if node is StaticBody2D:
		(node as StaticBody2D).collision_mask = 0 if not target_state else 1
	elif node is Area2D:
		if target_state and (node is CollisionEnabler or node is ZIndexChanger):
			# Para que se configure el nodo en el estado por defecto
			(node as Area2D).monitorable = true
			(node as Area2D).monitoring = true
			node.ready_setup()
		else:
			(node as Area2D).monitorable = target_state
			(node as Area2D).monitoring = target_state
	elif node is Light2D:
		(node as Light2D).enabled = target_state
