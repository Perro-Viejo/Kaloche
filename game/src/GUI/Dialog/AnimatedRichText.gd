extends RichTextLabel
class_name AnimatedRichText

export var secs_per_character := 1.0

var _wrapper := '%s'

onready var _tween: Tween = $Tween


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	clear()
	modulate.a = 0.0


func _process(delta: float) -> void:
	rect_position.x = 160 - (rect_size.x / 2)
	$Label.rect_position.x = 6


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func play_text(value: String) -> void:
	clear()
	bbcode_text = _wrapper % value
	percent_visible = 0
	$Label.text = ''

	# Se usa un Label para saber el ancho que tendrá el texto
	$Label.text = text
	yield(get_tree(), 'idle_frame')

	prints('cuenta:', get_total_character_count())
	# Si se quiere hacer de otro modo en el Inspector
	# (animation_speed * 0.01) * get_total_character_count()
	var duration := secs_per_character * get_total_character_count()
	prints('duración":', duration)
	_tween.interpolate_property(
		self, 'percent_visible',
		0, 1,
		duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	_tween.interpolate_property(
		self, 'rect_size:x',
		rect_size.x, $Label.rect_size.x + 12,
		duration * 0.8, Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	_tween.start()
	modulate.a = 1.0


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
