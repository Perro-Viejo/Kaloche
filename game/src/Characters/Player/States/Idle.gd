extends "res://src/StateMachine/State.gd"

onready var _owner: Player = owner as Player

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)

	_owner.play_animation()

func exit() -> void:
	.exit()
