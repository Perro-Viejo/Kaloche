extends Area2D

export var self_destroy = true

export var play_once = false

export var pickable_needed = ''

export var delay = 0.0

export var active = true

export var _path = ''
export var _dialog_key = ''
export var _condition_dialog_key = ''

var _played

func _ready():
	connect('body_entered', self, '_on_body_entered')

func _on_body_entered(body: Node):
	if active:
		if body.name == 'Player':
			var _body_dir = body.dir
			yield(get_tree().create_timer(delay), 'timeout')
			if body.grabbing and body.picked_item.name == pickable_needed:
				DialogEvent.emit_signal('dialog_requested', _path, _condition_dialog_key)
				if self_destroy:
					queue_free()
			else:
				if play_once and _played:
					pass
				else:
					DialogEvent.emit_signal('dialog_requested', _path, _dialog_key)
					_played = true
					if self_destroy and _condition_dialog_key == '':
						queue_free()
	else:
		pass
