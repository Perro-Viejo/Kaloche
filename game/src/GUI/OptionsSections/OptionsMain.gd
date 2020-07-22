extends HBoxContainer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
enum OPT { RESOLUTION, AUDIO, LANGUAGE, CONTROLS, BACK }

var SetUp:bool = true #need to disable playing sound on initiating faders

# Las opciones
onready var _resolution_option: Button = find_node('Resolution')
onready var _audio_option: Button = find_node('Audio')
# Los paneles
onready var _audio_panel:Panel = find_node('AudioPanel')
onready var _resolution_panel:Panel = find_node('Panel')
onready var Master:HSlider = find_node('Master').get_node('HSlider')
onready var Music:HSlider = find_node('Music').get_node('HSlider')
onready var SFX:HSlider = find_node('SFX').get_node('HSlider')
onready var Language_panel:Panel = find_node('Panel3')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready()->void:
	# Esconder los paneles por si alguno se quedó visible durante la edición en
	# el editor
	_resolution_panel.hide()
	_audio_panel.hide()
	
	#Set up toggles and sliders
	if Settings.HTML5:
		find_node('Borderless').visible = false
		find_node('Scale').visible = false
	set_resolution()
	set_volume_sliders()
	Event.Languages = false #just in case project saved with visible Languages

	SetUp = false #Finished fader setup

	# Conectarse a señales de los hijos de su mamá
	_resolution_option.connect('pressed', self, '_on_option_pressed', [ OPT.RESOLUTION ])
	_audio_option.connect('pressed', self, '_on_option_pressed', [ OPT.AUDIO ])

	# Conectarse a señales del mundo pokémon
	Event.connect('Controls', self, 'on_show_controls')
	Event.connect('Languages', self, 'on_show_languages')
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

# ██████████████████████████████████████████████████████████████████████████████
func _on_option_pressed(id := -1) -> void:
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	_hide_panels()
	match id:
		OPT.RESOLUTION:
			_resolution_panel.visible = true
		OPT.AUDIO:
			_audio_panel.visible = true

func _hide_panels() -> void:
	_resolution_panel.hide()
	_audio_panel.hide()

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

func _on_Resolution_pressed() -> void:
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	_resolution_panel.visible = true

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

#EVENT SIGNALS
func on_show_controls(value:bool)->void:
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	visible = !value 	#because showing controls

func on_show_languages(value:bool)->void:
	Event.emit_signal('play_requested', 'UI', 'Gen_Button')
	_resolution_panel.visible = !value
	_audio_panel.visible = !value

#localization
func retranslate()->void:
	find_node('Resolution').text = tr('RESOLUTION')
	find_node('Volume').text = tr('VOLUME')
	get_node('PanelsContainer/Panel3/VBoxContainer/Languages').text = tr('LANGUAGES')
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
