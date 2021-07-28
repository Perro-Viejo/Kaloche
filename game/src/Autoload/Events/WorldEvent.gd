extends Node

signal zone_entered(name)
signal world_entered(data)
signal rod_selected(rod)
signal pickable_burnt(pickable)
signal zone_position_requested(position)

var player_blocked := false
var characters := []
var player: Actor


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func add_character(chr: Node) -> void:
	# TODO: Verificar si ya existe el nodo a agregar para no agregarlo dos veces
	# 		o actualizar la referencia guardada.
	characters.append(chr)


func get_character(chr_name: String) -> Node2D:
	for c in characters:
		if c.name.to_lower() == chr_name.to_lower():
			return c
	
	prints('No se encontró el personaje:', chr_name)
	return null
