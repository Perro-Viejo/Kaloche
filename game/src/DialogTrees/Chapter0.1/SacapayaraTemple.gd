extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _step_floor() -> void:
	yield(DialogEvent.run([
		'Player(Curious): RT_Teotriste_01',
		'Player(Sad): RT_Teotriste_02',
	]), 'completed')


func _rod_grabbed() -> void:
	yield(DialogEvent.run([
		'Rocberto(Surprised): RT_Rocberto_01',
	]), 'completed')
