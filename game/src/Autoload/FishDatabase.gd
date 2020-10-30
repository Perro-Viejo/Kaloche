extends Node

func get_random_fish() -> FishData:
	var fish: FishData = null
	if randf() > 0.8:
		fish = get_child(randi() % get_child_count()) as FishData
	return fish
