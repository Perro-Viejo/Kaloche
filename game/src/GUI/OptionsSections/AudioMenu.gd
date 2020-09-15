extends Panel
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
var _enable := visible

onready var _master:VBoxContainer = find_node('Master')
onready var _music:VBoxContainer = find_node('Music')
onready var _sfx:VBoxContainer = find_node('SFX')
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	set_volume_sliders()

	self.connect('visibility_changed', self, '_change_enable')
	_master.connect('value_changed', self, '_on_Master_value_changed')
	_music.connect('value_changed', self, '_on_Music_value_changed')
	_sfx.connect('value_changed', self, '_on_SFX_value_changed')

func set_volume_sliders() -> void: #Initialize volume sliders
	_master.value = Settings.VolumeMaster * 100
	_music.value = Settings.VolumeMusic * 100
	_sfx.value = Settings.VolumeSFX * 100

func _change_enable() -> void:
	_enable = visible
	if _enable:
		_master.get_node('HSlider').grab_focus()

func _on_Master_value_changed(value: float):
	if not _enable:
		return
	Settings.VolumeMaster = value/100
	var player:AudioStreamPlayer = find_node('Master').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()

func _on_Music_value_changed(value: float):
	if not _enable:
		return
	Settings.VolumeMusic = value/100
	var player:AudioStreamPlayer = find_node('Music').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()

func _on_SFX_value_changed(value: float):
	if not _enable:
		return
	Settings.VolumeSFX = value/100
	var player:AudioStreamPlayer = find_node('SFX').get_node('AudioStreamPlayer')
	player.stream = preLoad.snd_TestBeep
	player.play()
