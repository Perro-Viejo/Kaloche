class_name Player
extends "res://src/Characters/Actor.gd"

enum Tools {
	NONE,
	ROD,
	STICK,
	SHOVEL
}

var node_to_interact: Pickable = null setget _set_node_to_interact
var grabbing := false
var picked_item: Pickable = null
var on_ground := false
var fishing := false setget _set_fishing
var fs_id := 'Grass'
var foot := 'L'
var is_paused := false
var is_out := false
var is_moving := false
var dir := Vector2(0, 0)
var surface := fs_id setget _set_surface
var current_tool: int = Tools.NONE setget _set_current_tool
var rod_tip_pos := Vector2(-5, -4)
var rod_tip_offset := Vector2(11, -2)

var _is_camera_shaking := false
var _camera_shake_amount := 15.0
var _shake_timer := 0.0

onready var cam: Camera2D = $Camera2D
onready var fishing_spot: ColorRect = $FishingSpot
onready var foot_area: Area2D = $FootArea
onready var hook: Node2D = $Hook
onready var sprite := $Sprite
onready var rod_tip := $RodTip
onready var hook_target : Node2D = $HookTarget
onready var shadow := sprite.get_node('Shadow')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready() -> void:
	# Poner los objetos por defecto en el inventario
	(inventory as Inventory).set_default_items()
	# Hacer la configuración por defecto cuando el Player ya está en escena
	fishing_spot._fish_splash = $FishSplash
	hook.hide()
	# Escuchar eventos de los hijos de satán
	$FootArea.connect('area_entered', self, 'toggle_on_ground', [ true ])
	$FootArea.connect('area_exited', self, 'toggle_on_ground')
	hook_target.connect('area_entered', self, '_set_hook_drop_surface', [ true ])
	hook_target.connect('area_exited', self, '_set_hook_drop_surface', [ false ])

	# Conectarse a eventos del universo
	DialogEvent.connect('line_triggered', self, '_should_speak')
	PlayerEvent.connect('control_toggled', self, '_toggle_control')
	PlayerEvent.connect('camera_shaked', self, '_shake_camera')
	PlayerEvent.connect('camera_moved', self, '_move_camera')
	PlayerEvent.connect('camera_moved_to', self, '_move_camera_to')
	PlayerEvent.connect('camera_disabled', self, '_disable_camera')


func _process(delta) -> void:
	if _is_camera_shaking:
		_shake_timer -= delta
		$Camera2D.offset = Vector2(
			rand_range(-1.0, 1.0) * _camera_shake_amount,
			rand_range(-1.0, 1.0) * _camera_shake_amount
		)

		if _shake_timer <= 0.0:
			_is_camera_shaking = false
			$Camera2D.offset = Vector2.ZERO


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func change_zoom(out: bool = true) -> void:
	is_out = out
	
	if out:
		AudioEvent.emit_signal('play_requested', 'UI', 'ZoomOut')
	else:
		AudioEvent.emit_signal('play_requested', 'UI', 'ZoomIn')

	$Tween.remove_all()
	$Tween.interpolate_property(
		cam,
		'zoom',
		cam.zoom,
		Vector2.ONE * 2 if out else Vector2.ONE / 2,
		1.0 if out else 0.5,
		Tween.TRANS_QUINT,
		Tween.EASE_OUT
	)
	$Tween.start()

	yield($Tween, 'tween_completed')


func toggle_on_ground(body: Node2D, on: = false) -> void:
	if body.is_in_group('Surface'):
		if on:
			self.surface = body.fs_name
		else:
			self.surface = ''


func has_equiped() -> bool:
	return current_tool != Tools.NONE


func play_animation(animation_name := '') -> void:
	$AnimationPlayer.play(animation_name)


func stop_animation() -> void:
	$AnimationPlayer.stop()


# Agrega un Item al inventario cuando éste está vinculado a un Pickup
func pickup_item() -> void:
	(inventory as Inventory).add_to_inventory(picked_item.item)
	yield(get_tree().create_timer(0.1), 'timeout')
	is_paused = true
	picked_item.hide_interaction()
	# TODO: Hacer retroalimentación de agarrada de Pickup para inventario
	speak('Eeeeeeeeeeeeeeeeeeee')
	yield(get_tree().create_timer(2.0), 'timeout')
	speak('Ora tengo: %s' % tr(picked_item.item.name_code))
	grabbing = false
	picked_item.queue_free()
	picked_item = null
	is_paused = false


func change_zindex(new_value: int) -> void:
	z_index = new_value
	if picked_item:
		picked_item.z_index = new_value


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _toggle_control(props: Dictionary = {}) -> void:
	$StateMachine.transition_to_state($StateMachine.STATES.IDLE)
	is_paused = !is_paused
	
	if props.has('disable'):
		is_paused = props.disable

#	if props.has('disable_camera'):
#		cam.current = false


func _shake_camera(props: Dictionary) -> void:
	if props.has('strength'):
		_camera_shake_amount = props.strength
	if props.has('duration'):
		_shake_timer = props.duration
	if props.has('remove_control'):
		_toggle_control()
	_is_camera_shaking = true


func _move_camera(dis = Vector2.ZERO) -> void:
	if dis.x: cam.position.x += dis.x
	if dis.y: cam.position.y += dis.y


func _move_camera_to(target = Vector2.ZERO) -> void:
	cam.position = target


func _zoom_camera(zoom: Vector2) -> void:
	cam.zoom = zoom


func _disable_camera(is_current: bool) -> void:
	cam.current = !is_current
	

func _set_node_to_interact(new_node: Pickable) -> void:
	if node_to_interact:
		node_to_interact.hide_interaction()

	if new_node and new_node.is_in_group('Pickable'):
		new_node.show_interaction()

	node_to_interact = new_node


func _set_fishing(value: bool) -> void:
	fishing = value
	$StateMachine.state.play_animation()


func _set_surface(id := '') -> void:
	surface = id
	if not id:
		fs_id = 'Grass'
	else:
		fs_id = id


func _set_current_tool(tool_id: int) -> void:
	var i: Inventory = inventory
	if inventory.has_item('I_ROD'):
		current_tool = tool_id
		if $StateMachine.state == $StateMachine.STATES.IDLE:
			$StateMachine.state.on_tool_equiped(tool_id)
	else:
		speak('No tengo nada... y no [shake]se me para[/shake]')


func _set_hook_drop_surface(area: Area2D, entered: bool) -> void:
	if area.is_in_group('Surface'):
		if entered:
			hook.surface_ref = area as Surface
		else:
			hook.surface_ref = null
