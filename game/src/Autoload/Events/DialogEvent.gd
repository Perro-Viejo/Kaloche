extends Node

signal character_spoke(character, message, time_to_disappear, emotion)
signal dialog_event(playing, countdown, duration)
#signal dialog_requested(dialog_name, selected_slot)
signal dialog_requested(dialog_tree_name, dialog_name)
signal dialog_continued
signal dialog_skipped
signal dialog_finished
signal dialog_paused
signal forced_close_requested
signal line_triggered(character_name, text, time, emotion)
signal dialog_menu_requested(options)
signal dialog_option_clicked(option_dic)
signal dialog_menu_updated(cfg)
signal dialog

var cutscene_skipped := false

var _running := false


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func wait(time := 1.0, is_in_queue := true) -> void:
	if is_in_queue: yield()
	if cutscene_skipped:
		yield(get_tree(), 'idle_frame')
		return
	yield(get_tree().create_timer(time), 'timeout')


func run(instructions: Array, show_gi := true) -> void:
	if _running:
		yield(get_tree(), 'idle_frame')
		return run(instructions, show_gi)

	_running = true
	if not WorldEvent.player_blocked:
		PlayerEvent.emit_signal('control_toggled')

	for idx in instructions.size():
		var instruction = instructions[idx]

		if instruction is String:
			yield(_eval_string(instruction as String), 'completed')
		elif instruction is Dictionary:
			if instruction.has('dialog'):
				_eval_string(instruction.dialog)
				yield(self.wait(instruction.time, false), 'completed')
#				emit_signal('dialog_continued')
		elif instruction is GDScriptFunctionState and instruction.is_valid():
			instruction.resume()
			yield(instruction, 'completed')

	_running = false
	PlayerEvent.emit_signal('control_toggled')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _eval_string(text: String) -> void:
	match text:
		'..':
			yield(wait(0.5, false), 'completed')
		'...':
			yield(wait(1.0, false), 'completed')
		'....':
			yield(wait(2.0, false), 'completed')
		_:
			var char_talk: int = text.find(':')
			if char_talk:
				var char_and_emotion: String = text.substr(0, char_talk)
				var emotion_idx: int = char_and_emotion.find('(')
				var char_name: String = char_and_emotion.substr(0, emotion_idx).to_lower()
				var emotion := ''
				if emotion_idx > 0:
					emotion = char_and_emotion.substr(emotion_idx + 1).rstrip(')')
				var char_line: String = text.substr(char_talk + 1).trim_prefix(' ')
				emit_signal('line_triggered', char_name, tr(char_line), 0, emotion)
				yield(self, 'dialog_continued')
			else:
				yield(get_tree(), 'idle_frame')
