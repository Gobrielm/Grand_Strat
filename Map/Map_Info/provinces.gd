extends TileMapLayer

var tiles_to_provinces := {}
var colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(0.5, 0.5, 0), Color(0.5, 0, 0.5), Color(0, 0.5, 0.5)]

func add_tile_to_province(tile: Vector2i, id: int):
	tiles_to_provinces[tile] = id
	set_cell(tile, 0, get_atlas_for_id(id))

func get_atlas_for_id(id: int) -> Vector2i:
	var num = id % 32
	@warning_ignore("integer_division")
	return Vector2i(num % 8, num / 8)

func get_color(tile: Vector2i) -> Color:
	var atlas = get_cell_atlas_coords(tile)
	var num = atlas.y * 8 + atlas.x
	if num < 0:
		return Color(0, 0, 0, 0)
	return colors[num]
