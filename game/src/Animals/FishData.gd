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
var size_str := ''
var is_sacred := false

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	yield(owner, 'ready')
	init_data()

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func init_data() -> void:
	if type == Type.GEN:
		attracted_to['Nada'] = 1.0
		for b in FishingDatabase.get_baits():
			attracted_to[b.name] = 0.1
	else:
		for bait in chances:
			attracted_to[get_node(bait).name] = chances[bait]

	randomize()
	size = rand_range(size_range.min, size_range.max)
	
	if size <= 0.5:
		resistance = rand_range(1, 3)
		catch_sfx = 'small'
		size_str = 'sm'
	elif size > 0.5 and size <= 1:
		resistance = rand_range(3, 7)
		catch_sfx = 'med'
		size_str = 'md'
	elif size > 1:
		resistance = rand_range(7, 12)
		catch_sfx = 'large'
		size_str = 'xl'

func get_data() -> Dictionary:
	return {
		name = 'FISH_' + Type.keys()[type],
		node_name = name,
		size = size,
		resistance = resistance,
		icon = icon,
		sprite = sprite,
		catch_sfx = catch_sfx,
		attracted_to = attracted_to,
		is_sacred = is_sacred
	}
