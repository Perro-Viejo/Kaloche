extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func _awake() -> void:
	yield(DialogEvent.run([
		'Player(Curious): SI_Teotriste_01',
		'Player(Sad): SI_Teotriste_02',
	]), 'completed')


func _bridge_broke() -> void:
	yield(DialogEvent.run([
		'Player(Surprised): SI_Teotriste_03',
	]), 'completed')

func _find_ruins() -> void:
	yield(DialogEvent.run([
		'Player(Curious): SI_Teotriste_04',
	]), 'completed')

func _grab_debris() -> void:
	yield(DialogEvent.run([
		'Player(Surprised): SI_Teotriste_05',
		'Player(Sad): SI_Teotriste_06',
	]), 'completed')
