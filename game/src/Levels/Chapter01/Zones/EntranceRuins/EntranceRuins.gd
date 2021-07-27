extends Node2D

var current_rocks := []
var collisions
var _broken := false
var _first := true

func _ready():
	collisions = $StaticBody2D
	for rock in $Debris.get_children():
		current_rocks.append(rock)
		rock.connect('grabbed_changed', self, '_rock_grabbed', [rock])


func _rock_grabbed(state, rock):
	if _first:
		DialogEvent.emit_signal('dialog_requested', 'Chapter0.1/DInitiationPath', 'grab_debris')
		_first = false
	if state == false:
		current_rocks.erase(rock)
		rock.disconnect('grabbed_changed', self, '_rock_grabbed')
	else:
		if not _broken:
			AudioEvent.emit_signal('play_requested', 'EntranceRuins', 'Rumble', global_position)
	if current_rocks.empty():
		if not _broken:
			AudioEvent.emit_signal('play_requested', 'EntranceRuins', 'Destruction')
			yield(get_tree().create_timer(1), 'timeout')
			$Ruins.set_frame(1)
			_broken = true
			collisions.get_node('Blocked').set_disabled(true)
			collisions.get_node('Unblocked').set_disabled(false)
			collisions.get_node('Unblocked2').set_disabled(false)
		
