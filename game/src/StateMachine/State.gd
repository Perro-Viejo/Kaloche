class_name State
extends Node2D
"""
State interface to use in Hierarchical State Machines.
The lowest leaf tries to handle callbacks, and if it can't, it delegates the work to its parent.
It's up to the user to call the parent state's functions, e.g. `_parent.physics_process(delta)`
Use State as a child of a StateMachine node.
"""
export var _parent_path: NodePath
export var animation_name := ''

var _parent: Node = null

onready var _state_machine = _get_state_machine(self)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	yield(owner, 'ready')
	if _parent_path:
		_parent = get_node(_parent_path)
	else:
		_parent = get_node('../..')
	visible = false


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func unhandled_input(event: InputEvent) -> void:
	pass


func physics_process(delta: float) -> void:
	pass


func enter(msg: Dictionary = {}) -> void:
	visible = true
	play_animation()
	pass


func world_tick() -> void:
	pass


func exit() -> void:
	visible = false
	stop()


func play_animation() -> bool:
	if animation_name:
		owner.play_animation(animation_name)
		return true
	return false


func stop() -> void:
	if animation_name:
		owner.stop_animation()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _get_state_machine(node: Node) -> Node:
	if node != null and not node.is_in_group('state_machine'):
		return _get_state_machine(node.get_parent())
	return node
