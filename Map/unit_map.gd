extends TileMapLayer

var map: TileMapLayer
var unit_creator
var unit_data: Dictionary = {}
var labels: Dictionary = {}
var unit_selected_coords: Vector2i
func _ready():
	unit_creator = load("res://Units/unit_managers/unit_creator.gd").new()
	map = get_parent()

func tile_has_no_unit(tile_to_check: Vector2i) -> bool:
	return !unit_data.has(tile_to_check)

func is_player_id_match(coords: Vector2i, player_id: int) -> bool:
	return unit_data.has(coords) and unit_data[coords].get_player_id() == player_id

#Creating Units
@rpc("any_peer", "call_remote", "unreliable")
func create_unit(coords: Vector2i, type, player_id: int):
	set_cell(coords, 1, Vector2i(0, unit_creator.get_y_atlas_from_unit_type(type)))
	unit_data[coords] = type.new(coords, player_id)
	create_label(coords, str(unit_data[coords]))

func create_label(coords: Vector2i, text: String):
	var label: Label = Label.new()
	add_child(label)
	label.text = text
	label.position = map_to_local(coords)
	label.position.x -= (label.size.x / 2)
	label.position.y += label.size.y
	labels[coords] = label

#Moving Units
func set_selected_unit_route(move_to: Vector2i):
	if unit_data.has(unit_selected_coords):
		var soldier_data: base_unit = unit_data[unit_selected_coords]
		soldier_data.set_route(dfs_to_destination(unit_selected_coords, move_to))
	

func move_unit(coords: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(coords)
	var soldier_data: base_unit = unit_data[coords]
	var move_to = soldier_data.pop_next_location()
	if next_location_is_available(move_to):
		soldier_data.set_location(move_to)
		erase_cell(coords)
		set_cell(move_to, 1, soldier_atlas)
		unit_data.erase(coords)
		unit_data[move_to] = soldier_data
		unit_selected_coords = move_to
		move_label(coords, move_to)
	elif !soldier_data.is_route_empty():
		var end = soldier_data.get_destination()
		set_selected_unit_route(end)

func next_location_is_available(coords: Vector2i) -> bool:
	return !unit_data.has(coords)

func dfs_to_destination(coords: Vector2i, destination: Vector2i) -> Array:
	var current
	var queue: priority_queue = priority_queue.new()
	var tile_to_prev = {}
	var visited = {}
	queue.add_item(0, coords)
	while !queue.is_empty():
		current = queue.pop_top()
		if current == destination:
			break
		for tile in map.get_surrounding_cells(current):
			if !visited.has(tile) and map.is_tile_traversable(tile) and tile_has_no_unit(tile):
				queue.add_item(tile.distance_to(destination), tile)
				visited[tile] = true
				tile_to_prev[tile] = current
	return create_route_from_tile_to_prev(coords, destination, tile_to_prev)
	
func create_route_from_tile_to_prev(start: Vector2i, destination: Vector2i, tile_to_prev: Dictionary) -> Array:
	var current = destination
	var route = []
	while current != start:
		route.push_front(current)
		current = tile_to_prev[current]
	return route


func move_label(coords: Vector2i, move_to: Vector2i):
	var label = labels[coords]
	labels.erase(coords)
	labels[move_to] = label
	label.position = map_to_local(move_to)
	label.position.x -= (label.size.x / 2)
	label.position.y += label.size.y

#Selecting Units
func select_unit(coords: Vector2i, player_id: int):
	if is_player_id_match(coords, player_id):
		var soldier_atlas = get_cell_atlas_coords(coords)
		unit_selected_coords = coords
		if soldier_atlas != Vector2i(-1, -1):
			map.click_unit()

func _process(delta):
	for location: Vector2i in unit_data:
		var unit: base_unit = unit_data[location]
		unit.update_progress(delta)
		if unit.get_next_location() != location:
			#TODO: Terrain check
			if unit.ready_to_move(100 / unit.get_speed()):
				move_unit(location)
			
