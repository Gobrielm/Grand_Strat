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
	var building_name = cargo_buildings[atlas]
	var loaded_script = load("res://Cargo/Cargo_Objects/Specific/" + building_name + ".gd")
	if loaded_script == null:
		print(building_name)
		return null
	return loaded_script.new(coords)

func create_atlas_to_building():
	cargo_buildings = {}
	cargo_buildings[Vector2i(0, 0)] = "lumber_mill"
	cargo_buildings[Vector2i(1, 0)] = "woodcutter"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
