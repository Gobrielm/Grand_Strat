extends TileMapLayer

var tiles_to_provinces := {}

func add_tile_to_province(tile: Vector2i, id: int):
	tiles_to_provinces[tile] = id
	set_cell(tile, 0, get_atlas_for_id(id))

func get_atlas_for_id(id: int) -> Vector2i:
	var num = id % 32
	@warning_ignore("integer_division")
	return Vector2i(num % 8, num / 8)
