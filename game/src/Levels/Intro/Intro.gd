extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(int) var intro_messages = 4
export(int) var dialogue_messages = 9
export (String, FILE, "*.tscn") var First_Level: String

onready var _overlay: ColorRect = $OverlayLayer/Overlay

var _count := 0
var _in_intro := true
var _demon_count := 1
var _teo_count := 1
var _waiting_sacrifice := false
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_overlay.show()
	$Pickable.hide()

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
		Event.emit_signal('intro_shown', _get_intro_msg())
	elif _count <= dialogue_messages:
		if _in_intro and _count == intro_messages:
			_in_intro = false
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
	if _in_intro:
		Event.emit_signal('intro_shown')
	else:
		# Emitir la señal para saltarse el Fade in de los mensajes de introducción
		Event.emit_signal('dialog_skipped')


func _sacrifice_done() -> void:
	_waiting_sacrifice = false
	_count += 1
	_show_dialogue_msg()
	_count = -1
