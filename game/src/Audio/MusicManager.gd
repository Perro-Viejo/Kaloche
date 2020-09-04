extends Node2D

var prev_mx = null

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioEvent.connect('mx_request', self, 'play_mx')
	AudioEvent.connect('mx_stop', self, 'stop_mx')


func _get_mx(_music) -> Node:
	var sound_path := '%s' % [_music]
	var node: Node = null
	if has_node(sound_path):
		node = get_node(sound_path)
	return node

func play_mx(music: String) -> void:
	var audio: Node = _get_mx(music)
	if audio.get('stream_paused'):
		audio.stream_paused = false
	else:
		if not audio == prev_mx:
			audio.play()
			prev_mx = audio
	if audio is AudioStreamPlayer or audio is AudioStreamPlayer2D:
		if audio.is_connected('finished', self, '_on_finished'):
			return
		else:
			audio.connect('finished', self, '_on_finished', [music])
	else:
		if audio.select_sound.is_connected('finished', self, '_on_finished'):
			return
		else:
			audio.select_sound.connect('finished', self, '_on_finished', [music])

func _on_finished(music: String):
	AudioEvent.emit_signal('stream_finished', music)
