class_name Hud
extends CanvasLayer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
var world_entered: bool = false

var _current_zone: = ''
var last_key := ''

onready var _zone_name: Label = $Control/ZoneName
onready var _dflt_pos: = {
	zone_name = _zone_name.rect_position
}
onready var _continue: TextureButton = find_node('Continue')
onready var _journal: Control = $Control/Journal
onready var _dialog: Dialog = find_node('Dialog')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_zone_name.text = ''
	_zone_name.rect_position.y = _dflt_pos.zone_name.y + 128

	_continue.hide()
	_journal.hide()

	# Conectarse a eventos paganos
	$Tween.connect('tween_all_completed', self, 'update_zone_name')

	# Conectarse a los eventos del señor
	WorldEvent.connect('zone_entered', self, 'update_zone_name')
	WorldEvent.connect('world_entered', self, '_on_world_entered')
	HudEvent.connect('continue_requested', self, 'show_continue')
	
	# DEBUG
	DebugOverlay.add_monitor('\nse presionó', self, ':last_key')


func _unhandled_input(event: InputEvent) -> void:
	last_key = event.as_text()

	if event.is_action_pressed('ui_accept'):
		_zone_name.hide()
		_continue.hide()
		HudEvent.emit_signal('hud_accept_pressed')
	elif event.is_action_pressed('Journal'):
		if world_entered:
			toggle_journal()


func update_zone_name(name: String = '') -> void:
	_zone_name.show()
	if name == '':
		_zone_name.text = ''
		return

	var appear_anim: = true

	if _zone_name.text != '':
		appear_anim = false

		$Tween.remove_all()

		_zone_name.rect_position.y = _dflt_pos.zone_name.y

	_zone_name.text = name
	AudioEvent.emit_signal('play_requested', 'UI', 'Zone')

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



func show_continue() -> void:
	if not world_entered:
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
