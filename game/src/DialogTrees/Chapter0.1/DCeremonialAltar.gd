tool
extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _arrive() -> void:
	yield(DialogEvent.run([
		'Player(Surprised): CEREALTR_Teotriste_01',
		'Player(Curious): CEREALTR_Teotriste_02',
	]), 'completed')

func _arrive_rocberto() -> void:
	yield(DialogEvent.run([
		'Rocberto(Sad): CEREALTR_Rocberto_01',
		'Rocberto(Sad): CEREALTR_Rocberto_02',
	]), 'completed')

func _rocberto_fall() -> void:
	yield(DialogEvent.run([
		WorldEvent.player._zoom_camera(Vector2(0.8, 0.8)),
		WorldEvent.player.focus_camera_to(WorldEvent.get_character('Rocberto')),
		'Rocberto(Sad): CEREALTR_Rocberto_03',
		'Rocberto(Sad): CEREALTR_Rocberto_04',
		WorldEvent.player.reset_camera(),
	]), 'completed')

func _false_feed() -> void:
	yield(DialogEvent.run([
		'Player(Surprised): CEREALTR_Teotriste_03',
	]), 'completed')

func _activate_temple() -> void:
	yield(DialogEvent.run([
		WorldEvent.player.focus_camera_to(WorldEvent.get_character('Rocberto')),
		'Rocberto(Sad): CEREALTR_Rocberto_05',
		WorldEvent.player.reset_camera(),
		'Player(Surprised): CEREALTR_Teotriste_04',
		WorldEvent.player.focus_camera_to(WorldEvent.get_character('Rocberto')),
		'Rocberto(Sad): CEREALTR_Rocberto_06',
		WorldEvent.player.reset_camera(),
	]), 'completed')
