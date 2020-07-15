extends Control
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var y_offset := 16.0

var _wave := '[wave amp=14 freq=8].[/wave][wave amp=14 freq=9].[/wave][wave amp=14 freq=10].[/wave]'
var _showing := false
var _dflt_pos: Vector2
var _trgt_pos: Vector2
var _current_target: Node
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_dflt_pos = self.rect_position
	_trgt_pos = Vector2(_dflt_pos.x, _dflt_pos.y - y_offset)
	modulate.a = 0

	# Conectarse a señales de hijos
	$Tween.connect('tween_completed', self, '_on_Tween_completed')
	
	# Conectarse a señales del cielo de las señales
	Event.connect('talking_bubble_requested', self, '_place_bubble')

	hide()


func _process(delta):
	if _current_target and not $Tween.is_active():
		rect_global_position = _trgt_pos


func appear(_show := true) -> void:
	_showing = _show
	if _show:
		show()
		$Tween.remove_all()
		$RichTextLabel.clear()
		$RichTextLabel.append_bbcode(_wave)

	$Tween.interpolate_property(
		self,
		'rect_position:y',
		_dflt_pos.y if _show else _trgt_pos.y,
		_trgt_pos.y if _show else _dflt_pos.y,
		0.4 if _show else 0.2,
		Tween.TRANS_ELASTIC,
		Tween.EASE_OUT
	)
	$Tween.interpolate_property(
		self,
		'modulate:a',
		0 if _show else 1,
		1 if _show else 0,
		0.4 if _show else 0.2,
		Tween.TRANS_ELASTIC,
		Tween.EASE_OUT
	)
	$Tween.start()


func _on_Tween_completed(obj: Object, key: NodePath) -> void:
	if not _showing and modulate.a == 0.0:
		$RichTextLabel.clear()
		hide()


func _place_bubble(target: Node = null) -> void:
	if target:
		_current_target = target
		rect_global_position = Utils.get_screen_coords_for(_current_target)
		_dflt_pos = rect_global_position
		_trgt_pos = Vector2(_dflt_pos.x, _dflt_pos.y - y_offset)
		_trgt_pos.x -= rect_size.x / 2
		_trgt_pos.y -= rect_size.y + 8
		appear()
	else:
		_current_target = null
		appear(false)

