extends Node2D

export (String) var source = ""
export (String) var emitter = ""
export (Vector2) var freq_range = Vector2.ZERO
export (float) var weight = 1 

var frequency = 0
var tick_count = 0

func _ready():
	if not source:
		print("Porfavori define 'emitter_type' so I can know que decirle al Manager")
	if emitter == "":
		emitter = get_name()
	frequency = rand_range(freq_range.x, freq_range.y)
#Aguanta meter el parametro de MaxDistance pero necesita señal en el AudioEvent

func count_tick(target_pos):
	tick_count += 1
	if tick_count >= frequency:
		play_sfx(target_pos)
		tick_count = 0
	

func play_sfx(target_pos):
	print(emitter)
	randomize()
	var offset = Vector2(rand_range(-150, 150), rand_range(-150, 150))
	frequency = rand_range(freq_range.x, freq_range.y)
	AudioEvent.emit_signal("play_requested", source, emitter, target_pos + offset)

