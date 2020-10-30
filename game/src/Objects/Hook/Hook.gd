class_name Hook
extends Node2D

signal dropped
signal sent_back
signal hooked
signal tried

var target_pos: Vector2 setget _set_target_pos
var target_set := false

onready var origin_pos = position
onready var tween := $Tween
onready var area: Area2D = $Area2D
onready var dflt_pos := position

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	area.monitoring = false
	area.monitorable = false

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func pull_done(rod_strength: float) -> Dictionary:
	if $StateMachine.state.has_method('pull_done') :
		return $StateMachine.state.pull_done(rod_strength)
	return {}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _set_target_pos(end_pos: Vector2) -> void:
	dflt_pos = position
	target_pos = position + end_pos
	target_set = true
