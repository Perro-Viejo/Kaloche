tool
class_name FishPickable
extends "res://src/Pickables/Pickable.gd"

onready var _tween: Tween = get_node("Tween")

var spawn = false
var countdown = 6
var fish_type := [
	{
		type = 'apuy',
		chance = {
			Data.BAITS.GUSANO: 1,
			Data.BAITS.SANGRE: 0
		}
	},
	{
		type = 'chanchita',
		chance = {
			Data.BAITS.GUSANO: 0.5,
			Data.BAITS.SANGRE: 0.2
		}
	},
	{
		type = 'cachama',
		chance = {
			Data.BAITS.GUSANO: 0.3,
			Data.BAITS.SANGRE: 0.5
		}
	},
	{
		type = 'piranha',
		chance = {
			Data.BAITS.GUSANO: 0.05,
			Data.BAITS.SANGRE: 1
		}
	},
	{
		type = 'bocachico',
		chance = {
			Data.BAITS.GUSANO: 0.8,
			Data.BAITS.SANGRE: 0.15
		}
	}
]


func jump(origin):
	monitorable = false
	monitoring = false
	_tween.interpolate_property(
		self, "position",
		position, position + (origin * -1) * rand_range(1.5, 2.5) , 1.6,
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	_tween.start()
	_tween.connect('tween_completed', self, '_enable_monitoring')
#	Aquí debería el pez saltar por su vida cuando llegue a su posición final


func check_bait(bait):
	var chance := randf()
	var selected_fish := ''
	var i := 0
	if bait != Data.BAITS.NADA:
		randomize()
		fish_type.shuffle()
		while not selected_fish:
			if chance <= fish_type[i].chance[bait]:
				selected_fish = fish_type[i].type
			else:
				i += 1
	else:
		selected_fish = 'gen'

	tr_code = selected_fish
	set_sprite_texture(load("res://assets/images/world/fish_" + selected_fish + ".png"))
#	$Bubble/Label.text = 'P_' + (tr_code if tr_code != '' else name).to_upper()


func _enable_monitoring(_obj: Object, _key: NodePath) -> void:
	if is_in_group('Sacred'):
		AudioEvent.emit_signal('play_requested', 'Pickable', 'Sacred_Loop', global_position)
		AudioEvent.emit_signal('follow_requested', 'Pickable', 'Sacred_Loop', self, true)
	yield(get_tree().create_timer(0.5), 'timeout')
	monitorable = true
	monitoring = true

func queue_free():
	if is_in_group('Sacred'):
		AudioEvent.emit_signal('stop_requested', 'Pickable', 'Sacred_Loop')
		AudioEvent.emit_signal('follow_requested', 'Pickable', 'Sacred_Loop', self, false)
	yield(get_tree(), "idle_frame")
	.queue_free()
