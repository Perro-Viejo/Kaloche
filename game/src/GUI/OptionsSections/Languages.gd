extends Panel
signal Language_choosen
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
onready var button: PackedScene = preload('res://src/GUI/Buttons/DefaultButton.tscn')
onready var options_container: VBoxContainer = find_node('LanguageOptions')
onready var _close: Button = find_node('Close')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready()->void:
	for language in Settings.Language_list:
		var newButton: Button = button.instance()
		var languageStr: String = Settings.Language_dictionary[language]
		newButton.text = '%s%s' %\
			[ language, ' [X]' if languageStr == Settings.Language else ''  ]
		newButton.connect('pressed', self, '_on_button_pressed', [language])

		options_container.add_child(newButton)
	options_container.move_child(_close, options_container.get_child_count())

	# Reasignar focas
	options_container.get_child(0).focus_previous = _close.get_path()
	options_container.get_child(0).focus_neighbour_top = _close.get_path()
	_close.focus_next = options_container.get_child(0).get_path()
	_close.focus_neighbour_bottom = options_container.get_child(0).get_path()


func _on_button_pressed(value:String)->void:
	Settings.Language = Settings.Language_dictionary[value] #Settings will emit ReTranslate
