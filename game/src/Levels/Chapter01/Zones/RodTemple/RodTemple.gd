extends Node2D

onready var _animation: AnimationPlayer = $AnimationPlayer

func emerge():
	_animation.play('Emerge')
