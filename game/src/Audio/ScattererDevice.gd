extends Node2D

export (Vector2) var freq_range = Vector2.ONE
export (String, "Bird", "Parrot", "Insect") var animalo = "Parrot"
var frequency

var listener
var target_pos
var _timer
var offset = Vector2.ZERO


func _ready():
	frequency = rand_range(freq_range.x, freq_range.y)
	_timer = $Timer
	#Este timer podría ir a mitad de segundo y convertirse en un tick
	_timer.wait_time = frequency
	#Esto conectaría con una funcíón que cuente cada tick y dependiendo cada objeto vea si lo debería tocar
	_timer.connect('timeout', self, 'play_sfx')
	$Area2D.connect('area_entered', self, '_on_area_entered')
	$Area2D.connect('area_exited', self, '_on_area_exited')

func _process(delta):
	if listener:
		target_pos = listener.get_global_position()

func _on_area_entered(other):
	if other.get_name() == 'PlayerArea':
		listener = other
		_timer.start()
func _on_area_exited(other):
	_timer.stop()

func play_sfx():
	randomize()
	offset = Vector2(rand_range(-150, 150), rand_range(-150, 150))
	#Esta frecuencia debería ser individual por objeto/animal
	frequency = rand_range(freq_range.x, freq_range.y)
	print("me toke")
	AudioEvent.emit_signal("play_requested", "Animals", animalo, target_pos + offset)
