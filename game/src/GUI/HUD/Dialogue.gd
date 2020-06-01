class_name Dialogue
extends Label
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var animation_time = 0.01
export(int) var character_speed = 2
export(bool) var animate_on_set_text = true
export(bool) var animate_on_start = false
export(bool) var canPlay = true
export(float) var disappear_wait = 3.0

var default_position
var default_size

var _current_disappear: = 0.0
var _chars: = []
var _count: = 0
var _text: String
var _hud: Hud
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	hide()

	default_position = get_position()
	default_size = get_size()

	Event.connect('character_spoke', self, '_on_character_spoke')
	$Timer.connect('timeout', self, '_on_timer_timeout')
	$Timer.set_wait_time(animation_time)

	if animate_on_start:
		start_animation()

func start_animation():
	if has_node('Timer'): $Timer.start()

func _on_timer_timeout():
	if text.length() < _text.length():
		text += _text[_count]
		_count += 1
		print(default_position)
		rect_position.x = 160 - (rect_size.x / 2)
	else:
		_count = 0
		$Timer.stop()

		if _current_disappear > 0:
			yield(get_tree().create_timer(_current_disappear), 'timeout')
		elif _current_disappear == 0.0:
			yield(get_tree().create_timer(disappear_wait), 'timeout')
		else:
			# El texto no desaparecerá sólo, sino que se espera una señal que lo
			# haga desaparecer
			_hud.show_continue(0)
			return
		_current_disappear = 0.0
		hide()
		set_text('')

func _on_character_spoke(
		character: String, message: String, time_to_disappear: float = 0.0
	):
	match character:
		'Demon':
			add_color_override("font_color", Color('#e35f58'))
		'Teo':
			add_color_override("font_color", Color('#3d6e70'))
		_:
			add_color_override("font_color", Color('#222323'))

	if message != '':
		show()
		Event.emit_signal('play_requested', 'UI', 'Dialogue')
		set_text(message)

		_current_disappear = time_to_disappear

		if time_to_disappear < 0:
			if not _hud:
				_hud = (get_node('../../') as Hud)
			_hud.in_dialogue = true
	else:
		hide()


func set_text(text):
	set_defaults()

	if text != '':
		_text = text
		if animate_on_set_text:
			start_animation()
		else:
			.set_text(text)

func set_defaults():
	.set_text('')
	rect_size = default_size
#	rect_position = default_position
	$Timer.stop()
