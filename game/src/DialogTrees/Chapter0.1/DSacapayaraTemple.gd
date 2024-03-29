extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _step_floor() -> void:
	yield(DialogEvent.run([
		'Player(Curious): SACATMPL_Teotriste_01',
		'Player(Sad): SACATMPL_Teotriste_02',
	]), 'completed')


func _rod_grabbed() -> void:
	yield(DialogEvent.run([
		WorldEvent.player.focus_camera_to(WorldEvent.get_character('Rocberto')),
		'Rocberto(Surprised): SACATMPL_Rocberto_01',
		WorldEvent.player.reset_camera()
	]), 'completed')
