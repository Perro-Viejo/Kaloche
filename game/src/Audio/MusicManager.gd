extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	AudioEvent.connect('mx_request', self, 'play_mx')
	AudioEvent.connect('mx_stop', self, 'stop_mx')


func play_mx(music):
	var sound_path := '%s' % [music]
