# Script en el que se pueden guardar funciones de uso transversarl entre todos
# los nodos y scripts del proyecto
extends Node

func get_screen_coords_for(node: Node) -> Vector2:
	return node.get_viewport().canvas_transform * node.get_global_position()

func get_random_array_element(arr: Array):
	randomize()
	return arr[randi() % arr.size()]

func get_random_array_idx(arr: Array) -> int:
	randomize()
	return randi() % arr.size()
