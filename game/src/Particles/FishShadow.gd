# Controla el comportamiento de las sombras de los peces en las superficies
# en las que se puede pescar
extends Node2D

var size := 'sm'
var is_examining := false
var surface_ref: Area2D = null

var _timer: Timer = null
var _tween: Tween = null

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _enter_tree():
	if not is_examining:
		$AnimationPlayer.play('swim_%s' % size)

		_tween = Tween.new()
		add_child(_tween)

		_timer = Timer.new()
		_timer.wait_time = randi() % 5 + 1
		_timer.one_shot = true
		_timer.connect('timeout', self, 'swim')
		_timer.autostart = true

		add_child(_timer)
	else:
		$AnimationPlayer.play("examine_md")

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
# Hace que el pez se mueva en línea recta de un punto a otro para que parezca que
# está nadando
func swim() -> void:
	# Elegir un punto al cuál moverse
	var target := Vector2(randi() % 10, randi() % 10)
	if surface_ref.is_point_inside_polygon(target):
		_tween.interpolate_property(
			self, 'position',
			position, surface_ref.position + position + target,
			2, Tween.TRANS_SINE, Tween.EASE_OUT
		)
		_tween.start()
