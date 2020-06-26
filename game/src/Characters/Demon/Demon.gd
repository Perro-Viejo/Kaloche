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
var previous_text = ''
var first_visit = true

var _in_dialog := false

onready var _feed_shape: CircleShape2D = $FeedArea/CollisionShape2D.shape
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	# Conectarse a eventos de los hijos
	$InteractionArea.connect('area_entered', self, '_on_area_entered')
	$InteractionArea.connect('area_exited', self, '_on_area_exited')
	$FeedArea.connect('area_entered', self, '_check_food')
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	# Conectarse a eventos del universo
	Event.connect('line_triggered', self, '_should_speak')

	max_health = health

func _process(delta):
	$AnimatedSprite.scale = Vector2.ONE * range_lerp(health, 0, max_health, 0, max_size)
	$FeedArea/CollisionShape2D/Feed.scale = $AnimatedSprite.scale
	_feed_shape.radius = lerp(1, 14, $AnimatedSprite.scale.y)
#	$Idle.set_pitch_scale(range_lerp(health, 0, max_health, 3, 1))
#	$InteractionArea/Area.shape.radius = lerp(1, 20, $AnimatedSprite.scale.y)


func eat(is_good: bool, carbs: int = 1, name: String = '', sacred: bool = false):
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
		if sacred:
			max_size = max_size * 2
			max_health = max_health * 2
			health = max_health
		match name:
			'Iguana':
				speak(tr("DEMON_EAT_IGUANA"))
			'Jaguar':
				speak(tr("DEMON_EAT_JAGUAR"))
			'Cricket':
				speak(tr("DEMON_EAT_CRICKET"))
			'Hen':
				speak(tr("DEMON_EAT_HEN"))
			'Mico':
				speak(tr("DEMON_EAT_MONKEY"))
			_:
				speak(tr("DEMON_EAT_POS"))
		$Timer.set_paused(false)
	else:
		if eaten_items > 0:
			eaten_items -= carbs
		if health > 0:
			health -= 3
		speak(tr("DEMON_EAT_NEG"))


func speak(text := '', time_to_disappear := 0):
	if text == previous_text:
		return
	else:
		previous_text = text
		$TalkingBubble.appear()
		Event.emit_signal('character_spoke', self, text, time_to_disappear)


# Sirve para disparar comportamientos cuando se ha completado un diálogo
func spoke():
	$TalkingBubble.appear(false)

	if _in_dialog:
		Event.emit_signal('dialog_continued')


func _on_area_entered(other):
	if Data.get_data(Data.CURRENT_SCENE) != 'World': return

	if other.get_name() == 'PlayerArea':
		if not first_visit:
			speak(tr("DEMON_GREET"))
		else:
			first_visit = false
			_in_dialog = true

			Event.connect('dialog_finished', self, '_dialog_finished')
			Event.emit_signal('dialog_event', true, 2, 7)
			Event.emit_signal('dialog_requested', 'Salute')
			# Iniciar a quitarle vida al Kaloche
			$Timer.start()


func _on_area_exited(other):
	if Data.get_data(Data.CURRENT_SCENE) != 'World': return

	if other.get_name() == 'PlayerArea':
		speak(tr("DEMON_GOODBYE"))


func _check_food(body: Node) -> void:
	$Timer.set_paused(true)
	if body.is_in_group('Pickable') and not (body as Pickable).being_grabbed:
		var pickable: Pickable = body as Pickable
		var particle = MAGIC_FIRE.instance()
		var sacred = false
		add_child(particle)
		particle.set_global_position(pickable.get_position())
		particle.scale = scale
		if pickable.is_in_group('Sacred'):
			Event.emit_signal('dialog_event', true, .3, 3)
			sacred = true
		else:
			Event.emit_signal('dialog_event', true, .5 , 2.1)
		Event.emit_signal('play_requested','Demon', 'Burn')
		Event.emit_signal('play_requested','Demon', 'Ignite')
		pickable.set_z_index(-1)
		pickable.set_monitoring(false)
		yield(get_tree().create_timer(3), 'timeout')
		Event.emit_signal('stop_requested','Demon', 'Burn')
		eat(pickable.is_good, pickable.carbs, pickable.name, sacred)
		pickable.queue_free()
		particle.queue_free()


func _on_Timer_timeout():
	if not immortal:
		if health > 0:
			health -= 1
		else:
			$Timer.stop()
			queue_free()


func _should_speak(character_name, text, time) -> void:
	if name.to_lower() == character_name:
		speak(text, time)


func _dialog_finished() -> void:
	_in_dialog = false
	spoke()
