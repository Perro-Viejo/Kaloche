class_name Hud
extends CanvasLayer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
var _current_zone: = ''
var in_dialogue: bool = false
var world_entered: bool = false

onready var _zone_name: Label = $Control/ZoneName
onready var _dflt_pos: = {
	zone_name = _zone_name.rect_position
}
onready var _continue: Label = $Control/Continue
onready var _journal: Control = $Control/Journal
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_zone_name.text = ''
	_zone_name.rect_position.y = _dflt_pos.zone_name.y + 128
	_continue.hide()
	_journal.hide()

	# Conectarse a eventos paganos
	$Tween.connect('tween_all_completed', self, 'update_zone_name')

	# Conectarse a los eventos del señor
	Event.connect('zone_entered', self, 'update_zone_name')
	Event.connect('world_entered', self, '_on_world_entered')
	Event.connect('continue_requested', self, 'show_continue')


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept'):
		if _continue.is_visible():
			Event.emit_signal('intro_continued')
		else:
			Event.emit_signal('intro_skipped')

		_zone_name.hide()
		_continue.hide()
	elif event.is_action_pressed('Journal'):
		if world_entered:
			toggle_journal()


func update_zone_name(name: String = '') -> void:
	Event.emit_signal('play_requested', 'UI', 'Zone')
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


func show_continue(wait: int = 0) -> void:
#	yield(get_tree().create_timer(wait), 'timeout')
	_zone_name.rect_position = _dflt_pos.zone_name
	_zone_name.text = tr('CLICK_CONTINUE')

	_zone_name.show()
	_continue.show()


func toggle_journal() -> void:
	if not _journal.visible:
		_journal.show()
	else:
		_journal.hide()


func _on_world_entered():
	world_entered = true