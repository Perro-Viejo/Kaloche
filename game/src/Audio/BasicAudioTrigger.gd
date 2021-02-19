extends Area2D

enum TYPE {SFX, MX, SPOT}

export (TYPE) var asset_type

export var asset_name = ""

func _ready():
	if asset_name == "":
		asset_name = get_name()
	
	connect('area_entered', self, '_on_area_entered')
	connect('area_exited', self, '_on_area_exited')

func _on_area_entered(other):
	if other.get_name() == 'PlayerArea':
		match TYPE.keys()[asset_type]:
			"SFX":
				pass
			"MX":
				AudioEvent.emit_signal("mx_request", asset_name)
			"SPOT":
				AudioEvent.emit_signal("play_requested", "Spot", asset_name, global_position)


func _on_area_exited(other):
	if other.get_name() == 'PlayerArea':
		match TYPE.keys()[asset_type]:
			"SFX":
				pass
			"MX":
				pass
			"SPOT":
				AudioEvent.emit_signal("stop_requested", "Spot", asset_name)
