extends Node2D

onready var _animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	($Temple/ZIndexChanger as ZIndexChanger).connect(
		'z_index_changed',
		self,
		'_change_temple_mask_range'
	)


func emerge():
	_animation.play('Emerge')


func _change_temple_mask_range(new_z_index: int) -> void:
	$Temple/Mask.range_z_min = new_z_index
	$Temple/Mask.range_z_max = new_z_index
