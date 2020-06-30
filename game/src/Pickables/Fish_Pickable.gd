extends "res://src/Pickables/Pickable.gd"

var spawn = false
var countdown = 6
onready var _tween: Tween = get_node("Tween")

func jump(origin):
	_tween.interpolate_property(self, "position",
		position, position + (origin*-1)*rand_range(2, 4) , .1,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	_tween.start()



