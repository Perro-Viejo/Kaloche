extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(int) var intro_messages = 4
export(int) var dialogue_messages = 9
export (String, FILE, "*.tscn") var First_Level: String

onready var _overlay: ColorRect = $OverlayLayer/Overlay

var _count: int = 0
var _in_intro: bool = true
var _demon_count: int = 1
var _teo_count: int = 1
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_overlay.show()
	$Pickable.hide()

	Event.connect('intro_continued', self, '_show_intro')

	_show_intro()

func _show_intro() -> void:
	if _count < 0:
		Event.emit_signal('character_spoke', '', '')
		Event.emit_signal("ChangeScene", First_Level)
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
		# Esperar a que el jugador sacrifique el venao
		_count += 1
		$Pickable.toggle_collision()
		Event.emit_signal('character_spoke', '', '')
	else:
		_show_dialogue_msg()
		_count = -1

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
