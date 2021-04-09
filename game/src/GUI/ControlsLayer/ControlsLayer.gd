extends CanvasLayer

export (String, FILE, '*.tscn') var first_Level := ''

var _is_shown_as_scene := false

onready var _close_label: Label = find_node('CloseLabel')
onready var _helper_button: Button = find_node('Helper')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	_helper_button.connect('pressed', self, '_close')

	if Data.get_data(Data.CURRENT_SCENE) == self.name:
		_is_shown_as_scene = true
		_close_label.text = 'CLICK_CONTINUE'
		_close_label.rect_position.x = OS.window_size.x
		_helper_button.grab_focus()

		$MainContainer.show()

		yield(get_tree(), 'idle_frame')
		$Tween.interpolate_property(
			_close_label, 'rect_position:x',
			OS.window_size.x, 320.0 - _close_label.rect_size.x,
			0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT,
			1.5
		)
		$Tween.start()
	else:
		$MainContainer.hide()

		# Conectarse a eventos del universo pokémon
		GuiEvent.connect('show_controls_requested', self, '_show_controls')

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _show_controls(appear: bool) -> void:
	if appear:
		$MainContainer.show()
		guiBrain.gui_collect_focusgroup()
#		SectionEvent.Paused = false
	else:
		$MainContainer.hide()
#		SectionEvent.Paused = true
		guiBrain.gui_collect_focusgroup()


func _close() -> void:
	$Tween.remove_all()
	
	if _is_shown_as_scene:
		GuiEvent.emit_signal('ChangeScene', first_Level)
	else:
		SectionEvent.show_controls = false
