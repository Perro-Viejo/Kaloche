class_name Dialogue
extends Label
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var animation_time = 0.01
export(int) var character_speed = 2
export(bool) var animate_on_set_text = true
export(bool) var animate_on_start = false
export(bool) var typing = true
export(float) var disappear_wait = 3.0

var default_position
var default_size

var _current_disappear: = 0.0
var _chars: = []
var _count: = 0
var _text: String
var _hud: Hud
var _forced_update := false
var _current_character: Node2D
var _dialog_sequence := []
var _sequence_step := 0
# Cosas del Godot Dialog System ---- {
var _story_reader_class := load('res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd')
var _stories_es := load('res://assets/stories/baked_stories_es.tres')
var _did := 0
var _nid := 0
var _final_nid := 0
# } ----
var _wait := false

onready var _story_reader: EXP_StoryReader = _story_reader_class.new()
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	hide()

	default_position = get_position()
	default_size = get_size()

	match TranslationServer.get_locale():
		_:
			_story_reader.read(_stories_es)

	Event.connect('character_spoke', self, '_on_character_spoke')
	Event.connect('dialog_skipped', self, 'stop')
	Event.connect('dialog_sequence', self, '_display_sequence')
	Event.connect('dialog_requested', self, '_play_dialog')
	Event.connect('dialog_continued', self, '_continue_dialog')

	$Timer.connect('timeout', self, '_on_timer_timeout')
	$Timer.set_wait_time(animation_time)


func _process(delta: float) -> void:
	if not _hud:
		_hud = (get_node('../../') as Hud)

	if _forced_update:
		_forced_update = false
		rect_position.x = 160 - (rect_size.x / 2)
		_hud.show_continue(0)


func start_animation():
	if not is_inside_tree(): return
	if has_node('Timer'): $Timer.start()
	typing = true

func set_text(text):
	Event.emit_signal('play_requested', 'UI', 'Dialogue')
	set_defaults()

	if text != '':
		_text = text
		if animate_on_set_text:
			start_animation()
		else:
			.set_text(text)
	else:
		_text = ''
		_count = 0


func set_defaults():
	self.text = ''
	rect_size = default_size

	$Timer.stop()


func stop(auto_complete: bool = true) -> void:
	# Ignorar el skip si el texto ya está en su estado final
	if text == _text: return

	_finish()

	if auto_complete:
		text = _text
		_forced_update = true


func _on_timer_timeout():
	if text.length() < _text.length():
		text += _text[_count]
		_count += 1
		# Reposicionar el elemento porque el texto va creciendo
		rect_position.x = 160 - (rect_size.x / 2)
	else:
		# El texto ya tiene todos los caracteres
		_finish()

		if _current_disappear > 0:
			yield(get_tree().create_timer(_current_disappear), 'timeout')
		elif _current_disappear == 0.0:
			yield(get_tree().create_timer(disappear_wait), 'timeout')
		else:
			# El texto no desaparecerá sólo, sino que se espera una señal que lo
			# haga desaparecer
			_hud.show_continue(0)
			return
		if not typing:
			_current_disappear = 0.0
			self.text = ''
			hide()
			_current_character = null

func _display_sequence(messages: Array) -> void:
	var message = PoolStringArray(messages).join(',')
	if message.find(',') > -1:
			_sequence_step = 0
			_dialog_sequence = message.split(',')
			show()
			set_text(_dialog_sequence[_sequence_step])

func _on_character_spoke(
		character: Node2D = null, message :String = '', time_to_disappear := 0.0
	):
	if typing:
		stop()
		if not is_inside_tree(): return
		yield(get_tree().create_timer(.3), 'timeout')

	# Definir el color del texto
	var text_color: Color = Color('#222323')
	if character and character.get('dialog_color'):
		text_color = character.dialog_color
	add_color_override("font_color", text_color)

	if _current_character \
		and _current_character.is_inside_tree() \
		and _current_character.has_method('spoke'):
		# Notificar al personaje que ya terminó de hablar
		_current_character.spoke()

	if message != '':
		_current_character = character
		show()
		set_text(message)

		_current_disappear = time_to_disappear

		if time_to_disappear < 0:
			_hud.in_dialogue = true
	else:
		_current_character = null
		_finish()
		set_text('')
		hide()



# Detiene el temporizador y resetea el contador de caracteres escritos a cero
# pues el texto ya se está mostrando completo.
func _finish() -> void:
	_count = 0
	$Timer.stop()

	if typing:
		typing = false

	if _wait:
		_wait = false
		Event.emit_signal('dialog_paused')

	if _sequence_step < _dialog_sequence.size() - 1:
		if .is_inside_tree():
			yield(get_tree().create_timer(.4), 'timeout')
		_sequence_step += 1
		set_text(_dialog_sequence[_sequence_step])
		return

	_dialog_sequence = []
	_sequence_step = 0


func _play_dialog(dialog_name: String) -> void:
	_did = _story_reader.get_did_via_record_name(dialog_name)
	_nid = _story_reader.get_nid_via_exact_text(_did, 'start')
	_final_nid = _story_reader.get_nid_via_exact_text(_did, 'end')
	_continue_dialog()


func _continue_dialog() -> void:
	_next_dialog_line()

	if _nid == _final_nid:
		Event.emit_signal('dialog_finished')
	else:
		_play_dialog_line()


func _next_dialog_line() -> void:
	_nid = _story_reader.get_nid_from_slot(_did, _nid, 0)


func _play_dialog_line() -> void:
	var line_txt := _story_reader.get_text(_did, _nid)
	var line_dic: Dictionary = JSON.parse(line_txt).result

	_wait = false
	if line_dic.has('wait'):
		_wait = true

	if line_dic.has('on_start'):
		Event.emit_signal(line_dic.on_start)

	Event.emit_signal(
		'line_triggered',
		(line_dic.actor as String).to_lower(),
		line_dic.line as String
	)
