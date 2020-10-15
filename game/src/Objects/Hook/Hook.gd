class_name Hook
extends Node2D

signal dropped

var target_pos: Vector2 setget _set_target_pos
var target_set := false

onready var origin_pos = position
onready var tween := $Tween

func _set_target_pos(end_pos: Vector2) -> void:
	target_pos = position + end_pos
	target_set = true

func pull_done(rod_strength: float) -> Dictionary:
	if $StateMachine.state == $StateMachine.STATES.HOOKED:
		return $StateMachine.state.pull_done(rod_strength)
	return {}
