extends HBoxContainer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
enum OPT { RESOLUTION, AUDIO, LANGUAGE, CONTROLS, BACK }

var SetUp:bool = true #need to disable playing sound on initiating faders

var _close_panel_btn: Button = null
var _last_focus_owner: Control = null

# Las opciones
onready var _resolution_option: Button = find_node('Resolution')
onready var _audio_option: Button = find_node('Audio')
onready var _language_option: Button = find_node('Languages')
# Los paneles
onready var _panels := {
	audio = find_node('AudioPanel') as Panel,
	resolution = find_node('ResolutionPanel') as Panel,
	language = find_node('LanguagePanel') as Panel,
}
onready var Master: HSlider = find_node('Master').get_node('HSlider')
onready var Music: HSlider = find_node('Music').get_node('HSlider')
onready var SFX: HSlider = find_node('SFX').get_node('HSlider')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready()->void:
	# Esconder los paneles por si alguno se quedó visible durante la edición en
	# el editor
	_hide_panels()
	
	#Set up toggles and sliders
	if Settings.HTML5:
		find_node('Borderless').visible = false
		find_node('Scale').visible = false
	set_resolution()
	set_volume_sliders()
	Event.Languages = false #just in case project saved with visible Languages

	SetUp = false #Finished fader setup

	# Conectarse a señales de los hijos de su mamá
	_resolution_option.connect(
		'pressed', self, '_on_option_pressed', [ OPT.RESOLUTION ]
	)
	_audio_option.connect('pressed', self, '_on_option_pressed', [ OPT.AUDIO ])
	_language_option.connect('pressed', self, '_on_option_pressed', [ OPT.LANGUAGE ])

	# Conectarse a señales del mundo pokémon
#	Event.connect('Controls', self, '_on_option_pressed', [ OPT.CONTROLS ])
#	Event.connect('Languages', self, '_on_option_pressed', [ OPT.LANGUAGE ])
	Settings.connect('Resized', self, '_on_Resized')
	Settings.connect('ReTranslate', self, 'retranslate') # Localización

	retranslate()

func set_resolution()->void:
	find_node('Fullscreen').pressed = Settings.Fullscreen
	find_node('Borderless').pressed = Settings.Borderless
	#Your logic for scaling

func set_volume_sliders()->void: #Initialize volume sliders
	Master.value = Settings.VolumeMaster * 100
	Music.value = Settings.VolumeMusic * 100
	SFX.value = Settings.VolumeSFX * 100

# ⋐▒▒▒ CONTROL DE PANELES ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒⋑
func _on_option_pressed(id := -1) -> void:
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	_hide_panels()
	
	_last_focus_owner = guiBrain.FocusDetect.get_focus_owner()
	match id:
		OPT.RESOLUTION:
			_panels.resolution.visible = true
			find_node('Fullscreen').grab_focus()
		OPT.AUDIO:
			_panels.audio.visible = true
			# TODO: Encontrar una forma menos manual de hacer esta mierda
			find_node('Master').get_node('HSlider').grab_focus()
		OPT.LANGUAGE:
			_panels.language.visible = true
			# TODO: Encontrar una forma menos manual de hacer esta mierda
			_panels.language.find_node('LanguageOptions').get_child(0).grab_focus()
	
	_close_panel_btn = _get_current_panel().find_node('Close')
	if _close_panel_btn and \
		not _close_panel_btn.is_connected('pressed', self, '_close_panel'):
		_close_panel_btn.connect('pressed', self, '_close_panel')

func _hide_panels() -> void:
	for p in _panels:
		_panels[p].hide()

func _get_current_panel() -> Panel:
	var current: Panel = null
	for p in _panels:
		if _panels[p].visible:
			current = _panels[p]
			break
	return current

func _close_panel() -> void:
	for p in _panels:
		if _panels[p].visible:
			_panels[p].hide()
			break
	_last_focus_owner.grab_focus()
	_last_focus_owner = null
# ⋐▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ CONTROL DE PANELES ▒▒▒▒⋑

#### BUTTON SIGNALS ####
func _on_Master_value_changed(value):
	if SetUp:
		return
	Settings.VolumeMaster = value/100
	var player:AudioStreamPlayer = find_node('Master').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()

func _on_Music_value_changed(value):
	if SetUp:
		return
	Settings.VolumeMusic = value/100
	var player:AudioStreamPlayer = find_node('Music').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()

func _on_SFX_value_changed(value):
	if SetUp:
		return
	Settings.VolumeSFX = value/100
	var player:AudioStreamPlayer = find_node('SFX').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()

func _on_Fullscreen_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	if SetUp:
		return
	Settings.Fullscreen = find_node('Fullscreen').pressed

func _on_Borderless_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	if SetUp:
		return
	Settings.Borderless = find_node('Borderless').pressed

func _on_ScaleUp_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Settings.Scale += 1

func _on_ScaleDown_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Settings.Scale -= 1

func _on_Resized()->void:
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	set_resolution()

func _on_Languages_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Event.Languages = !Event.Languages
	if !Event.Languages:
		return
	yield(Settings, 'ReTranslate') #After choosing language it will trigger ReTranslate
	Event.Languages = !Event.Languages

func _on_Controls_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Event.Controls = true

func _on_Back_pressed():
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	Settings.save_settings()
	Event.Options = false

#localization
func retranslate()->void:
	find_node('Resolution').text = tr('RESOLUTION')
	find_node('Volume').text = tr('VOLUME')
	get_node('PanelsContainer/LanguagePanel/VBoxContainer/Languages').text = tr('LANGUAGES')
	find_node('Fullscreen').text = tr('FULLSCREEN')
	find_node('Borderless').text = tr('BORDERLESS')
	find_node('Scale').text = tr('SCALE')
	find_node('Master').get_node('ScaleName').text = tr('MASTER')
	find_node('Music').get_node('ScaleName').text = tr('MUSIC')
	find_node('SFX').get_node('ScaleName').text = tr('SFX')
	get_node('OptionsContainer/VBoxContainer/Languages').text = tr('LANGUAGES')
	find_node('Controls').text = tr('CONTROLS')
	find_node('Back').text = tr('BACK')

func set_node_in_focus()->void:
	var FocusGroup:Array = get_groups()
	print(FocusGroup)
