extends Node2D
# ♪ Controla la reproducción de efectos de sonido dentro del juego ♪
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
var _sources: Array = []
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	for src in get_children():
		_sources.append(src.name)

	Event.connect('play_requested', self, 'play_sound')
	Event.connect('dx_requested', self, 'play_dx')
	Event.connect('stop_requested', self, 'stop_sound')
	Event.connect('pause_requested', self, 'pause_sound')
	Event.connect('change_volume', self, 'set_volume')



func _get_audio(source, sound) -> Node:
	return get_node(''+source+'/'+sound)

func play_sound(source: String, sound: String, _position: Vector2 = Vector2(-160, 90)) -> void:
	var audio: Node = _get_audio(source, sound)
	# Corrige el error de no tener un DX para el personaje que va a hablar
	if not audio: return
	
	# recibe el parametro de posicion de quien esta llamando el sonido
	if audio is AudioStreamPlayer2D:
		audio.set_position(_position)
	
	if audio.get('stream_paused'):
		audio.stream_paused = false
	else:
		audio.play()
		if audio is AudioStreamPlayer or audio is AudioStreamPlayer2D:
			if audio.is_connected('finished', self, '_on_finished'):
				return
			else:
				audio.connect('finished', self, '_on_finished', [source, sound])
		else:
			if audio.select_sound.is_connected('finished', self, '_on_finished'):
				return
			else:
				audio.select_sound.connect('finished', self, '_on_finished', [source, sound])

func play_dx(character: String, emotion: String):
	if not emotion:
		emotion = 'Gen'
	play_sound('DX/'+character, emotion, Vector2.ZERO)

func stop_sound(source: String, sound: String) -> void:
	_get_audio(source, sound).stop()


func pause_sound(source: String, sound: String) -> void:
	var audio: Node = _get_audio(source, sound)

	if not audio.get('stream_paused'):
		audio.stream_paused = true

func _on_finished(source: String, sound: String):
	Event.emit_signal('stream_finished', source, sound)

func set_volume(source, sound, volume):
	_get_audio(source, sound).set_volume_db(volume)

func set_pitch(source, sound, pitch):
	_get_audio(source, sound).set_pitch_scale(pitch)

