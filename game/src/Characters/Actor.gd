class_name Actor
extends Node2D

signal died()

export(Color) var dialog_color
export(int) var health = 0
export(bool) var immortal = false
export(Resource) var inventory
export(int) var max_health = 0
export var is_player := false

var movement_speed_multiplier := Vector2.ONE

var _in_dialog := false

onready var state_machine = $StateMachine


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	WorldEvent.add_character(self)
	
	if is_player:
		WorldEvent.player = self


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func speak(text: String, time = 0.0, emotion = '') -> void:
	DialogEvent.emit_signal('character_spoke', self, text, time)
	if not text == '':
		AudioEvent.emit_signal('dx_requested' , name, emotion)


func spoke():
	if _in_dialog:
		DialogEvent.emit_signal('dialog_continued')
