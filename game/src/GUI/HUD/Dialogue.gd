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

# Cosas del Godot Dialog System ---- {
var _story_reader_class := load('res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd')
var _stories_es := load('res://assets/stories/baked_stories_es.tres')
var _did := 0
var _nid := 0
var _final_nid := 0
var _options_nid := 0
var _in_dialog := false
# } ----
var _wait := false
var _selected_slot := 0

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
	Event.connect('dialog_requested', self, '_play_dialog')
	Event.connect('dialog_continued', self, '_continue_dialog')
	Event.connect('dialog_option_clicked', self, 'option_clicked')

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
	set_defaults()

	if text != '':
		_text = text
		Event.emit_signal('play_requested', 'UI', 'Dialogue')
		if animate_on_set_text:
			start_animation()
		else:
			.set_text(text)
	else:
		_text = ''
		_count = 0

		hide()


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


func option_clicked(opt: Dictionary) -> void:
	_selected_slot = opt.id
	if opt.has('say') and opt.say:
		Event.emit_signal(
			'line_triggered',
			(opt.actor as String).to_lower(),
			opt.line as String,
			opt.time
		)
	else:
		_continue_dialog(_selected_slot)


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
			set_text('')

			_current_disappear = 0.0
			if _in_dialog:
				_continue_dialog(_selected_slot)

			if _current_character:
				var coco = _current_character
				_current_character = null
				coco.spoke()
				coco = null


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


func _play_dialog(dialog_name: String) -> void:
	_in_dialog = true
	_did = _story_reader.get_did_via_record_name(dialog_name)
	_nid = _story_reader.get_nid_via_exact_text(_did, 'start')
	_final_nid = _story_reader.get_nid_via_exact_text(_did, 'end')

	Event.emit_signal('movement_toggled')
	_continue_dialog()


func _continue_dialog(slot := 0) -> void:
	_selected_slot = 0
	_next_dialog_line(slot)

	if _nid == _final_nid:
		_options_nid = 0
		_in_dialog = false

		Event.emit_signal('movement_toggled')
		Event.emit_signal('dialog_finished')
	else:
		_play_dialog_line()


func _next_dialog_line(slot := 0) -> void:
	_nid = _story_reader.get_nid_from_slot(_did, _nid, slot)


func _play_dialog_line() -> void:
	var line_txt := _story_reader.get_text(_did, _nid)

	if _in_dialog:
		# Verificar si el texto del nodo es la palabra clave para volver al menú
		# de opciones activo
		if line_txt == 'return':
			_nid = _options_nid
			Event.emit_signal('dialog_menu_requested')
			return

	var line_dic: Dictionary = JSON.parse(line_txt).result

	_wait = false
	if line_dic.has('wait'):
		_wait = true

	# Por defecto se asume que el diálogo continuará con base en una acción del
	# jugador
	var time_to_disappear := -1.0
	if line_dic.has('time'):
		time_to_disappear = line_dic.time as float

	if line_dic.has('on_start'):
		Event.emit_signal(line_dic.on_start)

	if line_dic.has('options'):
		_options_nid = _nid
		var id := 0
		for opt in line_dic.options:
			opt.id = id

			if not opt.has('actor'):
				opt.actor = 'Player'
			if not opt.has('time'):
				opt.time = 3

			id += 1

		Event.emit_signal('dialog_menu_requested', line_dic.options)

	if line_dic.has('off') or line_dic.has('on'):
		# En este nodo se apagarán opciones
		var cfg := {}

		if line_dic.has('off'):
			for opt in line_dic.off:
				cfg[String(opt)] = false

		if line_dic.has('on'):
			for opt in line_dic.on:
				cfg[String(opt)] = true

		Event.emit_signal('dialog_menu_updated', cfg)

	# Lo último que se hace es disparar la línea de diálogo
	if line_dic.has('line'):
		Event.emit_signal(
			'line_triggered',
			(line_dic.actor as String).to_lower(),
			line_dic.line as String,
			time_to_disappear
		)
