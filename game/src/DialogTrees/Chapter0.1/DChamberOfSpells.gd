extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _rocberto_block() -> void:
	yield(DialogEvent.run([
		'Rocberto(Sad): CHAMSPLS_Rocberto_0' + str(randi() % 3 + 1),
	]), 'completed')
