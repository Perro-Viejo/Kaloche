extends "res://src/StateMachine/State.gd"

export(float) var speed = 2

var dir:Vector2 = Vector2.ZERO
var can_move = true

var _last_dir: Vector2 = Vector2.ZERO

onready var _calc_speed: float = speed * 60


func _ready():
	DialogEvent.connect('dialog_event', self, '_on_dialog_event')

func _unhandled_input(event: InputEvent) -> void:
	if _parent.is_paused: return

	if event.is_action_pressed('Action'):
#		if _parent.fishing:
#			_parent.fishing_spot.pull_fish()
		if _parent.has_equiped():
			match _parent.current_tool:
				_parent.Tools.ROD:
					# Inicia la pesca
					_state_machine.transition_to_state(_state_machine.STATES.FISHPREPARE)
		elif _parent.node_to_interact and not _parent.grabbing:
			_state_machine.transition_to_state(_state_machine.STATES.GRAB)
	elif event.is_action_pressed('Drop'):
		if _parent.node_to_interact:
			if _parent.grabbing:
				_state_machine.transition_to_state(
					_state_machine.STATES.DROP, { dir = _last_dir }
				)
			elif _parent.node_to_interact.dialog:
				DialogEvent.emit_signal('dialog_requested', _parent.node_to_interact.dialog)

	elif event.is_action_pressed('Equip'):
		if _parent.has_equiped():
			_parent.current_tool = _parent.Tools.NONE
		else:
			_parent.current_tool = _parent.Tools.ROD
		# TODO: Aquí se equipará el objeto seleccionado en el inventario. Por
		#		ahora será la caña porque no tenemos más.
		
#		if _parent.fishing:
#			_state_machine.transition_to_state(_state_machine.STATES.IDLE)
#		else:
#			if not _parent.grabbing and not _parent.is_moving:
#				_state_machine.transition_to_state(_state_machine.STATES.FISH)


func _physics_process(delta) -> void:
	if not can_move or _parent.is_paused:
		return

	dir.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	dir.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	
	_parent.dir = dir
	
	if dir.x != 0:
		_last_dir.x = dir.x
		_last_dir.y = 0

		owner.sprite.flip_h = dir.x < 0

	elif dir.y != 0:
		_last_dir.x = 0
		_last_dir.y = dir.y
	
	if not _parent.is_out:
		_parent.move_and_collide(dir * _calc_speed * delta)
	else:
		_parent.move_and_collide(dir * _calc_speed * 2 * delta)
		
	if dir != Vector2(0,0) and not _parent.is_moving:
		_state_machine.transition_to_state(_state_machine.STATES.WALK)
	elif dir == Vector2(0,0) and _parent.is_moving:
		_state_machine.transition_to_state(_state_machine.STATES.IDLE)

	if _parent.grabbing and _parent.node_to_interact:
		_parent.node_to_interact.global_position = _parent.global_position
		_parent.node_to_interact.position.y -= 7

func _on_dialog_event(playing, countdown, duration):
	if playing:
		yield(get_tree().create_timer(countdown), 'timeout')
		_state_machine.transition_to_state(_state_machine.STATES.IDLE)
		toggle_movement()
		yield(get_tree().create_timer(duration), 'timeout')
		toggle_movement()

func toggle_movement():
	can_move = !can_move

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func exit() -> void:
	.exit()
