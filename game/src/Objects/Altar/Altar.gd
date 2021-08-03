extends Node2D

signal activate_door


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	WorldEvent.connect('pickable_burnt', self, '_on_pickable_burnt')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_pickable_burnt(pickable):
	if 'Fish' in pickable.name and pickable.is_in_group('Sacred'):
		emit_signal('activate_door')
	else:
		DialogEvent.emit_signal('dialog_requested', 'Chapter0.1/DCeremonialAltar', 'false_feed')
