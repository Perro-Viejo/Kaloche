extends "res://src/StateMachine/State.gd"
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(float) var speed = 2

var dir:Vector2 = Vector2.ZERO

var _last_dir: Vector2 = Vector2.ZERO

var can_move = true

onready var _calc_speed: float = speed * 60
onready var _owner: Player = owner as Player
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░

func _ready():
	Event.connect('dialog_event', self, '_on_dialog_event')

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('Grab'):
		if _owner.can_grab and not _owner.grabbing:
			_state_machine.transition_to(_owner.STATES.GRAB)
	elif event.is_action_pressed('Drop') and _owner.can_grab and _owner.grabbing:
		_state_machine.transition_to(_owner.STATES.DROP, { dir = _last_dir })

func _physics_process(delta) -> void:
	if not can_move:
		return
	dir.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	dir.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")

	if dir.x != 0:
		_last_dir.x = dir.x
		_last_dir.y = 0

		_owner.sprite.flip_h = dir.x < 0
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

	if _owner.grabbing and _owner.can_grab:
		_owner.can_grab.global_position = _owner.global_position
		_owner.can_grab.position.y -= 7

func _on_dialog_event(playing, countdown, duration):
	if playing:
		yield(get_tree().create_timer(countdown), 'timeout')
		_state_machine.transition_to(_owner.STATES.IDLE)
		can_move = false
		yield(get_tree().create_timer(duration), 'timeout')
		can_move = true

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

func exit() -> void:
	.exit()
