extends Node2D

signal dropped

var target_pos: Vector2 setget _set_target_pos

onready var origin_pos = position
onready var tween := $Tween

func _set_target_pos(pos: Vector2) -> void:
	target_pos = Vector2(pos.x, origin_pos.y)

func pull_done() -> void:
	pass
