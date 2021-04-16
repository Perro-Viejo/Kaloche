extends "res://src/StateMachine/State.gd"

export(float) var speed = 2

var dir:Vector2 = Vector2.ZERO
var can_move = true

var _last_dir: Vector2 = Vector2.ZERO

onready var _calc_speed: float = speed * 60

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	DialogEvent.connect('dialog_event', self, '_on_dialog_event')


func _unhandled_input(event: InputEvent) -> void:
	if owner.is_paused: return

	if event.is_action_pressed('Action'):
		if owner.has_equiped():
			if owner.node_to_interact:
				owner.current_tool = owner.Tools.NONE
				_state_machine.transition_to_state(_state_machine.STATES.GRAB)
			else:
				match owner.current_tool:
					owner.Tools.ROD:
						# Inicia la pesca
						_state_machine.transition_to_state(_state_machine.STATES.FISHPREPARE)
		elif owner.node_to_interact and not owner.grabbing:
			_state_machine.transition_to_state(_state_machine.STATES.GRAB)
		elif owner.node_to_interact and owner.grabbing:
			_state_machine.transition_to_state(
				_state_machine.STATES.DROP, { dir = _last_dir }
			)
	#El evento de drop por si acaso...
#	elif event.is_action_pressed('Drop'):
#		if owner.node_to_interact:
#			if owner.grabbing:
#				_state_machine.transition_to_state(
#					_state_machine.STATES.DROP, { dir = _last_dir }
#				)
#			elif owner.node_to_interact.dialog:
#				DialogEvent.emit_signal('dialog_requested', owner.node_to_interact.dialog)
	elif event.is_action_pressed('Equip') and not owner.grabbing:
		if owner.has_equiped():
			owner.current_tool = owner.Tools.NONE
			AudioEvent.emit_signal('play_requested', 'Player', 'Unequip', owner.global_position)
		else:
			owner.current_tool = owner.Tools.ROD
		# TODO: Aquí se equipará el objeto seleccionado en el inventario. Por
		#		ahora será la caña porque no tenemos más.


func _physics_process(delta) -> void:
	if not can_move or owner.is_paused:
		return

	dir.x = Utils.is_pressed('Right', true) - Utils.is_pressed('Left', true)
	dir.y = Utils.is_pressed('Down', true) - Utils.is_pressed('Up', true)
	
	owner.dir = dir
	
	if dir.x != 0:
		_last_dir.x = dir.x
		_last_dir.y = 0

		owner.sprite.flip_h = dir.x < 0
		owner.shadow.flip_h = owner.sprite.flip_h
		owner.behind.flip_h = owner.sprite.flip_h

	elif dir.y != 0:
		_last_dir.x = 0
		_last_dir.y = dir.y
	
	if not owner.is_out:
		owner.move_and_collide(dir * _calc_speed * delta)
	else:
		owner.move_and_collide(dir * _calc_speed * 2 * delta)
		
	if dir != Vector2(0,0) and not owner.is_moving:
		_state_machine.transition_to_state(_state_machine.STATES.WALK)
	elif dir == Vector2(0,0) and owner.is_moving:
		_state_machine.transition_to_state(_state_machine.STATES.IDLE)

	if owner.grabbing and owner.node_to_interact:
		owner.node_to_interact.global_position = owner.global_position
		owner.node_to_interact.position.y -= 7


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func toggle_movement():
	can_move = !can_move


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)


func exit() -> void:
	.exit()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_dialog_event(playing, countdown, duration):
	if playing:
		yield(get_tree().create_timer(countdown), 'timeout')
		_state_machine.transition_to_state(_state_machine.STATES.IDLE)
		toggle_movement()
		yield(get_tree().create_timer(duration), 'timeout')
		toggle_movement()
