extends TileMapLayer

var cargo_buildings: Dictionary

func _ready():
	create_atlas_to_building()
	for cell in get_used_cells():
		var building = instance_building_from_coords(cell)
		terminal_map.create_terminal(building)

func instance_building_from_coords(coords: Vector2i) -> terminal:
	var atlas = get_cell_atlas_coords(coords)
	var loaded_script = get_script_from_atlas(atlas)
	assert(loaded_script != null)
	return loaded_script.new(coords)

func get_script_from_atlas(coords: Vector2i):
	if !cargo_buildings.has(coords):
		return null
	return cargo_buildings[coords]

func transform_construction_site_to_factory(coords: Vector2i):
	set_cell(coords, 0, Vector2i(4, 1))

func create_factory(_building_id: int, coords: Vector2i):
	var new_factory = load("res://Cargo/Cargo_Objects/Specific/Player/construction_site.gd").new(coords)
	set_cell(coords, 0, Vector2i(3, 1))
	terminal_map.create_terminal(new_factory)

func create_atlas_to_building():
	cargo_buildings = {}
	cargo_buildings[Vector2i(0, 0)] = load("res://Cargo/Cargo_Objects/Specific/Secondary/lumber_mill.gd")
	cargo_buildings[Vector2i(1, 0)] = load("res://Cargo/Cargo_Objects/Specific/Primary/woodcutter.gd")
	cargo_buildings[Vector2i(0, 1)] = load("res://Cargo/Cargo_Objects/Specific/Endpoint/town.gd")
	
