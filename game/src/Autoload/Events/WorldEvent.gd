extends Node

signal zone_entered(name)
signal world_entered(data)
signal rod_selected(rod)
signal pickable_burnt(pickable)
signal zone_position_requested(position)

var player_blocked := false
