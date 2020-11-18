class_name FishData
extends Node

enum Type { GEN, APUY, CHANCHITA, CACHAMA, PIRANHA, BOCACHICO }

export(Type) var type = Type.GEN
export var icon: Texture = null
export var sprite: Texture = null
export var chances := {}
export var size_range := { min = 0.2, max = 1.3 }

var size := 0.0
var resistance := 0
var catch_sfx := ''
var attracted_to := {}

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	for bait in chances:
		attracted_to[get_node(bait).name] = chances[bait]

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func get_data() -> Dictionary:
	randomize()
	size = rand_range(size_range.min, size_range.max)

	if size <= 0.5:
		resistance = rand_range(1, 3)
		catch_sfx = 'small'
	elif size > 0.5 and size <= 1 :
		resistance = rand_range(3, 7)
		catch_sfx = 'med'
	elif size > 1:
		resistance = rand_range(7, 12)
		catch_sfx = 'large'
	
	return {
		name = 'FISH_' + Type.keys()[type],
		size = size,
		resistance = resistance,
		icon = icon,
		sprite = sprite,
		catch_sfx = catch_sfx
	}
