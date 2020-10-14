class_name Hook
extends Node2D

signal dropped

var target_pos: Vector2 setget _set_target_pos

onready var origin_pos = position
onready var tween := $Tween

func _set_target_pos(end_pos: Vector2) -> void:
	target_pos = position + end_pos

func pull_done() -> void:
	pass
