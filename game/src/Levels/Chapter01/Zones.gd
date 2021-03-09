extends Node2D


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
#	$TempleDoorButton.connect('button_pressed', $TempleDoor, 'open')
	$Altar.connect('activate_door', self, '_on_activate_door')
	$FishTank.connect('tank_activated', self, '_on_tank_activated')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_activate_door() -> void:
	$AltarActivation.activate_temple()


func _on_tank_activated() -> void:
	$FishTankAnimation.reveal_rod($RodTemple)
