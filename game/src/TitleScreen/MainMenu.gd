extends CanvasLayer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export (String, FILE, "*.tscn") var First_Level: String
export (String, FILE, "*.tscn") var intro_scn: String
export(bool) var show_intro = true
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready()->void:
	Event.MainMenu = true
	guiBrain.gui_collect_focusgroup()
	if Settings.HTML5:
		$"BG/MarginContainer/VBoxMain/HBoxContainer/ButtonContainer/Exit".visible = false
	#localization
	Settings.connect("ReTranslate", self, "retranslate")
	retranslate()

func _process(delta):
	$BG.visible = !Event.Options

func _exit_tree()->void:
	Event.MainMenu = false				#switch bool for easier pause menu detection and more
	guiBrain.gui_collect_focusgroup()	#Force re-collect buttons because main meno wont be there

func _on_NewGame_pressed()->void:
	Event.emit_signal("NewGame")
	if show_intro:
		Event.emit_signal("ChangeScene", intro_scn)
	else:
		Event.emit_signal("ChangeScene", First_Level)

func _on_Options_pressed()->void:
	Event.Options = true

func _on_Exit_pressed()->void:
	Event.emit_signal("Exit")

#localization
func retranslate()->void:
	find_node("NewGame").text = tr("NEW_GAME")
	find_node("Options").text = tr("OPTIONS")
	find_node("Exit").text = tr("EXIT")
