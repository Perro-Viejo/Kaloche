extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(bool) var in_intro = false
export(bool) var immortal = false
export(int) var health = 20
export(Color) var dialog_color

const MAGIC_FIRE = preload("res://src/Particles/MagicFireParticle.tscn")

var eaten_items = 0
var max_health
var max_size = 1

var first_visit = true
#
onready var _feed_shape: CircleShape2D = $FeedArea/CollisionShape2D.shape
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	$InteractionArea.connect('area_entered', self, '_on_area_entered')
	$InteractionArea.connect('area_exited', self, '_on_area_exited')
	$FeedArea.connect('area_entered', self, '_check_food')
	$Timer.connect("timeout", self, "_on_Timer_timeout")

	max_health = health

func _process(delta):
	$AnimatedSprite.scale = Vector2.ONE * range_lerp(health, 0, max_health, 0, max_size)
	$FeedArea/CollisionShape2D/Feed.scale = $AnimatedSprite.scale
	_feed_shape.radius = lerp(1, 14, $AnimatedSprite.scale.y)


func eat(is_good: bool, carbs: int = 1):
	eaten_items += 1
	Event.emit_signal('play_requested','Demon', 'Eat')

	if in_intro:
		Event.emit_signal('intro_continued')
		return

	if is_good:
		if health < max_health:
			health += 10
#		Todavia no se si quitar este
#		eaten_items += carbs

		yield(get_tree().create_timer(0.2), 'timeout')
		Event.emit_signal('play_requested','Demon', 'Grow')
	else:
#		_feed_shape.extents.x -= carbs * 5

		if eaten_items > 0:
			eaten_items -= carbs
		if health > 0:
			health -= 3


func speak(text := '', time_to_disappear := 0):
	Event.emit_signal('character_spoke', self, text, time_to_disappear)
	$TalkingBubble.appear()


# Sirve para disparar comportamientos cuando se ha completado un diálogo
func spoke():
	$TalkingBubble.appear(false)


func _on_area_entered(other):
	if Data.get_data(Data.CURRENT_SCENE) != 'World': return

	if other.get_name() == 'PlayerArea':
		if not first_visit:
			speak(tr("Demon_Greet"))
		else:
			speak(tr("Saludos, me alimentas o me muero :("))
			$Timer.start()
			first_visit = false


func _on_area_exited(other):
	if Data.get_data(Data.CURRENT_SCENE) != 'World': return

	if other.get_name() == 'PlayerArea':
		speak(tr("Demon_Goodbye"))


func _check_food(body: Node) -> void:
	if body.is_in_group('Pickable') and not (body as Pickable).being_grabbed:
		var pickable: Pickable = body as Pickable
		var particle = MAGIC_FIRE.instance()
		add_child(particle)
		particle.set_global_position(pickable.get_position())
		particle.scale = scale
		Event.emit_signal('play_requested','Demon', 'Burn')
		Event.emit_signal('play_requested','Demon', 'Ignite')
		pickable.set_z_index(-1)
		pickable.set_monitoring(false)
		match pickable.name:
			'Iguana':
				speak(tr("Mmm... sabrosa y protectora Teyú"))
				max_size = max_size * 2
				max_health = max_health * 2
				health = max_health
			'Jaguar':
				speak(tr("Yum Yum... puedo saborear los misterios ocultos del Jaguar"))
				max_size = max_size * 2
				max_health = max_health * 2
				health = max_health
			'Cricket':
				speak(tr("No tuviste suerte esta vez Grillito"))
				max_size = max_size * 2
				max_health = max_health * 2
				health = max_health
			'Hen':
				speak(tr("¡Deliciosa gallina! Nada sagrada por cierto... -.-"))
			'Mico':
				speak(tr("Es muy sabio el viejo macaco, pero eso no lo hace sagrado... -.-"))
			_:
				if pickable.is_good:
					speak(tr("Demon_Eat_pos"))
				else:
					speak(tr("Demon_Eat_neg"))
		yield(get_tree().create_timer(3), 'timeout')
		Event.emit_signal('stop_requested','Demon', 'Burn')
		eat(pickable.is_good, pickable.carbs)
		pickable.queue_free()
		particle.queue_free()


func _on_Timer_timeout():
	if not immortal:
		if health > 0:
			health -= 1
		else:
			print('memori')
			queue_free()
			$Timer.stop()
#		print(health)