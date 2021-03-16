tool
class_name Area2DToggler
extends Area2D
# Habilita o deshabilita los Area2D que estén en el arreglo de targets cuando
# se entra o sale del área definida para este nodo.

export(Array, NodePath) var targets
export var disable_on_entered := false

var _targets := []


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	modulate = Color.red
	
	for p in targets:
		_targets.append(get_node(p))
	
	connect('area_entered', self, '_toggle', [true])
	connect('area_exited', self, '_toggle', [false])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _toggle(body: Area2D, entered: bool) -> void:
	if body.name == 'FootArea':
		var color: Color

		if entered:
			color = Color.black if disable_on_entered else Color.white
		else:
			color = Color.black if !disable_on_entered else Color.white

		for n in _targets:
			var area2d: Area2D = n as Area2D
			if entered:
				area2d.monitoring = !disable_on_entered
			else:
				area2d.set_deferred('monitoring', disable_on_entered)
			area2d.modulate = color
		
		prints('%s: %s' % [name, 'entra' if entered else 'sale'])
