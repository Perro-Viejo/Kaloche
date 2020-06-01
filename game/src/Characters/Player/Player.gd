class_name Player
extends KinematicBody2D
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
const STATES = {
	WALK = 'Walk',
	IDLE = 'Idle',
	GRAB = 'Grab',
	DROP = 'Drop'
}

var is_moving = false
var is_out: bool = false
var can_grab: Area2D = null
var grabbing: bool = false
var on_ground: bool = false
var fs_id: String = 'FS_Dirt'

onready var cam: Camera2D = $Camera2D
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var foot_area: Area2D = $FootArea
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	# Escuchar area
	$FootArea.connect('body_entered', self, 'toggle_on_ground', [ true ])
	$FootArea.connect('body_exited', self, 'toggle_on_ground')
	$AnimatedSprite.connect('frame_changed', self, '_on_frame_changed')

	# Definir estado por defecto
	play_animation()


func change_zoom(out: bool = true) -> void:
	is_out = out

	if out:
		Event.emit_signal('play_requested', 'UI', 'ZoomOut')
	else:
		Event.emit_signal('play_requested', 'UI', 'ZoomIn')
	# Hacer que camine más rápido si está afuera
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
		STATES.GRAB:
			sprite.play('Grab')
		STATES.DROP:
			sprite.play('Drop')
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

	if $AnimatedSprite.animation == 'Run' or $AnimatedSprite.animation == 'RunGrab':
		match $AnimatedSprite.frame:
			0,3:
				play_fs(fs_id)

func play_fs(id):
	Event.emit_signal('play_requested', "Player", id)

