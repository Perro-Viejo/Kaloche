extends "res://src/DialogTrees/DialogTree.gd"

var options := [
	{
		id = '',
		text = '',
		visible = true
	}
]


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _say_hello() -> void:
	yield(DialogEvent.run([
		'Player: Hola mis perritos!',
		'Rocberto: Hola Teotristex'
	]), 'completed')


func _say_adios() -> void:
	yield(DialogEvent.run([
		'Player(Angry): DLG_1_7_PLAYER',
		'Rocberto(Happy): Nunca me quisistes',
		'Player(Sad): Muérete'
	]), 'completed')
