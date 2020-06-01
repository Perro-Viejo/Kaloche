tool
class_name Pickable
extends Area2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(bool) var is_good = true
export(int) var carbs = 2
export(Texture) var img setget set_sprite_texture
export(String) var on_free = ''
export(String) var tr_code = ''

var being_grabbed: bool = false setget set_being_grabbed

var _hides: Pickable
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	$Bubble/Label.text = 'P_' + (tr_code if tr_code != '' else name).to_upper()
	$Bubble.rect_position.x -= ($Bubble.rect_size / 2).x

	connect('area_entered', self, '_check_collision', [ true ])
	connect('area_exited', self, '_check_collision')

	# Si el objeto tiene otro Pickable por dentro, ocultarlo. La idea es que ese
	# que es el hijo sólo se haga visible cuando el jugador agarre el contenedor
	for child in get_children():
		if child.is_in_group('Pickable'):
			_hides = child as Pickable

			_hides.hide() # ja!
			_hides.toggle_collision(false)

	$Outline.hide()
	$Bubble.hide()


func set_sprite_texture(tex: Texture) -> void:
	img = tex
	if has_node('Sprite'): $Sprite.texture = img


func set_being_grabbed(new_val: bool) -> void:
	being_grabbed = new_val
	# Hacer que el objeto no se pueda monitorear mientras está siendo cargado
	# por el jugador... así se asegura que si éste lo suelta estándo dentro del
	# área de comilona de elfuegoquequiereconsumiralmundo, detectará "la caída"
	# del objeto y se lo comerá
	monitorable = !new_val

	$Outline.hide()
	$Bubble.hide()

	# Sacar el objeto ocultiño
	if _hides:
		var dup: Pickable = _hides.duplicate() as Pickable
		dup.global_position = global_position
		dup.visible = true
		dup.toggle_collision()
		if dup.on_free != '':
			Event.emit_signal('character_spoke', 'Pickable', tr(dup.on_free))

		get_parent().call_deferred('add_child', dup)

		_hides.queue_free()

		_hides = null


func toggle_collision(enable: bool = true) -> void:
	$CollisionShape2D.disabled = !enable


func _check_collision(area: Node2D, grab: bool = false) -> void:
	if area.name != 'PlayerArea': return

	var player: Player = area.get_parent() as Player

	if player.grabbing: return

	if grab:
		player.can_grab = self
		$Bubble.show()
		$Outline.show()
	else:
		player.can_grab = null
		$Bubble.hide()
		$Outline.hide()
