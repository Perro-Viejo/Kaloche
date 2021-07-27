tool
class_name DialogTree
extends Resource

signal conversation_finished

export(Array, Resource) var options := [] setget _set_options


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos virtuales ░░░░
func option_selected(_opt: DialogOption) -> void:
	pass


# Cuando entra a este método, es porque se está usando el .tres
func start_conversation() -> void:
	start()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func play(dialog_name: String) -> void:
	if has_method('_' + dialog_name):
		yield(call('_' + dialog_name), 'completed')
		DialogEvent.emit_signal('dialog_finished')
	else:
		push_error(
			'No se encontró el diálogo %s en %s.' % [dialog_name, resource_name]
		)

func start() -> void:
	if options.empty():
		prints('Este diálogo no tiene otciones.')
		return

	if not WorldEvent.player_blocked:
		PlayerEvent.emit_signal('control_toggled')

	DialogEvent.in_conversation = true
	_show_options()

	yield(self, 'conversation_finished')

	DialogEvent.in_conversation = false
	disconnect_option_selection()
	DialogEvent.emit_signal('dialog_finished')
	PlayerEvent.emit_signal('control_toggled')


func disconnect_option_selection() -> void:
	if DialogEvent.is_connected('option_selected', self, 'option_selected'):
		DialogEvent.disconnect('option_selected', self, 'option_selected')


func show_option(id: String, is_visible := true) -> void:
	for o in options:
		if (o as DialogOption).id == id:
			o.visible = is_visible
			break


func is_option_visible(id: String) -> bool:
	for o in options:
		if (o as DialogOption).id == id:
			return o.visible
	return false


func show_group(group_name: String) -> void:
	for o in options:
		o.visible = true if (o as DialogOption).group == group_name else false

	_show_options()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _show_options() -> void:
	DialogEvent.emit_signal('dialog_menu_requested', options)
	if not DialogEvent.is_connected('option_selected', self, 'option_selected'):
		DialogEvent.connect('option_selected', self, 'option_selected')


func _set_options(value: Array) -> void:
	options = value
	for v in value.size():
		if not value[v]:
			var new_opt: DialogOption = DialogOption.new()
			var id := 'Opt%d' % options.size()
			new_opt.id = id
			new_opt.text = 'Opción %d' % options.size()
			options[v] = new_opt

			property_list_changed_notify()
