extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(bool) var in_intro = false
export(bool) var immortal = false
export(int) var health = 20

const MAGIC_FIRE = preload("res://src/Particles/MagicFireParticle.tscn")

var eaten_items = 0
var max_health
var max_size = 1

var first_visit = true

onready var _feed_shape: RectangleShape2D = $FeedArea/CollisionShape2D.shape
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	$InteractionArea.connect('area_entered', self, '_on_area_entered')
	$InteractionArea.connect('area_exited', self, '_on_area_exited')
	$FeedArea.connect('area_entered', self, '_check_food')
	$Timer.connect("timeout", self, "_on_Timer_timeout")

	max_health = health

func _process(delta):
	$AnimatedSprite.scale = Vector2.ONE * range_lerp(health, 0, max_health, 0, max_size)

func _on_area_entered(other):
	if other.get_name() == 'PlayerArea':
		if not first_visit:
			speak(tr("Demon_Greet"))
		else:
			speak(tr("Saludos, me alimentas o me muero :("))
			$Timer.start()
			first_visit = false

func _on_area_exited(other):
	if other.get_name() == 'PlayerArea':
		speak(tr("Demon_Goodbye"))

func eat(is_good: bool, carbs: int = 1):
	Event.emit_signal('play_requested','Demon', 'Eat')

	if in_intro:
		Event.emit_signal('intro_continued')
		return

	if is_good:
		if health < max_health:
			health += 10
		eaten_items += carbs

#		$AnimatedSprite.scale += Vector2.ONE * carbs
		_feed_shape.extents.x += carbs * 5

		yield(get_tree().create_timer(0.2), 'timeout')
		Event.emit_signal('play_requested','Demon', 'Grow')
	else:
#		$AnimatedSprite.scale -= Vector2.ONE * carbs
		_feed_shape.extents.x -= carbs * 5

		if eaten_items > 0:
			eaten_items -= carbs
		if health > 0:
			health -= 3

func speak(text):
	Event.emit_signal('character_spoke', 'Demon', text)


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
		print(health)
