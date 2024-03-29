extends VBoxContainer
signal value_changed(value)
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(Color) var highlight

var value := 0.0 setget set_value

onready var _dflt_color: Color = $ScaleName.get_color('font_color')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	$HSlider.connect('focus_entered', self, '_highlight_name')
	$HSlider.connect('focus_exited', self, '_highlight_name', [ false ])
	$HSlider.connect('value_changed', self, '_on_value_changed')

func set_value(val: float) -> void:
	value = val
	$HSlider.value = val

func _highlight_name(on := true) -> void:
	AudioEvent.emit_signal('play_requested', 'UI', 'Move')
	$ScaleName.add_color_override('font_color', highlight if on else _dflt_color)


func _on_value_changed(val: float):
	emit_signal('value_changed', val)
