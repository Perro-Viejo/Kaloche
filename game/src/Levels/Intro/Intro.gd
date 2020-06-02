extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(int) var intro_messages = 4
export(int) var dialogue_messages = 9
export (String, FILE, "*.tscn") var First_Level: String

var _count := 0
var _in_intro := true
var _demon_count := 1
var _teo_count := 1
var _waiting_sacrifice := false
var _fading_in := false
var _skipped := false
var _current_msg := ''

onready var _overlay: ColorRect = $OverlayLayer/Overlay
onready var _intro_label: Label = $OverlayLayer/LabelContainer/Label
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_intro_label.modulate = Color(1, 1, 1, 0)
	_intro_label.text = ''

	_overlay.show()
	$Pickable.hide()

	# Conectar escuchadores de eventos locales
#	$Tween.connect('tween_all_completed', self, 'update_zone_name')

	# Conectar escuchadores de eventos globales
	Event.connect('intro_continued', self, '_show_intro')
	Event.connect('intro_skipped', self, '_skip')

	_show_intro()


# Esta función se llama cuando en el HUD se registró la presionada de la acción
# 'ui_accept'
func _show_intro() -> void:
	if _count < 0:
		Event.emit_signal('character_spoke', '', '')
		Event.emit_signal("ChangeScene", First_Level)
		return

	if _waiting_sacrifice:
		# TODO: Que el fuego diga algo para recordarle al jugador que tiene
		# que agarrar el tucán y sacrificarlo
		return

	if _in_intro and _count < intro_messages:
		_current_msg = _get_intro_msg()
		_show_intro_msg(_current_msg)
	elif _count <= dialogue_messages:
		if _in_intro and _count == intro_messages:
			_in_intro = false
			yield(_next_intro(), 'completed')
			_intro_label.text = ''
			_intro_label.modulate.a = 0.0
			_overlay.hide()
			_count = 1

		_show_dialogue_msg()
	elif _count == dialogue_messages + 1:
		# Activar la agarración del tucán y esperar a que el jugador lo
		# sacrifique
		_waiting_sacrifice = true
		$Pickable.toggle_collision()
		$Pickable.connect('tree_exited', self, '_sacrifice_done')
		Event.emit_signal('character_spoke', '', '')

func _get_intro_msg() -> String:
	_count += 1
	return tr('INTRO_0%d' % _count)

func _show_dialogue_msg() -> void:
	match _count:
		1, 3, 5, 7, 9, 10, 11:
			Event.emit_signal(
				'character_spoke', 'Demon', tr('DEMON_0%d' % _demon_count), -1
			)
			if _demon_count == 5:
				$Pickable.show()
				$Pickable.toggle_collision(false)
			_demon_count += 1
		2, 4, 6, 8:
			Event.emit_signal(
				'character_spoke', 'Teo', tr('TEO_0%d' % _teo_count), -1
			)
			_teo_count += 1
	_count += 1


func _skip() -> void:
	_skipped = true

	if _in_intro:
		$Tween.remove_all()

		if _fading_in:
			_show_intro_msg('')
		else:
			_intro_label.modulate.a = 0
			_show_intro_msg('')
	else:
		# Emitir la señal para que el HUD corte la animación del diálogo
		Event.emit_signal('dialog_skipped')


func _sacrifice_done() -> void:
	_waiting_sacrifice = false
	_count += 1
	_show_dialogue_msg()
	_count = -1


func _next_intro() -> void:
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


func _show_intro_msg(msg := '', fade_in_time := 0.8) -> void:
	var wait := 3

	if msg:
		if _intro_label.text and _intro_label.modulate.a > 0:
			yield(_next_intro(), 'completed')
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
		wait = 0
		_intro_label.text = _current_msg
		_intro_label.modulate.a = 1.0

	yield(get_tree().create_timer(wait), 'timeout')

	_skipped = false
	Event.emit_signal('continue_requested')
