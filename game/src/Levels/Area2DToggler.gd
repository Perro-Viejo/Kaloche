extends Area2D
class_name Area2DToggler

export(Array, NodePath) var targets
export var disable_on_entered := false

var _targets := []


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	for p in targets:
		_targets.append(get_node(p))
	
	connect('area_entered', self, '_toggle', [true])
	connect('area_exited', self, '_toggle', [false])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _toggle(body: Area2D, entered: bool) -> void:
	if body.name == 'FootArea':
		if entered:
			for n in _targets:
				(n as Area2D).monitoring = !disable_on_entered
		else:
			for n in _targets:
				(n as Area2D).set_deferred('monitoring', disable_on_entered)
