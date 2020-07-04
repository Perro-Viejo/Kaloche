tool
extends "res://src/Pickables/Pickable.gd"

onready var _tween: Tween = get_node("Tween")

var spawn = false
var countdown = 6
var fish_type = ['apuy', 'bocachico', 'cachama', 'chanchita', 'piranha']

func jump(origin):
	_tween.interpolate_property(self, "position",
		position, position + (origin*-1)*rand_range(2.5, 4.5) , 1.6,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	_tween.start()

func check_bait(bait):
	var chance = randi()%100
	var selected_fish
	match bait:
		1:
			if chance <= 20:
				selected_fish = fish_type[0]
			if chance > 20 && chance <= 40:
				selected_fish = fish_type [1]
			if chance > 40 && chance <= 60:
				selected_fish = fish_type [2]
			if chance > 60 && chance <= 80:
				selected_fish = fish_type [3]
			if chance > 80:
				selected_fish = fish_type [4]
		2:
			if chance <= 50:
				selected_fish = fish_type[2]
			else:
				selected_fish = fish_type[4]
		_:
			selected_fish = 'gen'
	tr_code = selected_fish
	set_sprite_texture(load("res://assets/images/world/fish_"+ selected_fish + ".png"))
	$Bubble/Label.text = 'P_' + (tr_code if tr_code != '' else name).to_upper()
#



