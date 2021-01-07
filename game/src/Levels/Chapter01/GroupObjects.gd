extends Node2D

func _ready():
	$TempleDoorButton.connect('button_pressed', $TempleDoor, 'open')
	$Altar.connect('activate_door', self, '_on_activate_door')
	$FishTank.connect('tank_activated', self, '_on_tank_activated')

func _on_activate_door() -> void:
	$AltarActivation.show_door($TempleDoorButton)

func _on_tank_activated() -> void:
	$FishTankAnimation.reveal_rod($RodTemple)
