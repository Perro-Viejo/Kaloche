extends Node

func get_random_fish() -> FishData:
	return get_child(randi() % get_child_count()) as FishData
