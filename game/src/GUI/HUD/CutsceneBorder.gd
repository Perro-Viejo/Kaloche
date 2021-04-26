extends Control

onready var _dflt_top_y: float = $Top.rect_position.y
onready var _dflt_bottom_y: float = $Bottom.rect_position.y


func _ready() -> void:
	modulate.a = 0.0
	$Top.rect_position.y -= $Top.rect_min_size.y
	$Bottom.rect_position.y += $Bottom.rect_min_size.y


func toggle(appear: bool) -> void:
	$Tween.remove_all()

	if appear:
		modulate.a = 1.0
		$Tween.interpolate_property(
			$Top, 'rect_position:y',
			$Top.rect_position.y, _dflt_top_y,
			0.3, Tween.TRANS_SINE, Tween.EASE_OUT
		)
		$Tween.interpolate_property(
			$Bottom, 'rect_position:y',
			$Bottom.rect_position.y, _dflt_bottom_y,
			0.3, Tween.TRANS_SINE, Tween.EASE_OUT
		)
		$Tween.start()
	else:
		$Tween.interpolate_property(
			$Top, 'rect_position:y',
			_dflt_top_y, _dflt_top_y - $Top.rect_min_size.y,
			0.2, Tween.TRANS_SINE, Tween.EASE_OUT
		)
		$Tween.interpolate_property(
			$Bottom, 'rect_position:y',
			_dflt_bottom_y, _dflt_bottom_y + $Bottom.rect_min_size.y,
			0.2, Tween.TRANS_SINE, Tween.EASE_OUT
		)
		$Tween.start()
		yield($Tween, 'tween_all_completed')
		modulate.a = 0.0
