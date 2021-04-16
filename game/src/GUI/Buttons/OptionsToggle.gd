extends CheckButton
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(Color) var highligth
export(Color) var normal
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	self_modulate = normal
	connect('focus_entered', self, 'set_self_modulate', [highligth])
	connect('focus_entered', self, '_focus_sfx')
	connect('focus_exited', self, 'set_self_modulate', [normal])

func _focus_sfx():
	AudioEvent.emit_signal('play_requested', 'UI', 'Move')
