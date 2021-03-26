extends Area2D
class_name MaskEnabler

onready var _parent: Light2D = get_parent()

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	_parent.enabled = false
	connect('area_entered', self, '_toggle_mask', [true])
	connect('area_exited', self, '_toggle_mask', [false])


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _toggle_mask(body: Area2D, entered: bool) -> void:
	if body.name == 'FootArea':
		_parent.enabled = entered
