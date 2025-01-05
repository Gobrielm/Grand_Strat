extends TileMapLayer

var map: TileMapLayer
var unit_data: Dictionary = {}
func _ready():
	map = get_parent()

@rpc("any_peer", "call_remote", "unreliable")
func create_unit(coords: Vector2i):
	set_cell(coords, 1, Vector2i(0, 0))
	unit_data[coords] = line_infantry.new()

func move_unit(coords: Vector2i, move_to: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(coords)
	var soldier_data = unit_data[coords]
	set_cell(move_to, 1, soldier_atlas)
	unit_data[move_to] = soldier_data
	unit_data.erase(coords)

func select_unit(coords: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(coords)
	if soldier_atlas != Vector2i(-1, -1):
		map.click_unit()
		var soldier_data = unit_data[coords]


func _process(delta):
	pass
