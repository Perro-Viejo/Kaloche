extends Node2D

var current_rocks := []
var collisions

func _ready():
	collisions = $StaticBody2D
	for rock in $Debris.get_children():
		current_rocks.append(rock)
		rock.connect('grabbed_changed', self, '_rock_grabbed', [rock])


func _rock_grabbed(state, rock):
	if state == false:
		current_rocks.erase(rock)
	else:
		AudioEvent.emit_signal('play_requested', 'EntranceRuins', 'Rumble', global_position)
	if current_rocks.empty():
		AudioEvent.emit_signal('play_requested', 'EntranceRuins', 'Destruction')
		yield(get_tree().create_timer(1), 'timeout')
		$Ruins.set_frame(1)
		collisions.get_node('Blocked').set_disabled(true)
		collisions.get_node('Unblocked').set_disabled(false)
		collisions.get_node('Unblocked2').set_disabled(false)
		
