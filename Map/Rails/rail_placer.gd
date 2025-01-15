extends Node2D
@onready var rail_layer_0: TileMapLayer = $Rail_Layer_0
@onready var rail_layer_1: TileMapLayer = $Rail_Layer_1
@onready var rail_layer_2: TileMapLayer = $Rail_Layer_2
@onready var rail_layer_3: TileMapLayer = $Rail_Layer_3
@onready var rail_layer_4: TileMapLayer = $Rail_Layer_4
@onready var rail_layer_5: TileMapLayer = $Rail_Layer_5

var state_machine

var temp_layer_array = []
var track_connection: Dictionary = {}
var orientation_vectors = [Vector2(0, 1), Vector2(sqrt(3)/2, 0.5), Vector2(sqrt(3)/2, -0.5), Vector2(0, -1), Vector2(-sqrt(3)/2, -0.5), Vector2(-sqrt(3)/2, 0.5)]

var orientation = 0
var type = -1
var old_coordinates

func _ready():
	for item in get_children():
		if item.name.begins_with("Rail_Temp_Layer"):
			temp_layer_array.append(item)

func assign_state_machine(new_state_machine):
	state_machine = new_state_machine

func get_rail_layers() -> Array:
	var toReturn = []
	for item in get_children():
		if item.name.begins_with("Rail_Layer"):
			toReturn.append(item)
	return toReturn

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

func clear_all_real():
	track_connection.clear()
	for layer: TileMapLayer in get_children():
		if layer.name.begins_with("Rail_Layer"):
			layer.clear()

func clear_all_temps():
	for layer: TileMapLayer in temp_layer_array:
		layer.clear()

func place_tile(coords: Vector2i, new_orientation: int, new_type: int):
	if is_already_built(coords, new_orientation):
		return
	var rail_layer: TileMapLayer = get_rail_layer(new_orientation)
	rail_layer.set_cell(coords, 0, Vector2i(new_orientation, new_type))
	add_track_connection(coords, new_orientation)

func is_already_built(coords: Vector2i, new_orientation: int) -> bool:
	var rail_layer: TileMapLayer = get_rail_layer(new_orientation)
	return rail_layer.get_cell_atlas_coords(coords).x == new_orientation

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
func add_track_connection(coords: Vector2i, new_orientation: int):
	if !track_connection.has(coords):
		init_track_connection(coords)
	track_connection[coords][new_orientation] = true
@rpc("authority", "call_local", "reliable")
func delete_track_connection(coords: Vector2i, new_orientation: int):
	track_connection[coords][new_orientation] = false
func get_track_connections(coords: Vector2i) -> Array:
	if track_connection.has(coords):
		return track_connection[coords]
	else:
		return [false, false, false, false, false, false]
func get_depot_direction(coords: Vector2i) -> int:
	for rail_layer: TileMapLayer in get_rail_layers():
		var atlas = rail_layer.get_cell_atlas_coords(coords)
		if atlas.y == 1:
			return atlas.x
	return -1


func are_tiles_connected_by_rail(coord1: Vector2i, coord2: Vector2i, bordering_to_coord1: Array) -> bool:
	var track_connections1 = get_track_connections(coord1)
	var track_connections2 = get_track_connections(coord2)
	for direction in bordering_to_coord1.size():
		var real_direction = (direction + 2) % 6
		if bordering_to_coord1[direction] == coord2:
			return track_connections1[real_direction] and track_connections2[(real_direction + 3) % 6]
	return false
