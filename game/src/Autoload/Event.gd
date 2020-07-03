extends Node

signal ChangeScene
signal MainMenu
signal NewGame
signal Continue
signal Resume
signal Restart
signal Options
signal Controls
signal Languages
signal Paused
signal Exit
signal Refocus

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Perro Viejo ░░░░

# Para el diálogo y todo lo que tenga que ver con diálogos para dialogar
signal character_spoke(character, message, time_to_disappear)
signal dialog_event(playing, countdown, duration)
signal dialog_requested(dialog_name)
signal dialog_continued
signal dialog_skipped
signal dialog_finished
signal dialog_paused
signal line_triggered(character_name, text, time)
signal dialog_menu_requested(options)
signal dialog_option_clicked(option_dic)
signal dialog_menu_updated(cfg)

signal pickable_requested

signal zone_entered(name)
signal music_requested(stream) # Sólo mientras tanto
signal music_stoped() # Sólo mientras tanto
signal intro_shown(msg)
signal hud_accept_pressed
signal world_entered
signal continue_requested

signal play_requested(source, sound, position)
signal stop_requested(source, sound)
signal pause_requested(source, sound)
signal stream_finished(source, sound)
signal change_volume(source, sound, volume)

# Para todo lo que tenga que ver con el personaje jugable
signal control_toggled
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

#For section tracking
var MainMenu:bool = false setget set_main_menu
var Options:bool = false setget set_options
var Controls:bool = false setget set_controls
var Languages:bool = false setget set_languages
var Paused: bool = false setget set_paused

func set_main_menu(value:bool)->void:
	MainMenu = value
	emit_signal("MainMenu", MainMenu)

func set_options(value:bool)->void:
	Options = value
	emit_signal("Options", Options)

func set_controls(value:bool)->void:
	Controls = value
	emit_signal("Controls", Controls)

func set_languages(value:bool)->void:
	Languages = value
	emit_signal("Languages", Languages)

func set_paused(value:bool)->void:
	Paused = value
	emit_signal("Paused", Paused)
