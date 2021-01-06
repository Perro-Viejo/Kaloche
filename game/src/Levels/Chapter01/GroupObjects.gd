extends Node2D

func _ready():
	$TempleDoorButton.connect('button_pressed', $TempleDoor, 'open')
	$Altar.connect('activate_door', self, '_on_activate_door')

func _on_activate_door() -> void:
	#Falta hacer algo para que no se pueda detectar la colisión cuando es invisible
	$AltarActivation.show_door($TempleDoorButton)
