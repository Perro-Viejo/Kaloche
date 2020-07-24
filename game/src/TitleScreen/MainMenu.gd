extends CanvasLayer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export (String, FILE, '*.tscn') var First_Level: String
export (String, FILE, '*.tscn') var intro_scn: String
export(bool) var show_intro = true

var _is_credits := false

onready var _name_container: VBoxContainer = find_node('NameContainer')
onready var _buttons_container: HBoxContainer = find_node('ButtonsContainer')
onready var _new_game: Button = find_node('NewGame')
onready var _options: Button = find_node('Options')
onready var _credits: Button = find_node('Credits')
onready var _exit: Button = find_node('Exit')
onready var _credits_container: TextureButton = find_node('CreditsContainer')
onready var _credits_back: Button = _credits_container.get_node('Back')
onready var _devs: Label = find_node('Devs')
onready var _in_memory: Control = find_node('InMemory')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready()->void:
	Event.MainMenu = true
	guiBrain.gui_collect_focusgroup()
	_credits_container.hide()
	$CPUParticles2D.show()

	if Settings.HTML5:
		_exit.visible = false

	# Conectarse a señales de los hijos
	_new_game.connect('pressed', self, '_on_NewGame_pressed')
	_options.connect('pressed', self, '_on_Options_pressed')
	_credits.connect('pressed', self, '_on_Credits_pressed')
	_exit.connect('pressed', self, '_on_Exit_pressed')

	# Conectarse a señales del universo pokémon
	Settings.connect('ReTranslate', self, 'retranslate') # Localización

	retranslate()


func _process(delta):
	$BG.visible = !Event.Options


func _exit_tree()->void:
	Event.MainMenu = false				#switch bool for easier pause menu detection and more
	guiBrain.gui_collect_focusgroup()	#Force re-collect buttons because main meno wont be there


func _on_NewGame_pressed()->void:
	Event.emit_signal('NewGame')
	if show_intro:
		Event.emit_signal('ChangeScene', intro_scn)
	else:
		Event.emit_signal('ChangeScene', First_Level)


func _on_Options_pressed()->void:
	Event.Options = true


func _on_Credits_pressed() -> void:
	_is_credits = !_is_credits
	_credits_container.visible = _is_credits
	_devs.visible = _is_credits
	_in_memory.visible = _is_credits
	_name_container.visible = !_is_credits
	_buttons_container.visible = !_is_credits
	if _is_credits:
		_credits_back.connect('pressed', self, '_on_Credits_pressed')
		_credits_back.grab_focus()
	else:
		_credits_back.disconnect('pressed', self, '_on_Credits_pressed')
		_credits.grab_focus()


func _on_Exit_pressed()->void:
	Event.emit_signal('Exit')

#localization
func retranslate()->void:
	_new_game.text = tr('NEW_GAME')
	_options.text = tr('OPTIONS')
	_credits.text = tr('CREDITS')
	_exit.text = tr('EXIT')
	_credits_back.text = tr('BACK')
