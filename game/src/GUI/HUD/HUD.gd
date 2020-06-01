class_name Hud
extends CanvasLayer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
var _current_zone: = ''
var in_dialogue: bool = false

onready var _zone_name: Label = $Control/ZoneName
onready var _dflt_pos: = {
	zone_name = _zone_name.rect_position
}
onready var _intro: Label = $Control/CenterContainer/Intro
onready var _continue: Label = $Control/Continue
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_zone_name.text = ''
	_zone_name.rect_position.y = _dflt_pos.zone_name.y + 128
	_continue.hide()

	_intro.modulate = Color(1, 1, 1, 0)

	# Conectarse a los eventos del señor
	Event.connect('zone_entered', self, 'update_zone_name')
	$Tween.connect('tween_all_completed', self, 'update_zone_name')
	Event.connect('intro_shown', self, 'show_intro_msg')
#	_continue.connect('pressed', self, 'next_intro')


func _unhandled_input(event: InputEvent) -> void:
	if _continue.is_visible() and event.is_action('ui_accept'):
		next_intro()


func update_zone_name(name: String = '') -> void:
	if name == '':
		_zone_name.text = ''
		return

	var appear_anim: = true

	if _zone_name.text != '':
		appear_anim = false

		$Tween.remove_all()

		_zone_name.rect_position.y = _dflt_pos.zone_name.y

	_zone_name.text = name

	if appear_anim:
		Event.emit_signal('play_requested', 'UI', 'Zone')
		$Tween.interpolate_property(
			_zone_name,
			'rect_position:y',
			_dflt_pos.zone_name.y + 128,
			_dflt_pos.zone_name.y,
			0.6,
			Tween.TRANS_BACK,
			Tween.EASE_OUT
		)

	$Tween.interpolate_property(
		_zone_name,
		'rect_position:y',
		_dflt_pos.zone_name.y,
		_dflt_pos.zone_name.y + 128,
		0.4,
		Tween.TRANS_BACK,
		Tween.EASE_IN,
		3.2
	)

	$Tween.start()


func show_continue(wait: int = 5) -> void:
	yield(get_tree().create_timer(wait), 'timeout')
	_zone_name.rect_position = _dflt_pos.zone_name
	_zone_name.text = tr('CLICK_CONTINUE')

	_zone_name.show()
	_continue.show()


func show_intro_msg(msg: String) -> void:
	_intro.text = msg

	$Tween.interpolate_property(
		_intro,
		'modulate:a',
		0,
		1,
		0.8,
		Tween.TRANS_SINE,
		Tween.EASE_OUT,
		0.8
	)
	$Tween.start()

	show_continue(3)


func next_intro() -> void:
	_zone_name.hide()
	_continue.hide()

	if not in_dialogue:
		$Tween.interpolate_property(
			_intro,
			'modulate:a',
			1,
			0,
			0.5,
			Tween.TRANS_SINE,
			Tween.EASE_OUT,
			0.8
		)
		$Tween.start()

		yield($Tween, 'tween_completed')

	Event.emit_signal('intro_continued')
