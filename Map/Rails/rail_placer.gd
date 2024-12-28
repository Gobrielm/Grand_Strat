extends Node2D
@onready var rail_layer_0: TileMapLayer = $Rail_Layer_0
@onready var rail_layer_1: TileMapLayer = $Rail_Layer_1
@onready var rail_layer_2: TileMapLayer = $Rail_Layer_2
@onready var rail_layer_3: TileMapLayer = $Rail_Layer_3
@onready var rail_layer_4: TileMapLayer = $Rail_Layer_4
@onready var rail_layer_5: TileMapLayer = $Rail_Layer_5

var temp_layer_array = []
var track_connection: Dictionary = {}
var orientation_vectors = [Vector2(0, 1), Vector2(sqrt(3)/2, 0.5), Vector2(sqrt(3)/2, -0.5), Vector2(0, -1), Vector2(-sqrt(3)/2, -0.5), Vector2(-sqrt(3)/2, 0.5)]


var orientation = 0
var type = -1
var old_coordinates

@onready var map: TileMapLayer = get_parent()
var rail_graph: rail_graph_controller

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in get_children():
		if item.name.begins_with("Rail_Temp_Layer"):
			temp_layer_array.append(item)
	rail_graph = rail_graph_controller.new(map)

func hover_tile(coordinates: Vector2i, coords_middle: Vector2, coords_mouse: Vector2):
	delete_hover_rail()
	old_coordinates = coordinates
	var pointer: Vector2 = (coords_mouse - coords_middle).normalized()
	pointer.y *= -1
	var smallest_dist = 10000
	for index in orientation_vectors.size():
		var vector = orientation_vectors[index]
		var dist = abs(pointer.distance_to(vector))
		if dist < smallest_dist:
			smallest_dist = dist
			orientation = index
	if orientation == -1:
		return
	var temp_layer = get_temp_layer(orientation)
	temp_layer.set_cell(coordinates, 0, Vector2i(orientation, type))
	

func hover(coordinates: Vector2i, new_type: int, coords_middle: Vector2, coords_mouse: Vector2):
	type = new_type
	hover_tile(coordinates, coords_middle, coords_mouse)

func hover_many_tiles(tiles: Dictionary):
	clear_all_temps()
	for coords: Vector2i in tiles:
		for tile: Vector2i in tiles[coords]:
			var temp_layer = get_temp_layer(tile.x)
			temp_layer.set_cell(coords, 0, tile)

func clear_all_temps():
	for layer:TileMapLayer in temp_layer_array:
		layer.clear()

func place_tile(coords: Vector2i, new_orientation: int, new_type: int):
	var rail_layer: TileMapLayer = get_rail_layer(new_orientation)
	rail_layer.set_cell(coords, 0, Vector2i(new_orientation, new_type))
	add_track_connection(coords, new_orientation)
	if new_type == 0:
		place_rail(coords)
	elif new_type == 1:
		place_depot(coords)
	elif new_type == 2:
		place_station(coords)

func place_rail(coords: Vector2i):
	#Is vertex
	if get_total_connections(coords) > 2:
		if !rail_graph.is_tile_vertix(coords):
			rail_graph.add_rail_vertex(coords)
	elif get_total_connections(coords) == 2:
		var new_vertex = find_connected_existing_endpoint(coords)
		if !new_vertex == null:
			pass
			#Connecting two endpoints
	elif get_total_connections(coords) == 1:
		var other_endpoint = find_connected_existing_endpoint(coords)
		if other_endpoint == null:
			#New path from real vertex
			pass
		else:
			rail_graph.move_rail_vertex(other_endpoint, coords)

func find_bordering_non_existing_endpoint(coords: Vector2i):
	for cell in map.get_surrounding_cells(coords):
		if !rail_graph.is_tile_vertix(cell) and get_total_connections(cell) == 1 and are_tiles_connected_by_rail(coords, cell):
			return cell
	return null

func find_connected_existing_endpoint(coords: Vector2i):
	for cell in map.get_surrounding_cells(coords):
		if rail_graph.is_tile_vertix(cell) and get_total_connections(cell) == 1 and are_tiles_connected_by_rail(coords, cell):
			return cell
	return null

func get_total_connections(coords: Vector2i) -> int:
	var track_array = get_track_connections(coords)
	var total = 0
	for connected in track_array:
		if connected:
			total += 1
	return total

func place_depot(coords: Vector2i):
	rail_graph.add_rail_vertex(coords)

func place_station(coords: Vector2i):
	rail_graph.add_rail_vertex(coords)

func check_valid() -> bool:
	for layer in temp_layer_array:
		if layer.get_used_cells().size() > 0:
			return true
	return false

func place_hover():
	for layer in temp_layer_array:
		layer.clear()

func delete_hover_rail():
	if old_coordinates != null and orientation != null:
		var temp_layer = get_temp_layer(orientation)
		temp_layer.erase_cell(old_coordinates)

func get_orientation():
	return orientation

func get_coordinates():
	return old_coordinates

func get_rail_layer(curr_orientation):
	if curr_orientation == 0:
		return rail_layer_0
	elif curr_orientation == 1:
		return rail_layer_1
	elif curr_orientation == 2:
		return rail_layer_2
	elif curr_orientation == 3:
		return rail_layer_3
	elif curr_orientation == 4:
		return rail_layer_4
	elif curr_orientation == 5:
		return rail_layer_5

func get_temp_layer(curr_orientation: int):
	if curr_orientation >= 0 and curr_orientation < 6:
		return temp_layer_array[curr_orientation]

@rpc("authority", "call_local", "reliable")
func init_track_connection(coords: Vector2i):
	track_connection[coords] = [false, false, false, false, false, false]
@rpc("authority", "call_local", "reliable")
func add_track_connection(coords: Vector2i, orientation):
	if !track_connection.has(coords):
		init_track_connection(coords)
	track_connection[coords][orientation] = true
@rpc("authority", "call_local", "reliable")
func delete_track_connection(coords: Vector2i, orientation):
	track_connection[coords][orientation] = false
func get_track_connections(coords: Vector2i) -> Array:
	if track_connection.has(coords):
		return track_connection[coords]
	else:
		return [false, false, false, false, false, false]

func are_tiles_connected_by_rail(coord1: Vector2i, coord2: Vector2i) -> bool:
	var track_connections1 = get_track_connections(coord1)
	var track_connections2 = get_track_connections(coord2)
	var bordering_cells = map.get_surrounding_cells(coord1)
	for direction in bordering_cells.size():
		var real_direction = (direction + 4) % 6
		if bordering_cells[real_direction] == coord2:
			return track_connections1[real_direction] and track_connections2[(real_direction + 3) % 6]
	return false
