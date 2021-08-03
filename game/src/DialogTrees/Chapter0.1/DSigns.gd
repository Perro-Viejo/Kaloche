tool
extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _teotriste_reaction() -> void:
	yield(DialogEvent.run([
		'Player(Curious): SIGNS_Teotriste_0' + str(randi() % 5 + 1),
	]), 'completed')

func _read_sign() -> void:
	yield(DialogEvent.run([
		'Rocberto: SIGNS_Rocberto_0' + str(Data.read_sign_id),
	]), 'completed')
