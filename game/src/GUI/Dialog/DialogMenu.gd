class_name DialogMenu
extends VBoxContainer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(PackedScene) var option

var _current_options := []
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	hide()


func create_options(options := []) -> void:
	if options.empty():
		if not _current_options.empty():
			show_options()
		return

	_current_options = options
	for opt in options:
		var btn: Button = option.instance() as Button
		btn.text = opt.line
		btn.connect('pressed', self, '_on_option_clicked', [opt])

		add_child(btn)

		if opt.has('show') and not opt.show:
			btn.hide()
	show()


func remove_options() -> void:
	if not _current_options.empty():
		_current_options.clear()

		for btn in get_children():
			remove_child(btn as Button)
			(btn as Button).queue_free()
		hide()


func update_options(updates_cfg := {}) -> void:
	if not updates_cfg.empty():
		for btn in get_children():
			btn = (btn as Button)
			var id := String(btn.get_index())
			if updates_cfg.has(id):
				if not updates_cfg[id]:
					btn.hide()
				else:
					btn.show()


func show_options() -> void:
	show()


func _on_option_clicked(opt: Dictionary) -> void:
	hide()
	Event.emit_signal('dialog_option_clicked', opt)
