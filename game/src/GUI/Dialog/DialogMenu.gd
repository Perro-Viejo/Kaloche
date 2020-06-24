class_name DialogMenu
extends VBoxContainer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(PackedScene) var option
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	Event.connect('dialog_menu_requested', self, 'create_options')
	Event.connect('dialog_finished', self, 'remove_options')


func create_options(options := []) -> void:
	if options.empty(): return

	for opt in options:
		var btn: Button = option.instance() as Button
		btn.text = opt.line
		btn.connect('pressed', self, '_on_option_clicked', [opt])
		add_child(btn)

	show()


func remove_options() -> void:
	var btn: Button
	for btn in get_children():
		remove_child(btn)
		btn.queue_free()
	hide()


func _on_option_clicked(opt: Dictionary) -> void:
	hide()
	Event.emit_signal('dialog_option_clicked', opt)
