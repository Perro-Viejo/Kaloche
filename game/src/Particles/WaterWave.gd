extends Node2D

onready var _anim = $AnimationPlayer

func ready():
	_anim.connect('animation_finished', self, '_on_animation_finished')

func play_animation(anim, speed) -> void:
	_anim.play(anim, speed)
	yield(get_tree().create_timer(_anim.get_current_animation_length()), 'timeout')
	queue_free()

