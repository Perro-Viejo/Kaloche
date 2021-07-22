class_name DialogTree
extends Resource


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func play(dialog_name: String) -> void:
	if has_method('_' + dialog_name):
		yield(call('_' + dialog_name), 'completed')
		DialogEvent.emit_signal('dialog_finished')
	else:
		push_error('No se encontró el diálogo %s en %s.' % [dialog_name, resource_name])
