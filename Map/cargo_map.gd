extends TileMapLayer

var cargo_buildings: Dictionary
var cargo_controller

func assign_cargo_controller(new_cargo_controller):
	cargo_controller = new_cargo_controller
	ready()

func ready():
	create_atlas_to_building()
	for cell in get_used_cells():
		var building = instance_building_from_coords(cell)
		cargo_controller.create_terminal(building)

func instance_building_from_coords(coords: Vector2i) -> terminal:
	var atlas = get_cell_atlas_coords(coords)
	var loaded_script = get_script_from_atlas(atlas)
	if loaded_script == null:
		print("error")
		return null
	return loaded_script.new(coords)

func get_script_from_atlas(coords: Vector2i):
	if !cargo_buildings.has(coords):
		return null
	return cargo_buildings[coords]

func create_atlas_to_building():
	cargo_buildings = {}
	cargo_buildings[Vector2i(0, 0)] = load("res://Cargo/Cargo_Objects/Specific/Secondary/lumber_mill.gd")
	cargo_buildings[Vector2i(1, 0)] = load("res://Cargo/Cargo_Objects/Specific/Primary/woodcutter.gd")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
