class_name Hook
extends KinematicBody2D

signal dropped
signal sent_back
signal hooked
signal tried
signal fish_fled

export(NodePath) var rod_tip_ref

var target_pos: Vector2 setget _set_target_pos
var target_set := false
var bait := 'Nada' setget _set_bait
var thrown = false
var height = -135
var time = 0
var surface_ref: Area2D = null setget _set_surface_ref
# TODO: Esto debería de alguna forma estar vinculado a la zona/mapa donde esté
# el jugador. Por ejemplo, en el capítulo 0.1 el área más grande es de pasto (Grass),
# pero podría haber otros escenarios donde la mayoría sea roca o tierra o charco.
var surface_type := 'Grass'

onready var origin_pos = position
onready var tween := $Tween
onready var area: Area2D = $Area2D
onready var string = $String
onready var dflt_pos := position
onready var rod_tip := get_node(rod_tip_ref)

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	area.monitoring = false
	area.monitorable = false
	# mateo: aún no sé si esto será así porque puede que queramos que se vea el
	# gancho mientras cuelga de la caña antes de ser lanzado...
	$Sprite.visible = false

	DebugOverlay.add_monitor('\ncarnada', self, ':bait')


func _process(delta):
	if thrown:
		position.y = height * (-time * time + time)


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func pull_done(rod_strength: float) -> Dictionary:
	if $StateMachine.state.has_method('pull_done') :
		return $StateMachine.state.pull_done(rod_strength)
	return {}


func hook_success(fish_data: Dictionary) -> void:
	$StateMachine.transition_to_key('Hooked', fish_data)


func hook_fail() -> void:
	emit_signal('tried')
	AudioEvent.emit_signal('play_requested', 'Fishing', 'escape', global_position)


func play_animation(animation_name := '', speed := 1.0) -> void:
	if $AnimationPlayer.has_animation(animation_name):
		$AnimationPlayer.play(animation_name, -1.0, speed)
	else:
		printerr('Soy el Hook y no tengo la animación %s' % animation_name)


func show_hook(value): 
	$Sprite.visible = value
	$String.visible = value


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _set_target_pos(end_pos: Vector2) -> void:
	dflt_pos = position
	target_pos = position + end_pos
	target_set = true


func _set_bait(new_bait := '') -> void:
	if not new_bait: new_bait = 'Nada'
	bait = new_bait


func _set_surface_ref(new_surface: Area2D) -> void:
	if surface_ref and new_surface \
		and new_surface.get_instance_id() == surface_ref.get_instance_id():
		return

	surface_ref = new_surface
	surface_type = new_surface.surface_name if new_surface else 'Grass'

	if $StateMachine.state.has_method('surface_updated') :
		$StateMachine.state.surface_updated()
