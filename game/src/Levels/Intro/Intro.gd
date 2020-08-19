extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(int) var intro_messages = 4
export (String, FILE, "*.tscn") var First_Level: String

var _count := 0
var _in_intro := true
var _waiting_sacrifice := false
var _fading_in := false
var _skipped := false
var _current_msg := ''
var _in_dialog := false

onready var _overlay: ColorRect = $OverlayLayer/Overlay
onready var _intro_label: Label = $OverlayLayer/LabelContainer/Label
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_intro_label.modulate = Color(1, 1, 1, 0)
	_intro_label.text = ''

	_overlay.show()
	$Pickable.hide()

	# Conectar escuchadores de eventos globales
	HudEvent.connect('hud_accept_pressed', self, '_handle_accept')
	DialogEvent.connect('dialog_finished', self, '_go_to_world')
	IntroductionEvent.connect('pickable_requested', self, '_show_pickable')
	DialogEvent.connect('dialog_paused', self, '_enable_pickable')

	_continue()


# Esta función se llama cuando en el HUD se registró la presionada de la acción
# 'ui_accept'
func _handle_accept() -> void:
	if _intro_label.modulate.a == 1.0:
		_continue()
	else:
		_skip()


func _continue() -> void:
	if _count < 0:
		_go_to_world()
		return

	if _waiting_sacrifice:
		# TODO: Que el fuego diga algo para recordarle al jugador que tiene
		# que agarrar el tucán y sacrificarlo
		DialogEvent.emit_signal('character_spoke')
		return

	if _in_intro and _count < intro_messages:
		_current_msg = _get_intro_msg()
		_show_text(_current_msg)
	else:
		if _in_intro:
			_in_intro = false
			yield(_next(), 'completed')
			_intro_label.text = ''
			_intro_label.modulate.a = 0.0
			_overlay.hide()

		if not _in_dialog:
			DialogEvent.emit_signal('dialog_requested', 'Dream')
			_in_dialog = true
		else:
			DialogEvent.emit_signal('dialog_continued')


func _skip() -> void:
	_skipped = true

	if _in_intro:
		$Tween.remove_all()

		if _fading_in:
			_show_text('')
		else:
			_intro_label.modulate.a = 0
			_show_text('')


func _get_intro_msg() -> String:
	_count += 1
	return tr('INTRO_0%d' % _count)


func _sacrifice_done() -> void:
	_waiting_sacrifice = false
	_count += 1
	_continue()
	_count = -1


func _next() -> void:
	# Ocultar el texto de la introducción que se está mostrando para que se
	# muestre el siguiente
	_fading_in = false

	$Tween.interpolate_property(
		_intro_label,
		'modulate:a',
		1,
		0,
		0.5,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	$Tween.start()
	yield($Tween, 'tween_completed')


func _show_text(msg := '', fade_in_time := 0.8) -> void:
	var wait := 2

	if msg:
		if _intro_label.text and _intro_label.modulate.a > 0:
			yield(_next(), 'completed')
			if _skipped: return

		_intro_label.text = msg
		_fading_in = true

		$Tween.interpolate_property(
			_intro_label,
			'modulate:a',
			0,
			1,
			fade_in_time,
			Tween.TRANS_SINE,
			Tween.EASE_OUT
		)
		$Tween.start()
	else:
		wait = 0.1
		_intro_label.text = _current_msg
		_intro_label.modulate.a = 1.0

	yield(get_tree().create_timer(wait), 'timeout')

	_skipped = false

	if _in_intro: HudEvent.emit_signal('continue_requested')


func _go_to_world() -> void:
	DialogEvent.emit_signal('character_spoke')
	GuiEvent.emit_signal("ChangeScene", First_Level)


func _show_pickable() -> void:
	$Pickable.show()
	$Pickable.toggle_collision(false)


func _enable_pickable() -> void:
	# Activar la agarración del tucán y esperar a que el jugador lo
	# sacrifique
	_waiting_sacrifice = true
	$Pickable.toggle_collision()
	$Pickable.connect('tree_exited', self, '_sacrifice_done')
