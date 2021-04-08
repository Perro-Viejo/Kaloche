extends CanvasLayer

export (String, FILE, "*.tscn") var Main_Menu: String

var _world_positions := []

onready var _options_container: Container = find_node('OptionsContainer')
onready var _teletransport_container: Container = find_node('TeletransportContainer')
onready var _level_positions: OptionButton = find_node('PositionsList')
onready var _teletransport_separator: HSeparator = find_node('TeletransportSeparator')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready()->void:
	_teletransport_container.hide()
	_teletransport_separator.hide()
	
	GuiEvent.connect("Paused", self, "on_show_paused")
	GuiEvent.connect("Options", self, "on_show_options")
	SectionEvent.Paused = false
	#localization
	Settings.connect("ReTranslate", self, "_retranslate")
	WorldEvent.connect('world_entered', self, '_on_world_entered')


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func on_show_paused(value:bool)->void:
	#Signals allow each module have it's own response logic
	$Control.visible = value
	get_tree().paused = value


func on_show_options(value:bool)->void:
	AudioEvent.emit_signal('play_requested', 'UI', 'Gen_Button')
	if !SectionEvent.MainMenu:
		$Control.visible = !value


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_Resume_pressed():
	AudioEvent.emit_signal('play_requested', 'UI', 'Gen_Button')
	SectionEvent.Paused = false #setget triggers signal and responding to it hide GUI


func _on_Restart_pressed():
	GuiEvent.emit_signal('play_requested', 'UI', 'Gen_Button')
	GuiEvent.emit_signal("Restart")
	SectionEvent.Paused = false #setget triggers signal and responding to it hide GUI


func _on_Options_pressed():
	AudioEvent.emit_signal('play_requested', 'UI', 'Gen_Button')
	SectionEvent.Options = true


func _on_MainMenu_pressed():
	AudioEvent.emit_signal('play_requested', 'UI', 'Gen_Button')
	GuiEvent.emit_signal("ChangeScene", Main_Menu)
	SectionEvent.Paused = false


func _on_Exit_pressed():
	AudioEvent.emit_signal('play_requested', 'UI', 'Gen_Button')
	GuiEvent.emit_signal("Exit")


func _retranslate()->void:
	find_node("Resume").text = tr("RESUME")
	find_node("Restart").text = tr("RESTART")
	find_node("Options").text = tr("OPTIONS")
	find_node("MainMenu").text = tr("MAIN_MENU")
	find_node("Exit").text = tr("EXIT")


func _on_world_entered(data: Dictionary):
	if OS.has_feature('debug'):
		if data.has('points'):
			_level_positions.add_item('Ningún sitio')
			for p in data.points:
				_world_positions.append((p as Position2D).get_instance_id())
				_level_positions.add_item(p.name, p.get_index())

			_level_positions.connect('item_selected', self, '_position_selected')
			_teletransport_container.show()
			_teletransport_separator.show()


func _position_selected(index: int) -> void:
	if index == 0: return
	WorldEvent.emit_signal('zone_position_requested', _world_positions[index - 1])
