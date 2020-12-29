extends Node2D

onready var _animation: AnimationPlayer = $AnimationPlayer

func emerge():
	yield(get_tree().create_timer(20), 'timeout')
	_animation.play('Emerge')
