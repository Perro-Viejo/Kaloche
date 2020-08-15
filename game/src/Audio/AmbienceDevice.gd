extends Node2D

enum AMBS {SIERRA}

export (AMBS) var ambience

var listener
var current_amb
var active = false

func _ready():
	current_amb = ambience
	#Esto determina la maxima distancia en la que se va a activar el sonido
	$MaxDistance.connect('area_entered', self, '_on_area_entered')
	$MaxDistance.connect('area_exited', self, '_on_area_exited')

	#Esto determina el área donde el sonido estara centrado y con máximo volumen
	$AmbZone.connect('area_entered', self, 'position_bg', [true])
	$AmbZone.connect('area_exited', self, 'position_bg', [false])
	
	#TODO Determinar distancia de el falloff zone con respecto al AmbZone

func _on_area_entered(other):	
	if other.get_name() == 'PlayerArea':
		listener = other
		if not active:
			active = true
			Event.emit_signal("play_requested", "BG", AMBS.keys()[current_amb].capitalize())

func _on_area_exited(other):
	if other.get_name() == 'PlayerArea':
		listener = null
		if active:
			active = false
			Event.emit_signal("stop_requested", "BG", AMBS.keys()[current_amb].capitalize())

func position_bg(other, inside):
	if other.get_name() == 'PlayerArea':
		if inside:
			Event.emit_signal("position_amb", "BG", AMBS.keys()[current_amb].capitalize(), $AmbZone.global_position) 
		else:
			Event.emit_signal("position_amb", "BG", AMBS.keys()[current_amb].capitalize(), other.global_position)
			


