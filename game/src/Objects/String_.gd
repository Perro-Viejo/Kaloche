extends Node2D


export (float) var length = 30
export (float) var constrain = 1
export (Vector2) var gravity = Vector2(0,9.8)
export (float) var friction = 0.9
export (bool) var start_pin = true
export (bool) var end_pin = true

var hook_ref: Hook = null
var pos: PoolVector2Array
var pos_ex: PoolVector2Array
var count: int

func _ready():
	hook_ref = get_parent()
	count = get_count(length)
	resize_arrays()
	init_position()

func get_count(distance: float):
	var new_count = ceil(distance / constrain)
	return new_count

func resize_arrays():
	pos.resize(count)
	pos_ex.resize(count)

func init_position():
	for i in range(count):
		pos[i] = position + Vector2(constrain *i, 0)
		pos_ex[i] = position + Vector2(constrain *i, 0)
	position = Vector2.ZERO

func _process(delta):
	pos[0] = hook_ref.rod_tip.position - hook_ref.position
	pos_ex[0] = hook_ref.rod_tip.position - hook_ref.position
	pos[count-1] = Vector2.ZERO
	pos_ex[count-1] = Vector2.ZERO
	update_points(delta)
	update_distance()
	#update_distance()	#Repeat to get tighter rope
	#update_distance()
	$Line2D.points = pos

func update_points(delta):
	for i in range (count):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=count-1) || (i==0 && !start_pin) || (i==count-1 && !end_pin):
			var vec2 = (pos[i] - pos_ex[i]) * friction
			pos_ex[i] = pos[i]
			pos[i] += vec2 + (gravity * delta)

func update_distance():
	for i in range(count):
		if i == count-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		if i == 0:
			if start_pin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		elif i == count-1:
			pass
		else:
			if i+1 == count-1 && end_pin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
