tool
class_name Pickable
extends Area2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export var is_good := true
export var can_burn := true
export var carbs := 2
export var img: Texture setget set_sprite_texture
export var on_free := ''
export var tr_code := ''
export var character := ''
export var dialog := ''

var being_grabbed := false setget set_being_grabbed

var _hides: Area2D
var _respawn_position: Vector2
var _original_position: Vector2
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	if is_in_group('Sacred'):
		_original_position = global_position
	connect('area_entered', self, '_check_collision', [ true ])
	connect('area_exited', self, '_check_collision')
	
	if character:
		DialogEvent.connect('line_triggered', self, '_should_speak')

	# Si el objeto tiene otro Pickable por dentro, ocultarlo. La idea es que ese
	# que es el hijo sólo se haga visible cuando el jugador agarre el contenedor
	for child in get_children():
		if child.is_in_group('Pickable'):
			_hides = child as Pickable

			_hides.hide() # ja!
			_hides.toggle_collision(false)

	hide_interaction()


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
	
	if being_grabbed:
		$Shadow.hide()
	else:
		$Shadow.show()

	hide_interaction()

	# Sacar el objeto ocultiño
	if _hides:
		var dup: Pickable = _hides.duplicate() as Pickable
		dup.global_position = global_position
		dup.visible = true
		dup.toggle_collision()
		dup.connect('ready', self, '_hidden_in_tree', [dup])

		get_parent().call_deferred('add_child', dup)

		_hides.queue_free()

		_hides = null


func toggle_collision(enable: bool = true) -> void:
	$CollisionShape2D.disabled = !enable


func _check_collision(area: Node2D, grab: bool = false) -> void:
	if area.name != 'PlayerArea': return

	var player = area.get_parent()

	if player.grabbing: return

	if grab:
		player.node_to_interact = self
	else:
		player.node_to_interact = null


func _should_speak(character_name, text, time, emotion) -> void:
	if character.to_lower() == character_name:
		DialogEvent.emit_signal('character_spoke', self, text, time)
		AudioEvent.emit_signal('dx_requested' , character_name, emotion)


func _hidden_in_tree(dup: Pickable) -> void:
	if dup.character != '':
		pass
	if dup.on_free != '':
		DialogEvent.emit_signal('dialog_requested', dup.on_free)


func hide_interaction() -> void:
	HudEvent.emit_signal('name_bubble_requested')
	$Outline.hide()


func show_interaction() -> void:
	if being_grabbed: return
	
	HudEvent.emit_signal(
		'name_bubble_requested',
		self,
		tr('P_' + (tr_code if tr_code else name).to_upper())
	)
	$Outline.show()

func get_class() -> String:
	return "Pickable"

func respawn(_position = null) -> void:
	if _position:
		_respawn_position = _position
	else:
		_respawn_position = _original_position
	show()
	position = _respawn_position
 
