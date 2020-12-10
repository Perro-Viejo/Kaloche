class_name Demon
extends "res://src/Characters/Actor.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(bool) var in_intro = false

const MAGIC_FIRE = preload("res://src/Particles/MagicFireParticle.tscn")

var eaten_items = 0
var max_size = 1
var first_visit = true

onready var _feed_shape: CircleShape2D = $FeedArea/CollisionShape2D.shape
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	
	# Conectarse a eventos de los hijos
	$InteractionArea.connect('area_entered', self, '_on_area_entered')
	$InteractionArea.connect('area_exited', self, '_on_area_exited')
	$FeedArea.connect('area_entered', self, '_check_food')
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	# Conectarse a eventos del universo
	DialogEvent.connect('line_triggered', self, '_should_speak')

	max_health = health

func eat(is_good: bool, carbs: int = 1, name: String = '', sacred: bool = false):
	eaten_items += 1
	AudioEvent.emit_signal('play_requested','Demon', 'Eat')

	if in_intro:
		return

	if is_good:
		if health < max_health:
			health += 10

		yield(get_tree().create_timer(0.2), 'timeout')
		AudioEvent.emit_signal('play_requested','Demon', 'Grow')
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

func _on_area_entered(other):
	if Data.get_data(Data.CURRENT_SCENE) != 'World': return

	if other.get_name() == 'PlayerArea':
		if not first_visit:
			speak(tr("DEMON_GREET"))
		else:
			first_visit = false
			_in_dialog = true

			PlayerEvent.emit_signal('control_toggled')
			DialogEvent.connect('dialog_finished', self, '_dialog_finished')
			DialogEvent.emit_signal('dialog_requested', 'Salute')
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
			DialogEvent.emit_signal('dialog_event', true, .3, 3)
			sacred = true
		else:
			DialogEvent.emit_signal('dialog_event', true, .5 , 2.1)
		AudioEvent.emit_signal('play_requested','Demon', 'Burn')
		AudioEvent.emit_signal('play_requested','Demon', 'Ignite')
		pickable.set_z_index(-1)
		pickable.set_monitoring(false)
		yield(get_tree().create_timer(3), 'timeout')
		AudioEvent.emit_signal('stop_requested','Demon', 'Burn')
		eat(pickable.is_good, pickable.carbs, pickable.name, sacred)
		pickable.queue_free()
		particle.queue_free()


func _on_Timer_timeout():
	if not immortal:
		if health > 0:
			health -= 1
		else:
			$Timer.stop()
			


func _dialog_finished() -> void:
	DialogEvent.disconnect('dialog_finished', self, '_dialog_finished')
	PlayerEvent.emit_signal('control_toggled')
