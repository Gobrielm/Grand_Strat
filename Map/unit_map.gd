extends TileMapLayer

var map: TileMapLayer
var unit_data: Dictionary = {}
var unit_selected: Vector2i
func _ready():
	map = get_parent()

@rpc("any_peer", "call_remote", "unreliable")
func create_unit(coords: Vector2i):
	set_cell(coords, 1, Vector2i(0, 0))
	var label: Label = Label.new()
	add_child(label)
	unit_data[coords] = infantry.new()
	label.text = "infantry"
	var label_position = map_to_local(coords)
	label.position = label_position
	label_position.x -= (label.size.x / 2)
	label_position.y += label.size.y
	label.position = label_position
	
	
	
func move_selected_unit(move_to: Vector2i):
	move_unit(unit_selected, move_to)

func move_unit(coords: Vector2i, move_to: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(coords)
	var soldier_data = unit_data[coords]
	erase_cell(coords)
	set_cell(move_to, 1, soldier_atlas)
	unit_data.erase(coords)
	unit_data[move_to] = soldier_data
	unit_selected = move_to
	
	var label_position = map_to_local(coords)
	#label_position.x -= (label.size.x / 2)
	#label_position.y += label.size.y
	#label.position = label_position

func select_unit(coords: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(coords)
	if soldier_atlas != Vector2i(-1, -1):
		map.click_unit()
		unit_selected = coords

func select_tile(coords: Vector2i):
	var light = DirectionalLight2D.new()
	add_child(light)
	light.position = local_to_map(coords)

func _process(delta):
	pass
