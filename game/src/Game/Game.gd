class_name Game
extends Node2D

signal SceneIsLoaded

enum {IDLE, FADEOUT, FADEIN}

export var show_debug := true
export var disable_mouse := true
export var hide_teletransport_in_editor := false

var NextScene
var FadeState:int = IDLE

onready var CurrentScene = null
onready var CurrentSceneInstance = $Levels.get_child($Levels.get_child_count() - 1)
onready var _mouse_blocker: Control = $MouseBlocker/Control


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready()->void:
	Data.set_data(Data.CURRENT_SCENE, 'MainMenu')
	Data.set_data(Data.SHOW_DEBUG, show_debug)
	Data.set_data(Data.HIDE_TELETRANSPORT_IN_EDITOR, hide_teletransport_in_editor)
	
	if disable_mouse:
		_mouse_blocker.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		_mouse_blocker.hide()
	
	if OS.has_feature('release'):
		Data.set_data(Data.SHOW_DEBUG, false)
	
	if Settings.HTML5 or OS.has_feature('release'):
		_mouse_blocker.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Conectarse a eventos de los chabalitos
	$HTMLfocus.connect('closed', self, '_on_html_focus_closed')


	# Conectarse a eventos del universo digimon
	GuiEvent.connect("Options",	self, "on_Options")
	GuiEvent.connect("Exit",		self, "on_Exit")
	GuiEvent.connect("ChangeScene",self, "on_ChangeScene")
	GuiEvent.connect("Restart", 	self, "restart_scene")
	# Background loader
	SceneLoader.connect("scene_loaded", self, "on_scene_loaded")

	# Perro Viejo
	AudioEvent.connect('music_requested', self, 'play_song')
	AudioEvent.connect('music_stoped', $Music, 'stop')

	AudioEvent.emit_signal("play_requested", "MX", "Menu")
	
	# Agregar comandos a la consola de comandos
	Console.add_command('on_top', OS, 'set_window_always_on_top')\
			.add_argument('enabled', TYPE_BOOL)\
			.register()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func on_Options(options) -> void:
	guiBrain.gui_collect_focusgroup()


func on_ChangeScene(scene):
	if FadeState != IDLE:
		return

	if Settings.HTML5:
		NextScene = load(scene)
	else:
		SceneLoader.load_scene(scene, {scene="Level"})

	FadeState = FADEOUT

	$FadeLayer/FadeTween.interpolate_property(
		$FadeLayer, "percent",
		0.0, 1.0,
		0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.0
	)
	$FadeLayer/FadeTween.start()

func on_Exit()->void:
	if FadeState != IDLE:
		return
	get_tree().quit()

func on_scene_loaded(Loaded)->void:
	NextScene = Loaded.resource
	emit_signal("SceneIsLoaded")	#Scene fade signal in case it loads longer than fade out

func change_scene()->void: #handle actual scene change
	if NextScene == null:
		return
	yield(get_tree(), "idle_frame") #continue on idle frame
	CurrentSceneInstance.free()
	CurrentScene = NextScene
	NextScene = null
	CurrentSceneInstance = CurrentScene.instance()
	Data.set_data(Data.CURRENT_SCENE, CurrentSceneInstance.name)
	$Levels.add_child(CurrentSceneInstance)

func restart_scene():
	if FadeState != IDLE:
		return
	yield(get_tree(), "idle_frame")
	CurrentSceneInstance.free()
	CurrentSceneInstance = CurrentScene.instance()
	$Levels.add_child(CurrentSceneInstance)

func play_song(mx: AudioStream) -> void:
	$Music.stream = mx
	$Music.play()

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _on_FadeTween_tween_completed(object, key)->void:
	match FadeState:
		IDLE:
			pass
		FADEOUT:
			if NextScene == null:
				print("Not loaded, please wait!")
				yield(self, "SceneIsLoaded")
			change_scene()
			FadeState = FADEIN
			$FadeLayer/FadeTween.interpolate_property(
				$FadeLayer, "percent",
				1.0, 0.0,
				0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.0
			)
			$FadeLayer/FadeTween.start()
		FADEIN:
			FadeState = IDLE


func _on_html_focus_closed() -> void:
	guiBrain.gui_collect_focusgroup()
