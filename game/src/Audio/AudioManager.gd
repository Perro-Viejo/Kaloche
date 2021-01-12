extends Node2D
# ♪ Controla la reproducción de efectos de sonido dentro del juego ♪
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
var _sources: Array = []
var _hlt: Dictionary = {}
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	for src in get_children():
		_sources.append(src.name)

	AudioEvent.connect('play_requested', self, 'play_sound')
	AudioEvent.connect('dx_requested', self, 'play_dx')
	AudioEvent.connect('stop_requested', self, 'stop_sound')
	AudioEvent.connect('pause_requested', self, 'pause_sound')
	AudioEvent.connect('change_volume', self, 'set_volume')
	AudioEvent.connect('position_amb', self, 'set_amb_position')
	AudioEvent.connect('headloop_toggle', self, 'toggle_head_loop_tail')
	

func _get_audio(source, sound) -> Node:
	var sound_path := '%s/%s' % [source, sound]
	var node: Node = null
	if has_node(sound_path):
		node = get_node(sound_path)
	return node

func play_sound(source: String, sound: String, _position: Vector2 = Vector2(-160, 90)) -> void:
	var audio: Node = _get_audio(source, sound)
	# Corrige el error de no tener un DX para el personaje que va a hablar
	if not audio: return
	
	# recibe el parametro de posicion de quien esta llamando el sonido
	if audio is AudioStreamPlayer2D:
		audio.set_position(_position)
	elif audio is Node2D:
		audio._position = _position
	
	if audio.get('stream_paused'):
		audio.stream_paused = false
	else:
		if source == "BG":
			audio.play(rand_range(0.0, audio.stream.get_length()))
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
	AudioEvent.emit_signal('stream_finished', source, sound)

func set_volume(source, sound, volume):
	_get_audio(source, sound).set_volume_db(volume)

func set_pitch(source, sound, pitch):
	_get_audio(source, sound).set_pitch_scale(pitch)

func set_amb_position(source, sound, _position, _max_distance):
	_get_audio(source, sound).set_position(_position)
	_get_audio(source, sound).set_max_distance(_max_distance)	

func toggle_head_loop_tail (content):
	if _hlt.has(content.id):
		pass
#		continue_hlt(content)
	else:
		_hlt[content.id] = {
			step = 0,
			audios = [
				_get_audio(content.source, content.head),
				_get_audio(content.source, content.loop),
				_get_audio(content.source, content.tail)
			],
			_position = content._position,
			head_time = Timer.new()
		}
		continue_hlt(content)

func continue_hlt(content) -> void:
	var current_hlt = _hlt[content.id]
	var current_step = current_hlt.step
	
	if current_step == 3: return
	
	print(current_step)
	
#	if current_step == 0:
#		current_hlt.head_time.one_shot = true
#		current_hlt.head_time.autostart = true
#		current_hlt.head_time.wait_time = current_hlt.audios[current_step].stream.get_length()
#		current_hlt.head_time.connect('timeout', self, 'continue_hlt', [content])
#		add_child(current_hlt.head_time)
#
#	if current_step == 2:
#		current_hlt.audios[current_step - 1].stop()
#
#	if content.has('stop'):
#		current_hlt.audios[current_step - 1].stop()
#		current_step = 0
#	else:
#		current_hlt.step += 1
#		if current_hlt.audios[current_step] is AudioStreamPlayer2D:
#			current_hlt.audios[current_step].set_position(current_hlt._position)
#		current_hlt.audios[current_step].play()
