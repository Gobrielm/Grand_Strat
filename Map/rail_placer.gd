extends Node2D
@onready var rail_layer_0: TileMapLayer = $Rail_Layer_0
@onready var rail_layer_1: TileMapLayer = $Rail_Layer_1
@onready var rail_layer_2: TileMapLayer = $Rail_Layer_2
@onready var rail_layer_3: TileMapLayer = $Rail_Layer_3
@onready var rail_layer_4: TileMapLayer = $Rail_Layer_4
@onready var rail_layer_5: TileMapLayer = $Rail_Layer_5
var orientation = 0
var type = -1
var old_orientation
var old_coordinates
var old_type
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("rotate"):
		increment_orientation()

func hover_tile(coordinates: Vector2i):
	if old_coordinates != null and old_orientation != null:
		delete_hover_rail()
		re_place_old_tile()
	var rail_layer: TileMapLayer = get_rail_layer(orientation)
	#Get data of tile hovering over
	if rail_layer.get_cell_source_id(coordinates) == -1:
		old_type = -1
	else:
		old_type = rail_layer.get_cell_atlas_coords(coordinates).y
	
	old_orientation = orientation
	old_coordinates = coordinates
	
	rail_layer.set_cell(coordinates, 0, Vector2i(orientation, type))

func hover(coordinates: Vector2i, new_type: int):
	type = new_type
	hover_tile(coordinates)

func place_tile(coords: Vector2i, new_orientation: int, new_type: int):
	var rail_layer: TileMapLayer = get_rail_layer(new_orientation)
	rail_layer.set_cell(coords, 0, Vector2i(new_orientation, new_type))

func check_valid() -> bool:
	return old_coordinates != null or old_orientation != null

func place_hover():
	old_orientation = null
	old_coordinates = null
	type = -1

func delete_hover_rail():
	if old_coordinates != null and old_orientation != null:
		var old_rail_layer: TileMapLayer = get_rail_layer(old_orientation)
		old_rail_layer.erase_cell(old_coordinates)

func re_place_old_tile():
	if old_coordinates != null and old_orientation != null and old_type != -1:
		place_tile(old_coordinates, old_orientation, old_type)
	

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


func increment_orientation():
	orientation += 1
	orientation = orientation % 6

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
