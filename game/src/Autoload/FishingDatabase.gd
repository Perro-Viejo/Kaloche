extends Node

var _bait_idx := 0

onready var _fishes: Node = $Fishes
onready var _baits: Node = $Baits

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func get_random_fish() -> FishData:
	return _fishes.get_child(randi() % _fishes.get_child_count()) as FishData

func get_random_bait() -> BaitData:
	_bait_idx = randi() % _baits.get_child_count()
	return _baits.get_child(_bait_idx) as BaitData

func get_next_bait() -> BaitData:
	var bait: BaitData = null
	
	if _bait_idx >= 0:
		bait = _baits.get_child(_bait_idx)
	
	_bait_idx = wrapi(_bait_idx + 1, -1, _baits.get_child_count())
	
	return bait

func get_baits() -> Array:
	return _baits.get_children()

func get_bait(bait_idx) -> BaitData:
	var bait: BaitData = null
	bait = _baits.get_child(bait_idx)
	print(bait)
	
	return bait
