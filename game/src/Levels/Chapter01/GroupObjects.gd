extends Node2D

func _ready():
	$TempleDoorButton.connect('button_pressed', $TempleDoor, 'open')
	$Altar.connect('activate_door', $TempleDoorButton, 'show')
