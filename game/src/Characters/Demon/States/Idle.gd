extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	.enter()

func exit() -> void:
	pass

func _process(delta):
	pass
#	_parent.get_node("FeedArea/CollisionShape2D/Feed").scale = scale
#	$Idle.set_pitch_scale(range_lerp(health, 0, max_health, 3, 1))
#	$InteractionArea/Area.shape.radius = lerp(1, 20, sprite.scale.y)
