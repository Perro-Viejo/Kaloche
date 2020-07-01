class_name Player
extends KinematicBody2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(Color) var dialog_color

const STATES = {
	WALK = 'Walk',
	IDLE = 'Idle',
	GRAB = 'Grab',
	DROP = 'Drop',
	FISH = 'Fish'
}

var is_moving = false
var is_out: bool = false
var can_grab: Area2D = null
var grabbing: bool = false
var on_ground: bool = false
var fishing: bool = false
var fs_id: String = 'FS_Dirt'
var foot = 'L'
var is_paused := false

onready var cam: Camera2D = $Camera2D
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var fishing_spot: ColorRect = $FishingSpot
onready var foot_area: Area2D = $FootArea
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	# Escuchar eventos de los hijos de satán
	$FootArea.connect('body_entered', self, 'toggle_on_ground', [ true ])
	$FootArea.connect('body_exited', self, 'toggle_on_ground')
	$AnimatedSprite.connect('frame_changed', self, '_on_frame_changed')

	# Conectarse a eventos del universo
	Event.connect('line_triggered', self, '_should_speak')
	Event.connect('control_toggled', self, '_toggle_control')

	# Definir estado por defecto
	play_animation()


func change_zoom(out: bool = true) -> void:
	is_out = out

	if out:
		Event.emit_signal('play_requested', 'UI', 'ZoomOut')
	else:
		Event.emit_signal('play_requested', 'UI', 'ZoomIn')

	$Tween.remove_all()
	$Tween.interpolate_property(
		cam,
		'zoom',
		cam.zoom,
		Vector2.ONE * 2 if out else Vector2.ONE / 2,
		1.0 if out else 0.5,
		Tween.TRANS_QUINT,
		Tween.EASE_OUT
	)
	$Tween.start()

	yield($Tween, 'tween_completed')


func play_animation(state: String = '') -> void:
	match state:
		STATES.WALK:
			if not grabbing:
				sprite.play('Run')
			else:
				sprite.play('RunGrab')
		_:
			if not grabbing:
				sprite.play('Idle')
			else:
				sprite.play('IdleGrab')


func toggle_on_ground(body: Node2D, on: = false) -> void:
	if not body.is_in_group('Floor'): return

	on_ground = on

	if on_ground:

		var tile_map: TileMap = body as TileMap
		var tile_set: FloorTileset = tile_map.tile_set
		var tile_pos: Vector2 = (foot_area.global_position / 8).floor()
		# Gono-style
		var dir: Vector2 = $StateMachine/Move._last_dir
		tile_pos.x += dir.x

		if dir.y > 0:
			tile_pos.y += 1

		fs_id = tile_set.get_floor_sfx(tile_map.get_cellv(tile_pos))
	else:
		fs_id = 'FS_Dirt'


func _on_frame_changed() -> void:
	if $AnimatedSprite.animation == 'Run' \
		or $AnimatedSprite.animation == 'RunGrab':
		match $AnimatedSprite.frame:
			0,2:
				play_fs(fs_id)
				if fs_id == 'FS_Water':
					match foot:
						'L':
							$Splash_L.set_emitting(true)
							$Splash_R.restart()
							foot = 'R'
						'R':
							$Splash_R.set_emitting(true)
							$Splash_L.restart()
							foot = 'L'


func play_fs(id):
	Event.emit_signal('play_requested', "Player", id)


func speak(text := '', time_to_disappear := 0):
	Event.emit_signal('character_spoke', self, text, time_to_disappear)
	$TalkingBubble.appear()


# Sirve para disparar comportamientos cuando se ha completado un diálogo
func spoke():
	$TalkingBubble.appear(false)


func _should_speak(character_name, text, time) -> void:
	if name.to_lower() == character_name:
		speak(text, time)


func _toggle_control() -> void:
	is_paused = !is_paused
