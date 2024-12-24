extends Node2D
@onready var rail_layer_0: TileMapLayer = $Rail_Layer_0
@onready var rail_layer_1: TileMapLayer = $Rail_Layer_1
@onready var rail_layer_2: TileMapLayer = $Rail_Layer_2
@onready var rail_layer_3: TileMapLayer = $Rail_Layer_3
@onready var rail_layer_4: TileMapLayer = $Rail_Layer_4
@onready var rail_layer_5: TileMapLayer = $Rail_Layer_5
var temp_layer_array = []
var orientation_vectors = [Vector2(0, 1), Vector2(sqrt(3)/2, 0.5), Vector2(sqrt(3)/2, -0.5), Vector2(0, -1), Vector2(-sqrt(3)/2, -0.5), Vector2(-sqrt(3)/2, 0.5)]
var orientation = 0
var type = -1
var old_coordinates
# Called when the node enters the scene tree for the first time.
func _ready():
	for item in get_children():
		if item.name.begins_with("Rail_Temp_Layer"):
			temp_layer_array.append(item)

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
