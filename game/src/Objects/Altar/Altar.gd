extends Node2D

signal activate_door


func _ready():
	WorldEvent.connect('pickable_burnt', self, '_on_pickable_burnt')


func _on_pickable_burnt(pickable):
	if 'Fish' in pickable.name and pickable.is_in_group('Sacred'):
		emit_signal('activate_door')
