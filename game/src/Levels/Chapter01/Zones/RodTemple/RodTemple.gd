extends Node2D

onready var _animation: AnimationPlayer = $AnimationPlayer


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	($Main/ZIndexChanger as ZIndexChanger).connect(
		'z_index_changed',
		self,
		'_change_temple_mask_range'
	)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func emerge():
	_animation.play('Emerge')
	yield(get_tree().create_timer(_animation.get_animation('Emerge').length - 0.2), 'timeout')
	AudioEvent.emit_signal('play_requested', 'Spot', 'RodTemple', global_position)
	if $DialogTrigger:
		$DialogTrigger.queue_free()


func get_emerge_animation_length() -> float:
	return _animation.get_animation('Emerge').length


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _change_temple_mask_range(new_z_index: int) -> void:
	$MainClosedMask.range_z_min = new_z_index
	$MainClosedMask.range_z_max = new_z_index

