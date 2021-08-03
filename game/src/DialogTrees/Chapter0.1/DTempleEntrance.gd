tool
extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _arrive() -> void:
	yield(DialogEvent.run([
		'Player(Surprised): TMPLENTR_Teotriste_01',
		'Player(Curious): TMPLENTR_Teotriste_02',
	]), 'completed')

func _arrive_rocberto() -> void:
	yield(DialogEvent.run([
		'Rocberto: TMPLENTR_Rocberto_01',
		'Player(Surprised): TMPLENTR_Teotriste_03',
		'Rocberto: TMPLENTR_Rocberto_02',
		'Rocberto(Sad): TMPLENTR_Rocberto_03',
	]), 'completed')

func _door_open() -> void:
	yield(DialogEvent.run([
		'Rocberto: TMPLENTR_Rocberto_04',
		'Player(Curious): TMPLENTR_Teotriste_04',
		'Rocberto: TMPLENTR_Rocberto_05',
		'Player(Curious): TMPLENTR_Teotriste_05',
		'Rocberto(Sad): TMPLENTR_Rocberto_06',
		'Rocberto: TMPLENTR_Rocberto_07',
		'Rocberto(Happy): TMPLENTR_Rocberto_08',
	]), 'completed')
