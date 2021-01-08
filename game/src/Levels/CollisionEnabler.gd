extends Area2D
class_name CollisionEnabler

export(Array, NodePath) var targets = []
export var starts_disabled := false

var _target_bodies := []

onready var _parent: PhysicsBody2D = get_parent()
onready var _enabled := !starts_disabled

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	for b in targets:
		_target_bodies.append(get_node(b))
	
	if starts_disabled:
		for b in _target_bodies:
			_parent.add_collision_exception_with(b as PhysicsBody2D)

	connect('area_entered', self, '_toggle_mask', [true])
	connect('area_exited', self, '_toggle_mask', [false])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _toggle_mask(body: Area2D, entered: bool) -> void:
	if body.name == 'FootArea':
		for b in _target_bodies:
			if _enabled:
				_parent.add_collision_exception_with(b)
			else:
				_parent.remove_collision_exception_with(b)
			_enabled = !_enabled
