class_name Hook
extends Node2D

signal dropped
signal sent_back
signal hooked
signal tried

var target_pos: Vector2 setget _set_target_pos
var target_set := false
var bait := 'Nada' setget _set_bait

onready var origin_pos = position
onready var tween := $Tween
onready var area: Area2D = $Area2D
onready var dflt_pos := position

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	area.monitoring = false
	area.monitorable = false
	# mateo: aún no sé si esto será así porque puede que queramos que se vea el
	# gancho mientras cuelga de la caña antes de ser lanzado...
	$Sprite.visible = false

	DebugOverlay.add_monitor('\ncarnada', self, ':bait')

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func pull_done(rod_strength: float) -> Dictionary:
	if $StateMachine.state.has_method('pull_done') :
		return $StateMachine.state.pull_done(rod_strength)
	return {}

func hook_success(fish_data: FishData) -> void:
	$StateMachine.transition_to_key('Hooked', fish_data.get_data())

func hook_fail() -> void:
	emit_signal('tried')

func play_animation(animation_name := '', speed := 1.0) -> void:
	if $AnimationPlayer.has_animation(animation_name):
		$AnimationPlayer.play(animation_name, -1.0, speed)
	else:
		printerr('Soy el Hook y no tengo la animación %s' % animation_name)

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _set_target_pos(end_pos: Vector2) -> void:
	dflt_pos = position
	target_pos = position + end_pos
	target_set = true

func _set_bait(new_bait := '') -> void:
	if not new_bait: new_bait = 'Nada'
	bait = new_bait