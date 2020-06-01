extends Node2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(bool) var in_intro = false

const MAGIC_FIRE = preload("res://src/Particles/MagicFireParticle.tscn")

var eaten_items = 0

onready var _feed_shape: RectangleShape2D = $FeedArea/CollisionShape2D.shape
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	$InteractionArea.connect('area_entered', self, '_on_area_entered')
	$InteractionArea.connect('area_exited', self, '_on_area_exited')
	$FeedArea.connect('area_entered', self, '_check_food')

func _on_area_entered(other):
	if other.get_name() == 'Player':
		speak(tr("Demon_Greet"))

func _on_area_exited(other):
	if other.get_name() == 'Player':
		speak(tr("Demon_Goodbye"))

func eat(is_good: bool, carbs: int = 1):
	Event.emit_signal('play_requested','Demon', 'Eat')

	if in_intro:
		Event.emit_signal('intro_continued')
		return

	if is_good:
		eaten_items += carbs

		speak(tr("Demon_Eat_pos"))

		$AnimatedSprite.scale += Vector2.ONE * carbs
		_feed_shape.extents.x += carbs * 5

		yield(get_tree().create_timer(0.2), 'timeout')
		Event.emit_signal('play_requested','Demon', 'Grow')
	else:
		speak(tr("Demon_Eat_neg"))

		$AnimatedSprite.scale -= Vector2.ONE * carbs
		_feed_shape.extents.x -= carbs * 5

		if eaten_items > 0:
			eaten_items -= carbs

func speak(text):
	Event.emit_signal('character_spoke', 'Demon', text)
	yield(get_tree().create_timer(2), 'timeout')


func _check_food(body: Node) -> void:
	if body.is_in_group('Pickable') and not (body as Pickable).being_grabbed:
		var pickable: Pickable = body as Pickable
		var particle = MAGIC_FIRE.instance()
		add_child(particle)
		particle.set_global_position(pickable.get_position())
		Event.emit_signal('play_requested','Demon', 'Burn')
		Event.emit_signal('play_requested','Demon', 'Ignite')
		pickable.set_z_index(-1)
		pickable.set_monitoring(false)
		yield(get_tree().create_timer(3), 'timeout')
		Event.emit_signal('stop_requested','Demon', 'Burn')
		eat(pickable.is_good, pickable.carbs)
		pickable.queue_free()
		particle.queue_free()
