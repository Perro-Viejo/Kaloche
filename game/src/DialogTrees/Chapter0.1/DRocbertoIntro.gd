tool
extends "res://src/DialogTrees/DialogTree.gd"

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Diálogos ░░░░
func start_conversation() -> void:
	yield(
		DialogEvent.run(['Rocberto(Happy): ' + tr('ROCBINTR_Rocberto_01')]),
		'completed'
	)
	
	.start()


func option_selected(opt: DialogOption) -> void:
	var group_to_show := ''
	yield(DialogEvent.run(['Player: ' + opt.text]), 'completed')

	match opt.id:
		'Opt1':
			yield(DialogEvent.run([
				'Player(Curious): ROCBINTR_Teotriste_Op1_01',
				'Rocberto: ROCBINTR_Rocberto_Op1_02',
			]), 'completed')
			group_to_show = 'A'
		'Opt2':
			yield(DialogEvent.run([
				'Player(Sad): ROCBINTR_Teotriste_Op2_01',
				'Rocberto(Happy): ROCBINTR_Rocberto_Op2_02',
			]), 'completed')
			group_to_show = 'B'
		'Opt3':
			yield(DialogEvent.run([
				'Player(Angry): ROCBINTR_Teotriste_Op3_01',
				'Rocberto(Sad): ROCBINTR_Rocberto_Op3_02',
				'Player(Angry): ROCBINTR_Teotriste_Op3_03',
			]), 'completed')
			group_to_show = 'C'
		'Opt1A':
			yield(DialogEvent.run([
				'Rocberto(Sad): ROCBINTR_Rocberto_Op1A_01',
			]), 'completed')
			group_to_show = 'D'
		'Opt1B':
			yield(DialogEvent.run([
				'Player(Angry): ROCBINTR_Teotriste_Op1B_01',
				'Rocberto(Sad): ROCBINTR_Rocberto_Op1B_02',
			]), 'completed')
			group_to_show = 'D'
		'Opt2A':
			yield(DialogEvent.run([
				'Player(Angry): ROCBINTR_Teotriste_Op2A_01',
				'Rocberto(Sad): ROCBINTR_Rocberto_Op2A_02',
			]), 'completed')
			group_to_show = 'D'
		'Opt2B':
			yield(DialogEvent.run([
				'Player: ROCBINTR_Teotriste_Op2B_01',
				'Rocberto: ROCBINTR_Rocberto_Op2B_01',
			]), 'completed')
			group_to_show = 'D'
		'Opt3A':
			yield(DialogEvent.run([
				'Player(Curoius): ROCBINTR_Rocberto_Op3A_01',
				'Rocberto(Happy): ROCBINTR_Rocberto_Op3A_02',
			]), 'completed')
			group_to_show = 'D'
		'Opt3B':
			yield(DialogEvent.run([
				'Rocberto: ROCBINTR_Rocberto_Op3B_01',
			]), 'completed')
			group_to_show = 'D'
		'Opt4':
			yield(DialogEvent.run([
				'Player: ROCBINTR_Teotriste_Op4_01',
				'Rocberto: ROCBINTR_Rocberto_Op4_02',
				'Player: ROCBINTR_Teotriste_Op4_03',
				'Rocberto: ROCBINTR_Rocberto_Op4_04',
			]), 'completed')
		'Opt5':
			yield(DialogEvent.run([
				'Player: ROCBINTR_Teotriste_Op5_01',
				'Rocberto: ROCBINTR_Rocberto_Op5_02',
			]), 'completed')
		'Opt6':
			yield(DialogEvent.run([
				'Player: ROCBINTR_Teotriste_Op6_01',
				'Rocberto: ROCBINTR_Rocberto_Op6_02',
			]), 'completed')

	if group_to_show:
		show_group(group_to_show)
	else:
		emit_signal('conversation_finished')
