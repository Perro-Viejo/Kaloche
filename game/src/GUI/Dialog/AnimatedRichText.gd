class_name AnimatedRichText
extends RichTextLabel
# Permite mostrar textos caracter por caracter en un RichTextLabel para aprove-
# char sus capacidades de animación y edición de fragmentos de texto.

signal animation_finished

export var secs_per_character := 1.0

var _wrapper := '%s'
var _is_waiting_input := false
#  Estos valores se toman de la configuración hecha en el Editor --------------
var _max_width := rect_size.x
var _dflt_height := rect_size.y
#  ----------------------------------------------------------------------------
var _target_size := Vector2.ONE

onready var _tween: Tween = $Tween
onready var _label_dflt_size: Vector2 = $Label.rect_size


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	# Establecer la configuración inicial
	clear()
	modulate.a = 0.0
	
	# Conectarse a señales de los hijos
	_tween.connect('tween_all_completed', self, '_wait_input')
	
	# Conectarse a señales del universo pokémon
	HudEvent.connect('hud_accept_pressed', self, 'stop')


func _process(delta: float) -> void:
	rect_position.x = 160 - (rect_size.x / 2)
	$Label.rect_position.x = 6


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func play_text(value: String, color: Color = Color('#ffffeb')) -> void:
	# Establecer el estado por defecto
	clear()
	push_color(color)
	append_bbcode(_wrapper % value)
	percent_visible = 0
	rect_size = Vector2.DOWN * _dflt_height

	# Se usa un Label para saber el ancho y alto que tendrá el RichTextLabel
	$Label.rect_size = _label_dflt_size
	$Label.text = text
	yield(get_tree(), 'idle_frame')
	_target_size = Vector2(
		min(_max_width, $Label.rect_size.x + 12.0),
		_dflt_height + (($Label.get_line_count() - 1) * 14.0)
	)

	# Si se quiere hacer de otro modo en el Inspector
	# (animation_speed * 0.01) * get_total_character_count()
	var duration: float = secs_per_character * $Label.get_total_character_count()
#	var size_duration := min(duration * 0.5, 1.0)
	var size_duration := 0.82

	_tween.interpolate_property(
		self, 'percent_visible',
		0, 1,
		duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	_tween.interpolate_property(
		self, 'rect_size:x',
		rect_size.x, _target_size.x,
		0.62, Tween.TRANS_BACK, Tween.EASE_OUT
	)
	if $Label.get_line_count() > 1:
		_tween.interpolate_property(
			self, 'rect_size:y',
			rect_size.y, _target_size.y,
			0.47, Tween.TRANS_SINE, Tween.EASE_IN,
			0.67
		)
	else:
		rect_size.y = _target_size.y

	modulate.a = 1.0
	_tween.start()


func stop(forced = false) ->void:
	if modulate.a == 0.0:
		return
	get_tree().set_input_as_handled()
	
	if not forced:
		if _is_waiting_input:
			_is_waiting_input = false
			_notify_completion()
		else:
			# Saltarse las animaciones
			_tween.remove_all()
			percent_visible = 1.0
			rect_size = _target_size
			_wait_input()
	else:
		_tween.remove_all()
		percent_visible = 1.0
		rect_size = _target_size
		_is_waiting_input = false
		_notify_completion()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _wait_input() -> void:
	_is_waiting_input = true


func _notify_completion() -> void:
	modulate.a = 0.0
	emit_signal('animation_finished')
