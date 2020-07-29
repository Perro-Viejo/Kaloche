tool
class_name Switchable
extends Area2D

export(String) var switch_id=''
export(int) var delay=0

# ░░░░ Funciones ░░░░
func _ready() -> void:
	Event.connect("switch_on", self, "_on_switch_on")
	Event.connect("switch_off", self, "_on_switch_off")
	$ON.visible = false
	$OFF.visible = true
	
func _on_switch_on(id: String):
	if id == switch_id:
		yield(get_tree().create_timer(delay), "timeout")
		
		$ON.visible = true
		$OFF.visible = false
	
func _on_switch_off(id: String):
	if id == switch_id:
		yield(get_tree().create_timer(delay), "timeout")
		
		$ON.visible = false
		$OFF.visible = true
