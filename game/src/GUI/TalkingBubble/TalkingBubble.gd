extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var y_offset := 16.0

var _wave := '[wave amp=14 freq=8].[/wave][wave amp=14 freq=9].[/wave][wave amp=14 freq=10].[/wave]'
var _showing := false
var _dflt_pos: Vector2
var _trgt_pos: Vector2
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_dflt_pos = self.position
	_trgt_pos = Vector2(_dflt_pos.x, _dflt_pos.y - y_offset)
	modulate.a = 0

	# Conectarse a señales de hijos
	$Tween.connect('tween_completed', self, '_on_Tween_completed')

	hide()


func appear(_show := true) -> void:
	_showing = _show
	if not visible:
		show()
		$RichTextLabel.append_bbcode(_wave)

	$Tween.interpolate_property(
		self,
		'position:y',
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
