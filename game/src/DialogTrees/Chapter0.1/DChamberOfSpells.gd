extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _rocberto_block() -> void:
	yield(DialogEvent.run([
		WorldEvent.player.focus_camera_to(WorldEvent.get_character('Rocberto')),
		'Rocberto(Sad): CHAMSPLS_Rocberto_0' + str(randi() % 3 + 1),
		WorldEvent.player.reset_camera(),
	]), 'completed')
