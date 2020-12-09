class_name FloorTileset
extends TileSet

export(Array, int, "Red", "Green", "Blue") var enums = [2, 1, 0]

func get_floor_sfx(id: int) -> String:
	if id > -1:
		match tile_get_name(id):
			'river-grass':
				return 'Grass'
			'stone_floor':
				return 'Rock'
			'water':
				return 'Water'
	return 'Dirt'
