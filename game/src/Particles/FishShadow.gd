# Controla el comportamiento de las sombras de los peces en las superficies
# en las que se puede pescar
extends Node2D

var size := 'sm'
var is_examining := false
var surface_ref: Area2D = null

var _timer: Timer = null
var _tween: Tween = null

onready var _dflt_pos := position

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _enter_tree():
	if not is_examining:
		$AnimationPlayer.play('swim_%s' % size)

		_tween = Tween.new()
		_tween.connect('tween_completed', self, 'swim')
		add_child(_tween)

		_timer = Timer.new()
		_timer.wait_time = randi() % 5 + 1
		_timer.one_shot = true
		_timer.connect('timeout', self, 'swim')
		_timer.autostart = true

		add_child(_timer)
	else:
		$AnimationPlayer.play('examine_md')

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
# Hace que el pez se mueva en línea recta de un punto a otro para que parezca que
# está nadando.
func swim(_obj: Object = null, _key: NodePath = '') -> void:
	if _obj:
		# Si entra aquí, es porque viene del Tween de desplazamiento que se
		# completó
		_timer.wait_time = randi() % 5 + 1
		_timer.start()
		return
	
	# Elegir un punto al cuál moverse
	randomize()
	var rnd_point := Vector2(rand_range(-5.0, 5.0), rand_range(-5.0, 5.0))
	var target := _dflt_pos + rnd_point
	if surface_ref: 
		if surface_ref.is_point_inside_polygon(target):
			_tween.interpolate_property(
				self, 'position',
				position, target,
				2, Tween.TRANS_SINE, Tween.EASE_OUT
			)
			_tween.start()
		else:
			print('¡Ay! por allá no puedo nadar')
			swim()
