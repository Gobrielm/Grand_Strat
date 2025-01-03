extends TileMapLayer
var start = null
var unique_id
#Buttons
@onready var camera = $player_camera
@onready var track_button = $player_camera/CanvasLayer/track_button
@onready var station_button = $player_camera/CanvasLayer/station_button
@onready var depot_button = $player_camera/CanvasLayer/depot_button
@onready var single_track_button = $player_camera/CanvasLayer/single_track_button
@onready var tile_window = $tile_window
@onready var tile_info = $tile_window/tile_info
@onready var game = get_parent().get_parent()
@onready var rail_placer = $Rail_Placer
@onready var cargo_controller = $cargo_controller
var money_controller
const train_scene = preload("res://Cargo/Cargo_Objects/train.tscn")
const train_scene_client = preload('res://Client_Objects/client_train.tscn')
const depot = preload("res://Cargo/depot.gd")

var testing
# Called when the node enters the scene tree for the first time.
func _ready():
	unique_id = multiplayer.get_unique_id()
	if unique_id == 1:
		money_controller = preload("res://Player/money_controller.gd").new(multiplayer.get_peers())
		for cell in get_used_cells():
			rail_placer.init_track_connection.rpc(cell)
	testing = preload("res://Test/testing.gd").new(self)

func _input(event):
	update_hover()
	camera.update_coord_label(get_cell_position())
	if unique_id == 1:
		for id in get_money_of_all_players():
			update_money_label.rpc_id(id, get_money(id))
	if event.is_action_pressed("click"):
		record_start_rail()
		record_hover_click()
	elif event.is_action_released("click"):
		if camera.are_all_buttons_unpressed() and !tile_window.visible:
			tile_window.show_tile_info(get_cell_position())
		elif track_button.active:
			place_to_end_rail(start, get_cell_position())
		start = null
	elif event.is_action_pressed("deselect"):
		rail_placer.clear_all_temps()
		camera.unpress_all_buttons()
	elif event.is_action_pressed("debug_place_train"):
		create_train.rpc(get_cell_position())
	elif event.is_action_pressed("debug_print"):
		for i in 5:
			print(char(133))
		for coord in rail_placer.rail_graph.rail_vertices:
			print(coord)
			print(rail_placer.rail_graph.rail_vertices[coord].connections)
			print("-----")
		rail_placer.parse_entire_network(get_cell_position())
		

func _process(_delta):
	pass

func update_hover():
	if single_track_button.active:
		rail_placer.hover(get_cell_position(), 0, map_to_local(get_cell_position()), get_mouse_local_to_map())
	elif depot_button.active:
		rail_placer.hover(get_cell_position(), 1, map_to_local(get_cell_position()), get_mouse_local_to_map())
	elif station_button.active:
		rail_placer.hover(get_cell_position(), 2, map_to_local(get_cell_position()), get_mouse_local_to_map())
	elif start != null and track_button.active:
		get_rail_to_hover()

func record_hover_click():
	if !rail_placer.check_valid():
		return
	var coords = rail_placer.get_coordinates()
	var orientation = rail_placer.get_orientation()
	if single_track_button.active:
		rail_placer.place_hover()
		place_rail_general(coords, orientation, 0)
	elif depot_button.active:
		rail_placer.place_hover()
		place_rail_general(coords, orientation, 1)
	elif station_button.active:
		rail_placer.place_hover()
		place_rail_general(coords, orientation, 2)

#Cargo
func get_cargo_array() -> Array:
	return cargo_controller.get_cargo_array()

func is_location_depot(coords: Vector2i) -> bool:
	return tile_info.is_location_depot(coords)

func is_location_hold(coords: Vector2i) -> bool:
	return cargo_controller.is_location_hold(coords)

func get_depot_or_terminal(coords: Vector2i) -> terminal:
	var depot_to_return = tile_info.get_tile_metadata(coords)
	if depot_to_return != null and depot_to_return[0] == 1:
		return depot_to_return[2]
	return cargo_controller.get_terminal(coords)

#Trains
@rpc("any_peer", "reliable", "call_local")
func create_train(coords: Vector2i):
	var caller = multiplayer.get_remote_sender_id()
	if unique_id == 1:
		var train = train_scene.instantiate()
		train.name = "Train" + str(get_number_of_trains())
		add_child(train)
		train.create(coords, cargo_controller, caller)
	else:
		var train = train_scene_client.instantiate()
		train.name = "Train" + str(get_number_of_trains())
		add_child(train)
		train.create(coords)

func get_number_of_trains() -> int:
	var children = get_children()
	var count = 0
	for child in children:
		if child is Sprite2D:
			count += 1
	return count

#Rail Builder
func record_start_rail():
	start = get_cell_position()

func place_to_end_rail(new_start, new_end):
	start = new_start
	if start == null:
		return
	var end: Vector2i = new_end
	var queue = []
	
	var current: Vector2i
	var prev = null
	queue.push_back(start)
	while !queue.is_empty():
		current = queue.pop_front()
		if prev != null:
			var orientation = get_orientation(current, prev)
			if tile_info.can_place_here(get_cell_atlas_coords(current)):
				place_rail_general(current, orientation, 0)
			if tile_info.can_place_here(get_cell_atlas_coords(prev)):
				place_rail_general(prev, (orientation + 3) % 6, 0)
		if current == end:
			break
		queue.push_back(find_tile_with_min_distance(get_surrounding_cells(current), end))
		prev = current
	start = null

func get_rail_to_hover():
	var end : Vector2i = get_cell_position()
	var queue = []
	var toReturn = {}
	var current: Vector2i
	var prev = null
	queue.push_back(start)
	while !queue.is_empty():
		current = queue.pop_front()
		if prev != null:
			var orientation = get_orientation(current, prev)
			toReturn[current] = [Vector2i(orientation, 0)]
			if toReturn.has(prev):
				toReturn[prev].append(Vector2i((orientation + 3) % 6, 0))
			else:
				toReturn[prev] = [Vector2i((orientation + 3) % 6, 0)]
		if current == end:
			break
		queue.push_back(find_tile_with_min_distance(get_surrounding_cells(current), end))
		prev = current
	rail_placer.hover_many_tiles(toReturn)

func find_tile_with_min_distance(tiles_to_check: Array[Vector2i], target_tile: Vector2i):
	var min_distance = 10000
	var to_return
	for cell in tiles_to_check:
		if cell.distance_to(target_tile) < min_distance:
			min_distance = cell.distance_to(target_tile)
			to_return = cell
	return to_return

func get_orientation(current: Vector2i, prev: Vector2i):
	var difference = map_to_local(current) - map_to_local(prev)
	difference.y *= -1
	if (difference.x == 0 and difference.y < 0):
		return 0
	elif (difference.x == 0 and difference.y > 0):
		return 3
	elif (difference.y >= 0 and difference.x < 0):
		return 2
	elif (difference.y < 0 and difference.x > 0):
		return 5
	elif (difference.y >= 0 and difference.x > 0):
		return 4
	elif (difference.y < 0 and difference.x < 0):
		return 1
	return -1

#Map Functions
func get_cell_position():
	var cell_position = local_to_map(get_mouse_local_to_map())
	return cell_position

func get_mouse_local_to_map():
	var camera_pos = camera.position
	return camera_pos + get_mouse_local_to_camera()

func get_mouse_local_to_camera():
	var camera_middle = get_viewport_rect().size / 2
	var centered_at_top_left = get_viewport().get_mouse_position()
	var final = -camera_middle + centered_at_top_left
	return final / camera.zoom

#Money Stuff
func add_money_to_player(id: int, amount: int):
	money_controller.add_money_to_player(id, amount)

func get_money(id: int) -> int:
	return money_controller.get_money(id)

func get_money_of_all_players() -> Dictionary:
	return money_controller.get_money_dictionary()

@rpc("authority", "unreliable", "call_local")
func update_money_label(amount: int):
	camera.update_cash_label(amount)

#Tile Data
func get_tile_connections(coords: Vector2i):
	return rail_placer.get_track_connections(coords)

func request_tile_data(coordinates: Vector2i) -> TileData:
	return get_cell_tile_data(coordinates)

#Rail Graph System
func is_tile_vertex(coords: Vector2i) -> bool:
	return rail_placer.is_tile_vertex(coords)

func get_vertex(coords: Vector2i) -> rail_vertex:
	return rail_placer.get_vertex(coords)

func do_tiles_connect(coord1: Vector2i, coord2: Vector2i) -> bool:
	return rail_placer.are_tiles_connected_by_rail(coord1, coord2)
#Rail General
@rpc("authority", "call_local", "reliable")
func set_cell_rail_placer_server(coords: Vector2i, orientation: int, type: int, new_owner: int):
	rail_placer.place_tile(coords, orientation, type)
	if type == 1:
		encode_depot(coords)
	elif type == 2:
		encode_station(coords, new_owner)

func encode_depot(coords: Vector2i):
	tile_info.update_tile_metadata(coords, [1, "Depot", depot.new(coords, self)])

func encode_station(coords: Vector2i, new_owner: int):
	tile_info.update_tile_metadata(coords, [2, "Station"])
	cargo_controller.create_station(coords, new_owner)

@rpc("any_peer", "call_local", "unreliable")
func set_cell_rail_placer_request(coords: Vector2i, orientation: int, type: int):
	rail_placer.place_tile(coords, orientation, type)

#Rails, Depot, Station
func place_rail_general(coords: Vector2i, orientation: int, type: int):
	if unique_id == 1:
		set_cell_rail_placer_server.rpc(coords, orientation, type, unique_id)
	else:
		set_cell_rail_placer_request.rpc(coords, orientation, type)
	
