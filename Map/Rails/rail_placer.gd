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

@onready var map = get_parent()
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
	if get_total_connections(get_track_connections(coords)) > 2:
		rail_graph.add_rail_vertex(coords)

func get_total_connections(track_array: Array) -> int:
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
