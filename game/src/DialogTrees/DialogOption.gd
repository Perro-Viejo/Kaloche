tool
class_name DialogOption
extends Resource

export var id := '' setget _set_id
export var text := ''
export var visible := true
export var group := '' setget _set_group

var description := '' # Aquí irá el código de localización
var disabled := false
var used := false
var script_name := ''


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func turn_on() -> void:
	pass


func turn_off() -> void:
	pass


func turn_off_forever() -> void:
	pass


func hide_forever() -> void:
	pass


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_interacted() -> void:
	pass


func _on_interaction_canceled() -> void:
	pass


func _set_id(value: String) -> void:
	id = value
	script_name = id

	if group:
		resource_name = '%s(%s)' % [id, group]
	else:
		resource_name = id
	
	property_list_changed_notify()


func _set_group(value: String) -> void:
	group = value
	
	if value:
		resource_name = '%s(%s)' % [id, value]

	property_list_changed_notify()
