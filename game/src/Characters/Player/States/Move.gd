extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var speed = 2

var dir:Vector2 = Vector2.ZERO
var can_move = true

var _last_dir: Vector2 = Vector2.ZERO

onready var _calc_speed: float = speed * 60
onready var _owner: Player = owner
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	Event.connect('dialog_event', self, '_on_dialog_event')


func _unhandled_input(event: InputEvent) -> void:
	if _owner.is_paused: return

	if event.is_action_pressed('Grab'):
		if _owner.fishing:
			_owner.fishing_spot.pull_fish()
		if _owner.node_to_interact and not _owner.grabbing:
			_state_machine.transition_to(_owner.STATES.GRAB)
	elif event.is_action_pressed('Drop'):
		if _owner.node_to_interact:
			if _owner.grabbing:
				_state_machine.transition_to(_owner.STATES.DROP, { dir = _last_dir })
			elif _owner.node_to_interact.dialog:
				Event.emit_signal('dialog_requested', _owner.node_to_interact.dialog)
		else:
			if _owner.fishing:
				_owner.fishing_spot.switch_bait()

	if event.is_action_pressed('Fish'):
		if _owner.fishing:
			_state_machine.transition_to(_owner.STATES.IDLE)
		else:
			if not _owner.grabbing and not _owner.is_moving:
				_state_machine.transition_to(owner.STATES.FISH)


func _physics_process(delta) -> void:
	if not can_move or _owner.is_paused:
		return

	dir.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	dir.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")

	if dir.x != 0:
		_last_dir.x = dir.x
		_last_dir.y = 0

		_owner.sprite.flip_h = dir.x < 0
#		

	elif dir.y != 0:
		_last_dir.x = 0
		_last_dir.y = dir.y
		

	if not _owner.is_out:
		_owner.move_and_collide(dir * _calc_speed * delta)
	else:
		_owner.move_and_collide(dir * _calc_speed * 2 * delta)

	if not dir == Vector2(0,0) and not _owner.is_moving:
		_state_machine.transition_to(owner.STATES.WALK)
	elif dir == Vector2(0,0) and _owner.is_moving:
		_state_machine.transition_to(owner.STATES.IDLE)

	if _owner.grabbing and _owner.node_to_interact:
		_owner.node_to_interact.global_position = _owner.global_position
		_owner.node_to_interact.position.y -= 7

func _on_dialog_event(playing, countdown, duration):
	if playing:
		yield(get_tree().create_timer(countdown), 'timeout')
		_state_machine.transition_to(_owner.STATES.IDLE)
		toggle_movement()
		yield(get_tree().create_timer(duration), 'timeout')
		toggle_movement()

func toggle_movement():
	can_move = !can_move

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func exit() -> void:
	.exit()
