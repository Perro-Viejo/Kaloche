tool
extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░

func _arrive() -> void:
	yield(DialogEvent.run([
		'Player(Curious): PAYAPOND_Teotriste_01',
	]), 'completed')

func _rocberto_arrive() -> void:
	yield(DialogEvent.run([
		'Rocberto(Happy): PAYAPOND_Rocberto_01',
		'Rocberto(Sad): PAYAPOND_Rocberto_02',
		'Rocberto: PAYAPOND_Rocberto_03',
	]), 'completed')

func _tank_filled() -> void:
	yield(DialogEvent.run([
		'Rocberto(Happy): PAYAPOND_Rocberto_04',
	]), 'completed')

func _activation_finished() -> void:
	yield(DialogEvent.run([
		'Player(Surprised): PAYAPOND_Teotriste_02',
		'Rocberto: PAYAPOND_Rocberto_05',
	]), 'completed')

func _fishing_tutorial() -> void:
	yield(DialogEvent.run([
		'Rocberto: PAYAPOND_Rocberto_06',
		'Rocberto: PAYAPOND_Rocberto_07',
		'Rocberto: PAYAPOND_Rocberto_08',
		'Rocberto: PAYAPOND_Rocberto_09',
		'Rocberto: PAYAPOND_Rocberto_10',
		'Rocberto: PAYAPOND_Rocberto_11',
		'Rocberto: PAYAPOND_Rocberto_12',
	]), 'completed')

func _capture_first_fish() -> void:
	yield(DialogEvent.run([
		'Rocberto(Happy): PAYAPOND_Rocberto_13',
		'Rocberto(Happy): PAYAPOND_Rocberto_14',
		#TODO: aqui iria la condicion si uno ya encontro el altar con 04
		'Player(Happy): PAYAPOND_Teotriste_03',
	]), 'completed')
