extends Node2D

export var needs_grabbing := true
export var pickable_needed := 'Rocberto'
export var message_id := 0

func _ready():
	$InteractionArea.connect('body_entered', self, '_on_body_entered')
	$InteractionArea.connect('body_exited', self, '_on_body_exited')

func _on_body_entered(body: Node)  -> void:
	if body.name == 'Player':
		if needs_grabbing and body.grabbing:
			if pickable_needed == '' or body.picked_item.name == pickable_needed:
				#TODO: revisar si puedo mandar el parámetro del id en vez de
				#	hacer tantos métodos
				Data.read_sign_id = message_id
				DialogEvent.emit_signal('dialog_requested', 'Chapter0.1/DSigns', 'read_sign')
		else:
			#lo lee Teotriste
			DialogEvent.emit_signal('dialog_requested', 'Chapter0.1/DSigns', 'teotriste_reaction')

func _on_body_exited(body: Node)  -> void:
	if body.name == 'Player':
		DialogEvent.emit_signal('forced_close_requested')
