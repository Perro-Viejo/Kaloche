extends VBoxContainer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(Color) var highlight

onready var _dflt_color: Color = $ScaleName.get_color('font_color')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	$HSlider.connect('focus_entered', self, '_highlight_name')
	$HSlider.connect('focus_exited', self, '_highlight_name', [ false ])


func _highlight_name(on := true) -> void:
	$ScaleName.add_color_override('font_color', highlight if on else _dflt_color)
