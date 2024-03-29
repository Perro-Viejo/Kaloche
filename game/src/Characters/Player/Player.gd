 class_name Player
extends Actor

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
var surfaces_queue := []
var current_tool: int = Tools.NONE setget _set_current_tool
var rod_tip_pos := Vector2(-5, -4)
var rod_tip_offset := Vector2(11, -2)
var in_cutscene := false
var current_cam_offset := Vector2.ZERO

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
onready var behind: Sprite = $Overlay


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	# Poner los objetos por defecto en el inventario
	(inventory as Inventory).set_default_items()
	# Hacer la configuración por defecto cuando el Player ya está en escena
	fishing_spot._fish_splash = $FishSplash
	hook.hide()
	# Escuchar eventos de los hijos de satán
	$FootArea.connect('area_entered', self, 'toggle_on_ground', [ true ])
	$FootArea.connect('area_exited', self, 'toggle_on_ground')
	hook_target.connect('area_entered', self, '_set_hook_drop_surface')

	# Conectarse a eventos del universo
	PlayerEvent.connect('control_toggled', self, '_toggle_control')
	PlayerEvent.connect('camera_shook', self, '_shake_camera')
	PlayerEvent.connect('camera_moved', self, '_move_camera')
	PlayerEvent.connect('camera_moved_to', self, '_move_camera_to')
	PlayerEvent.connect('camera_disabled', self, '_disable_camera')
	
	Console.add_command('change_zoom', self)\
			.add_argument('out', TYPE_BOOL)\
			.register()


func _process(delta) -> void:
	if _is_camera_shaking:
		_shake_timer -= delta
		$Camera2D.offset = current_cam_offset + Vector2(
			rand_range(-1.0, 1.0) * _camera_shake_amount,
			rand_range(-1.0, 1.0) * _camera_shake_amount
		)

		if _shake_timer <= 0.0:
			_is_camera_shaking = false
			$Camera2D.offset = current_cam_offset


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
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
		Vector2.ONE * 2 if out else Vector2.ONE,
		1.0 if out else 0.5,
		Tween.TRANS_QUINT,
		Tween.EASE_OUT
	)
	$Tween.start()

	yield($Tween, 'tween_completed')

func fishing_zoom(zooming: bool, start: bool = false):
	if start:
		AudioEvent.emit_signal('play_requested', 'Fishing', 'whoosh_in')
		$Tween.interpolate_property(
			cam,
			'offset',
			cam.offset,
			hook.position,
			.9,
			Tween.TRANS_EXPO,
			Tween.EASE_OUT,
			.2
		)
		$Tween.start()
		speak('')
	else:
		if zooming:
			if not $Tween.is_active():
				$Tween.interpolate_property(
					cam,
					'zoom',
					cam.zoom,
					cam.zoom * Vector2.ONE * 0.95,
					.6,
					Tween.TRANS_EXPO,
					Tween.EASE_OUT
				)
				$Tween.start()
		else:
			$Tween.interpolate_property(
				cam,
				'offset',
				cam.offset,
				Vector2.ZERO,
				.8,
				Tween.TRANS_EXPO,
				Tween.EASE_OUT
			)
			$Tween.interpolate_property(
				cam,
				'zoom',
				cam.zoom,
				Vector2.ONE,
				.8,
				Tween.TRANS_EXPO,
				Tween.EASE_OUT
			)
			$Tween.start()
			if not cam.offset == Vector2.ZERO:
				AudioEvent.emit_signal('play_requested', 'Fishing', 'whoosh_out')

func toggle_on_ground(body: Node2D, on: = false) -> void:
	if body.is_in_group('Surface'):
		var assigned_surface: Surface = null
		
		if on:
			var do_append := true
			if not surfaces_queue.empty():
				var last: Surface = surfaces_queue.back()
				
				if Utils.get_global_index(body) < Utils.get_global_index(last):
					do_append = false
					surfaces_queue.insert(surfaces_queue.size() - 1, body)
					assigned_surface = last
			
			if do_append:
				surfaces_queue.append(body)
				assigned_surface = body
		else:
			if not surfaces_queue.empty():
				if surfaces_queue.back().get_instance_id() == body.get_instance_id():
					surfaces_queue.pop_back()
				else:
					surfaces_queue.erase(body)

			if surfaces_queue.empty():
				self.surface = ''
				movement_speed_multiplier = Vector2.ONE
			else:
				assigned_surface = surfaces_queue.back()
		
		if is_instance_valid(assigned_surface):
			self.surface = assigned_surface.surface_name
			movement_speed_multiplier = assigned_surface.speed_multiplier


func has_equiped() -> bool:
	return current_tool != Tools.NONE


func play_animation(animation_name := '') -> void:
	$AnimationPlayer.play(animation_name)


func stop_animation() -> void:
	$AnimationPlayer.stop()


# Agrega un Item al inventario cuando éste está vinculado a un Pickup
func pickup_item() -> void:
	AudioEvent.emit_signal('play_requested','Player','Pickup_Tool', global_position)
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
	AudioEvent.emit_signal('play_requested','Player','Item_Disappear', global_position)
	is_paused = false
	
	#No estoy seguro si aquí es el mejor lugar para esto
	if picked_item.item.name_code == 'I_ROD':
		yield(get_tree().create_timer(1), 'timeout')
		DialogEvent.emit_signal('dialog_requested', 'Chapter0.1/DSacapayaraTemple', 'rod_grabbed')
	
	picked_item = null


func change_zindex(new_value: int) -> void:
	z_index = new_value
	if picked_item:
		picked_item.z_index = new_value


func react():
	speak('')
	$Exclamation.play('react')
	AudioEvent.emit_signal('play_requested', 'Player', 'react_fish', global_position)
	$Exclamation.show()
	yield(get_tree().create_timer(0.6), 'timeout')
	$Exclamation.hide()
	$Exclamation.stop()


func toggle_behind(ref_z_index: int) -> void:
	if ref_z_index <= self.z_index:
		behind.hide()
	else:
		behind.show()


func focus_camera_to(target: Node2D = null, is_in_queue = true) -> void:
	if is_in_queue: yield()
	
	cam.global_position = target.global_position
	yield(get_tree().create_timer(1.0), 'timeout')


func reset_camera(is_in_queue = true) -> void:
	if is_in_queue: yield()

	cam.position = Vector2.ZERO
	cam.zoom = Vector2.ONE

	yield(get_tree(), 'idle_frame')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _toggle_control(props: Dictionary = {}) -> void:
	$StateMachine.transition_to_state($StateMachine.STATES.IDLE)
	is_paused = !is_paused
	WorldEvent.player_blocked = is_paused
	
	if props.has('disable'):
		is_paused = props.disable
	
	if (props.has('is_cutscene') and props.is_cutscene) or in_cutscene:
		in_cutscene = is_paused
		HudEvent.emit_signal('cutscene_started' if is_paused else 'cutscene_ended')

#	if props.has('disable_camera'):
#		cam.current = false


func _shake_camera(props: Dictionary) -> void:
	current_cam_offset = $Camera2D.offset
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
		if $StateMachine.state.has_method('on_tool_equiped'):
			$StateMachine.state.on_tool_equiped(tool_id)
			if current_tool:
				match current_tool:
					1: 
						AudioEvent.emit_signal('play_requested', 'Player', 'Equip_Rod', global_position)
	else:
		AudioEvent.emit_signal('play_requested', 'Player', 'False_Equip', global_position)
		speak('No tengo nada... y no [shake]se me para[/shake]')


func _set_hook_drop_surface(area: Area2D) -> void:
	if area.is_in_group('Surface'):
		hook.surface_ref = area as Surface
