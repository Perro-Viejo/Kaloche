# Controla el comportamiento de las sombras de los peces en las superficies
# en las que se puede pescar
extends Node2D

var size := 'sm'

func _enter_tree():
	$AnimationPlayer.play('swim_%s' % size)

# Hace que el pez se mueva en línea recta de un punto a otro para que parezca que
# está nadando
func swim() -> void:
	pass
