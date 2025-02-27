extends Node2D

const TILES_PER_ROW = 8

func get_good_index(coords: Vector2i) -> int:
	var num = coords.x + coords.y * TILES_PER_ROW
	if terminal_map.is_cargo_primary(num):
		return num
	assert(false)
	return -1 

func get_good_name(coords: Vector2i) -> String:
	var num = get_good_index(coords)
	if  num!= 0:
		return terminal_map.get_cargo_name(num)
	assert(false)
	return "null"
