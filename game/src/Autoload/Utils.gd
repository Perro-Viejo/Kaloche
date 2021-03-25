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


# Mejora la lectura de entradas del control. Gracias a:
# https://github.com/godotengine/godot/pull/30890#issuecomment-542823398
static func is_pressed(action, as_float := false):
	var is_pressed = false

	for event in InputMap.get_action_list(action):
		if event is InputEventKey:
			is_pressed = Input.is_key_pressed(event.scancode)
		elif event is InputEventJoypadButton:
			is_pressed = Input.is_joy_button_pressed(event.device, event.button_index)
		elif event is InputEventMouseButton:
			is_pressed = Input.is_mouse_button_pressed(event.button_index)
		elif event is InputEventJoypadMotion:
			is_pressed = Input.get_action_strength(action)
				#add more elif to treat the type accordingly
		else:
			continue
		
		if is_pressed:
			break

	if as_float:
		return ceil(float(is_pressed))
	return is_pressed
