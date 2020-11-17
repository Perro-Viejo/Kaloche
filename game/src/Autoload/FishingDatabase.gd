extends Node

onready var _fishes: Node = $Fishes
onready var _baits: Node = $Baits

func get_random_fish() -> FishData:
	return _fishes.get_child(randi() % _fishes.get_child_count()) as FishData

func get_random_bait() -> BaitData:
	return _baits.get_child(randi() % _baits.get_child_count()) as BaitData
