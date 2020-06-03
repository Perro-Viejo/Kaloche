extends Node2D

export (float) var max_distance
export (float) var min_distance
export (float) var max_volume = 0
export (bool) var active = true

var listener
var area_center
var distance_to_center
var last_position
var dir:Vector2 = Vector2.ZERO

func _ready():
	area_center = $Center.get_global_position()
	$Area2D.connect('area_entered', self, '_on_area_entered')
	$Area2D.connect('area_exited', self, '_on_area_exited')
	
func _process(delta):
	if listener:
		distance_to_center = listener.get_global_position().distance_to(area_center)
		if distance_to_center <= max_distance and distance_to_center >= min_distance:
			if $BG.get_volume_db() <= 0:
				$BG.set_volume_db(range_lerp((max_distance - distance_to_center), 0, (max_distance - min_distance), -80, max_volume))
		elif distance_to_center <= min_distance:
			$BG.set_volume_db(0)
func _on_area_entered(other):
	if active:
		if other.get_name() == 'PlayerArea':
			listener = other
			if not $BG.is_playing():
				$BG.play()

func _on_area_exited(other):
	if active:
		if other.get_name() == 'PlayerArea':
			listener = null
			if $BG.is_playing():
				$BG.set_volume_db(-80)
				$BG.stop()


