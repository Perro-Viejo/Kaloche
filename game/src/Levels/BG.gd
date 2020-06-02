extends Node2D

export (float) var max_distance
export (bool) var active = true

var listener
var area_center
var distance_to_center
var last_position
var dir:Vector2 = Vector2.ZERO

func _ready():
	area_center = $Center.get_global_position()
	$Area2D.connect('area_entered', self, '_on_area_entered')
	
func _process(delta):
	if listener:
		distance_to_center = listener.get_global_position().distance_to(area_center)
		if distance_to_center <= 360 and distance_to_center >= 280:
			if $BG.get_volume_db() <= 0:
				$BG.set_volume_db(280 - distance_to_center)
		elif distance_to_center <= 280:
			$BG.set_volume_db(0)
func _on_area_entered(other):
	if active:
		if other.get_name() == 'PlayerArea':
			listener = other
			if not $BG.is_playing():
				$BG.play()



