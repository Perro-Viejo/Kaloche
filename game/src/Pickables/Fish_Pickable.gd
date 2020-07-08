tool
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
	_tween.interpolate_property(self, "position",
		position, position + (origin*-1)*rand_range(2.5, 4.5) , 1.6,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	_tween.start()

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
	$Bubble/Label.text = 'P_' + (tr_code if tr_code != '' else name).to_upper()
#



