extends Node2D

export var needs_grabbing := true
export var pickable_needed := 'Rocberto'
export var message_id := 0

func _ready():
	$InteractionArea.connect('body_entered', self, '_on_body_entered')

func _on_body_entered(body: Node)  -> void:
	if body.name == 'Player':
		if needs_grabbing and body.grabbing:
			if pickable_needed == '' or body.picked_item.name == pickable_needed:
				DialogEvent.emit_signal('dialog_requested', '01Signs', message_id)
		else:
			#lo lee Teotriste
			DialogEvent.emit_signal('dialog_requested', 'TeotristeSignReaction')
