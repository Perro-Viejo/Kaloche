extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var y_offset := 16.0

onready var _dflt_pos := self.position
onready var _trgt_pos := Vector2(_dflt_pos.x, _dflt_pos.y - y_offset)
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	modulate.a = 0
	hide()


func appear(_show := true) -> void:
	if not visible:
		show()

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
