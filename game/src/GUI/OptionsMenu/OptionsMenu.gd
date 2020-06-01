extends CanvasLayer

func _ready()->void:
	#show main section and hide controls
	Event.connect("Options", self, "on_show_options")
	Event.Controls = false

func on_show_options(value:bool)->void:
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	$Control.visible = value
	Event.Controls = false


