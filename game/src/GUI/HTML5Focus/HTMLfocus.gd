extends CanvasLayer

signal closed


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Métodos de Godot ░░░░
func _ready()->void:
	if !Settings.HTML5:
		queue_free()
		return
	$Panel.show()
	$Button.show()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Métodos privados ░░░░
func _on_Button_pressed()->void:
	emit_signal('closed')
	queue_free()
