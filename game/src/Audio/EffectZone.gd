extends Area2D


export var effect = ''
export var wet = 0.0
export var dry = 1.0
export var max_distance = 0
export var min_distance = 0
export var distance_based = false

var current_body = null 

# Called when the node enters the scene tree for the first time.
func _ready():
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')

func _process(delta):
	if current_body and distance_based:
		var _position = global_position.distance_to(current_body.global_position)
		AudioEvent.emit_signal('fx_change_requested', effect, dry, range_lerp (_position, min_distance, max_distance, wet, 0))

func _on_body_entered(body):
	if body.name == 'Player':
		current_body = body
		if not distance_based:
			AudioEvent.emit_signal('fx_change_requested', effect, dry, wet)
		else:
			max_distance = global_position.distance_to(current_body.global_position)
	

func _on_body_exited(body):
	if body.name == 'Player':
		current_body = null
		AudioEvent.emit_signal('fx_change_requested', effect, 1.0, 0.0)
