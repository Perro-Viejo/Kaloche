extends Node2D

onready var _animation: AnimationPlayer = $AnimationPlayer


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready() -> void:
	($Main/ZIndexChanger as ZIndexChanger).connect(
		'z_index_changed',
		self,
		'_change_temple_mask_range'
	)
	_animation.connect('animation_finished', self, '_on_animation_finished')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func emerge():
	_animation.play('Emerge')


func get_emerge_animation_length() -> float:
	return _animation.get_animation('Emerge').length


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _change_temple_mask_range(new_z_index: int) -> void:
	$MainClosedMask.range_z_min = new_z_index
	$MainClosedMask.range_z_max = new_z_index

func _on_animation_finished(anim) -> void:
	if anim == 'Emerge':
		AudioEvent.emit_signal('play_requested', 'Spot', 'RodTemple', global_position)
