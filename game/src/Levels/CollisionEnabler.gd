class_name CollisionEnabler
extends Area2D

export(Array, NodePath) var targets = []
export var starts_disabled := false
export var modify_masks := false
export var disable_on_enter := false

var _target_bodies := []

onready var _parent: PhysicsBody2D = get_parent()
onready var _enabled := !starts_disabled

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	for b in targets:
		_target_bodies.append(get_node(b))
	
	ready_setup()

	connect('area_entered', self, '_toggle_mask', [true])
	connect('area_exited', self, '_toggle_mask', [false])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func ready_setup() -> void:
	if starts_disabled:
		if not modify_masks:
			for b in _target_bodies:
				_parent.add_collision_exception_with(b as PhysicsBody2D)
		else:
			_parent.collision_layer = 0
			_parent.collision_mask = 0
		_parent.hide()


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _toggle_mask(body: Area2D, entered: bool) -> void:
	if body.name == 'FootArea':
		# TODO: Reducir la lógica de este bloque ------------------------------
		if disable_on_enter and entered:
			_enabled = true
			_parent.hide()
		elif not disable_on_enter:
			if entered: _parent.show()
			else: _parent.hide()
		# ---------------------------------------------------------------------

		if not modify_masks:
			for b in _target_bodies:
				if _enabled:
					_parent.add_collision_exception_with(b)
				else:
					_parent.remove_collision_exception_with(b)
		else:
			_parent.collision_layer = 0 if _enabled else 1
			_parent.collision_mask = 0 if _enabled else 1

		_enabled = !_enabled
		
#		prints('%s: %s' % [_parent.name, 'entra' if entered else 'sale'])
