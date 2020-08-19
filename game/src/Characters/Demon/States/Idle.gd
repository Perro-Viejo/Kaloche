extends "res://src/StateMachine/State.gd"

func enter(msg: Dictionary = {}) -> void:
	.enter()

func _process(delta):
	_parent.get_node("FeedArea/CollisionShape2D/Feed").scale = sprite.scale
#	$Idle.set_pitch_scale(range_lerp(health, 0, max_health, 3, 1))
#	$InteractionArea/Area.shape.radius = lerp(1, 20, sprite.scale.y)
