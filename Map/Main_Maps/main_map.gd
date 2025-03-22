extends TileMapLayer
var start = null
var unique_id
#Buttons
@onready var camera = $player_camera
@onready var track_button = $player_camera/CanvasLayer/track_button
@onready var station_button = $player_camera/CanvasLayer/station_button
@onready var depot_button = $player_camera/CanvasLayer/depot_button
@onready var single_track_button = $player_camera/CanvasLayer/single_track_button
@onready var unit_creator_window = $unit_creator_window
@onready var tile_window := $tile_window
@onready var game = get_parent().get_parent()
@onready var rail_placer = $Rail_Placer
@onready var map_node = get_parent()
var tile_info
var unit_map
var money_interface
var untraversable_tiles = {}
var visible_tiles = []

const train_scene = preload("res://Cargo/Cargo_Objects/train.tscn")
const train_scene_client = preload('res://Client_Objects/client_train.tscn')
const depot = preload("res://Cargo/depot.gd")

var testing

var heart_beat = {}


func _on_timer_timeout():
	if unique_id == 1:
		for peer in multiplayer.get_peers():
			if heart_beat[peer] != 0:
				camera.update_desync_label(heart_beat[peer])
			heart_beat[peer] += 1
		server_heart_beat()

func server_heart_beat():
	send_heart_beat.rpc()

@rpc("authority", "call_remote", "unreliable")
func send_heart_beat():
	recognize_heart_beat.rpc_id(1)

@rpc("any_peer", "call_remote", "unreliable")
func recognize_heart_beat():
	heart_beat[multiplayer.get_remote_sender_id()] -= 1

func _ready():
	unique_id = multiplayer.get_unique_id()
	if unique_id == 1:
		create_untraversable_tiles()
		money_interface = money_controller.new(multiplayer.get_peers(), self)
		for peer in multiplayer.get_peers():
			heart_beat[peer] = 0
			update_money_label.rpc_id(peer, get_money(peer))
		update_money_label.rpc_id(1, get_money(1))
		unit_map = load("res://Map/unit_map.tscn").instantiate()
		add_child(unit_map)
		for cell in get_used_cells():
			rail_placer.init_track_connection.rpc(cell)
		tile_info = load("res://Map/tile_info.gd").new(self)
		create_client_tile_info.rpc(self)
		var cargo_controller = load("res://Cargo/cargo_controller.tscn").instantiate()
		cargo_controller.assign_map_node(map_node)
		add_child(cargo_controller)
		terminal_map.create(self)
		recipe.create_set_recipes()
		$player_camera/CanvasLayer/Desync_Label.visible = true
		testing = preload("res://Test/testing.gd").new(self)
	else:
		unit_map = load("res://Client_Objects/client_unit_map.tscn").instantiate()
		unit_map.name = "unit_map"
		add_child(unit_map)
		for tile in get_used_cells():
			visible_tiles.append(tile)
	

#Constants
@rpc("authority", "call_remote", "reliable")
func create_client_tile_info(cities: Dictionary):
	tile_info = load("res://Client_Objects/client_tile_info.gd").new(self, cities)

func is_owned(player_id: int, coords: Vector2i) -> bool:
	return map_node.is_owned(player_id, coords)

func start_building_units():
	state_machine.start_building_units()

func is_controlling_camera() -> bool:
	return state_machine.is_controlling_camera()


#Units
func create_untraversable_tiles():
	untraversable_tiles[Vector2i(5, 0)] = 1
	untraversable_tiles[Vector2i(6, 0)] = 1
	untraversable_tiles[Vector2i(7, 0)] = 1
	untraversable_tiles[Vector2i(-1, -1)] = 1

func is_tile_traversable(tile_to_check: Vector2i) -> bool:
	var atlas_coords = get_cell_atlas_coords(tile_to_check)
	return !untraversable_tiles.has(atlas_coords)

func show_unit_info_window():
	var unit_info_array = unit_map.get_unit_client_array(get_cell_position())
	$unit_info_window.show_unit(unit_info_array)

func update_info_window(unit_info_array: Array):
	$unit_info_window.update_unit(unit_info_array)

func create_unit():
	unit_map.check_before_create.rpc_id(1, get_cell_position(), unit_creator_window.get_type_selected(), unique_id)

@rpc("authority", "call_remote", "unreliable")
func refresh_unit_map(unit_tiles: Dictionary):
	unit_map.refresh_map(visible_tiles, unit_tiles)

func close_unit_box():
	$unit_info_window.hide()

func is_unit_double_clicked() -> bool:
	return unit_map.is_unit_double_clicked(get_cell_position(), unique_id)

#Tracks
func get_rail_type_selected() -> int:
	if single_track_button.active:
		return 0
	elif depot_button.active:
		return 1
	elif station_button.active:
		return 2
	return 3

func clear_all_temps():
	rail_placer.clear_all_temps()

func update_hover():
	var rail_type = get_rail_type_selected()
	if get_rail_type_selected() < 3:
		rail_placer.hover(get_cell_position(), rail_type, map_to_local(get_cell_position()), get_mouse_local_to_map())
	elif start != null and track_button.active:
		get_rail_to_hover()

func record_hover_click():
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

func get_depot_direction(coords: Vector2i) -> int:
	return rail_placer.get_depot_direction(coords)

func place_road_depot():
	if !state_machine.is_hovering_over_gui():
		rail_placer.place_road_depot(get_cell_position(), unique_id)

#Cargo
func is_depot(coords: Vector2i) -> bool:
	return tile_info.is_depot(coords)

func is_owned_depot(coords: Vector2i) -> bool:
	return tile_info.is_owned_depot(coords, unique_id)

func is_hold(coords: Vector2i) -> bool:
	return terminal_map.is_hold(coords)

func is_owned_hold(coords: Vector2i) -> bool:
	return tile_info.is_owned_hold(coords, unique_id)

func is_factory(coords: Vector2i) -> bool:
	return terminal_map.is_factory(coords)

func is_owned_station(coords: Vector2i) -> bool:
	return terminal_map.is_station(coords)

func is_location_valid_stop(coords: Vector2i) -> bool:
	return tile_info.is_hold(coords) or tile_info.is_depot(coords)

func get_depot_or_terminal(coords: Vector2i) -> terminal:
	var new_depot = tile_info.get_depot(coords)
	if new_depot != null:
		return new_depot
	return terminal_map.get_terminal(coords)

#Trains
@rpc("any_peer", "reliable", "call_local")
func create_train(coords: Vector2i):
	var caller = multiplayer.get_remote_sender_id()
	if unique_id == 1:
		var train = train_scene.instantiate()
		train.name = "Train" + str(get_number_of_trains())
		add_child(train)
		train.create(coords, caller)
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

func get_trains_in_depot(coords: Vector2i) -> Array:
	if tile_info.is_depot(coords):
		return tile_info.get_depot(coords).get_trains_simplified()
	return []

#Rail Builder
func record_start_rail():
	start = get_cell_position()

func reset_start():
	start = null

func place_rail_to_start():
	place_to_end_rail(start, get_cell_position())

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
			place_rail_general(current, orientation, 0)
			place_rail_general(prev, (orientation + 3) % 6, 0)
		if current == end:
			break
		queue.push_back(find_tile_with_min_distance(get_surrounding_cells(current), end))
		prev = current
	start = null

func get_rail_to_hover():
	var end : Vector2i = get_cell_position()
	var toReturn = get_rails_from(start, end)
	rail_placer.hover_many_tiles(toReturn)

func get_rails_from(begin: Vector2i, end: Vector2i) -> Dictionary:
	var queue = []
	var toReturn = {}
	var current: Vector2i
	var prev = null
	queue.push_back(begin)
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
	return toReturn

func find_tile_with_min_distance(tiles_to_check: Array[Vector2i], target_tile: Vector2i):
	var min_distance = 10000
	var to_return
	for cell in tiles_to_check:
		if cell.distance_to(target_tile) < min_distance:
			min_distance = cell.distance_to(target_tile)
			to_return = cell
	return to_return

func debug() -> Dictionary:
	var dict := get_rails_to_build(Vector2i(100, -115), 0, get_cell_position(), 0)
	for tile in dict:
		for orientation: int in dict[tile]:
			rail_placer.hover_debug(tile, orientation)
	return dict

func get_rails_to_build(from: Vector2i, starting_orientation: int, to: Vector2i, ending_orientation: int) -> Dictionary:
	var queue := [from]
	var tile_to_prev := {} # Vector2i -> Array[Tile for each direction]
	var order := {} # Vector2i -> Array[indices in order for tile_to_prev, first one is the fastest]
	var visited := {} # Vector2i -> Array[Bool for each direction]
	visited[from] = [false, false, false, false, false, false]
	visited[from][swap_direction(starting_orientation)] = true
	visited[from][(starting_orientation)] = true
	
	#Used to only allow the top and bottom of the station to connect
	var check = [null, null, null, null, null, null]
	var surrounding = get_surrounding_cells(from)
	check[(starting_orientation + 3) % 6] = (surrounding[(starting_orientation + 1) % 6])
	check[starting_orientation] = (surrounding[(starting_orientation + 4) % 6])
	
	var found = false
	var curr: Vector2i
	while !queue.is_empty() and !found:
		curr = queue.pop_front()
		var cells_to_check = get_cells_in_front(curr, visited[curr])
		if curr == from:
			cells_to_check = check
		for direction in cells_to_check.size():
			var cell = cells_to_check[direction]
			if cell == to and (direction == ending_orientation or direction == swap_direction(ending_orientation)):
				intialize_visited(visited, cell, direction)
				intialize_order(order, cell, direction)
				intialize_tile_to_prev(tile_to_prev, cell, direction, curr)
				found = true
				break
			elif cell != null and !check_visited(visited, cell, direction) and Utils.is_tile_open(cell, unique_id):
				intialize_visited(visited, cell, direction)
				intialize_order(order, cell, direction)
				intialize_tile_to_prev(tile_to_prev, cell, direction, curr)
				queue.append(cell)
	
	var toReturn := {}
	var direction = null
	var prev = null
	if found:
		var index = 0
		while direction != ending_orientation and direction != ((ending_orientation + 3) % 6):
			direction = order[to][index]
			index += 1
		curr = tile_to_prev[to][direction]
		found = false
		while !found:
			if prev != null:
				toReturn[prev].append((direction + 3) % 6)
			if curr == from and (can_direction_reach_dir(direction, swap_direction(starting_orientation)) or can_direction_reach_dir(direction, starting_orientation)):
				break
			toReturn[curr] = [direction]
			for dir in order[curr]:
				if can_direction_reach_dir(direction, dir) and tile_to_prev[curr][dir] != null:
					prev = curr
					curr = tile_to_prev[curr][dir]
					direction = dir
					break
	
	return toReturn

func can_direction_reach_dir(direction: int, dir: int) -> bool:
	return dir == direction or dir == (direction + 1) % 6 or dir == (direction + 5) % 6

func at_odd_angle(station_orientation: int, rail_orientation: int) -> bool:
	return rail_orientation == (station_orientation + 1) % 6 or rail_orientation == (station_orientation + 5) % 6

func swap_direction(num: int) -> int: 
	return (num + 3) % 6

func get_cells_in_front(coords: Vector2i, directions: Array) -> Array:
	var index = 2
	var toReturn = [null, null, null, null, null, null]
	for cell in get_surrounding_cells(coords):
		if directions[index] or directions[(index + 1) % 6] or directions[(index + 5) % 6] and !terminal_map.is_tile_taken(cell):
			toReturn[index] = cell
		index = (index + 1) % 6
	return toReturn

func check_visited(visited: Dictionary, coords: Vector2i, direction: int) -> bool:
	if visited.has(coords):
		return visited[coords][direction]
	return false

func intialize_visited(visited: Dictionary, coords: Vector2i, direction: int):
	if !visited.has(coords):
		visited[coords] = [false, false, false, false, false, false]
	visited[coords][direction] = true

func intialize_tile_to_prev(tile_to_prev: Dictionary, coords: Vector2i, direction: int, prev: Vector2i):
	if !tile_to_prev.has(coords):
		tile_to_prev[coords] = [null, null, null, null, null, null]
	tile_to_prev[coords][direction] = prev

func intialize_order(order: Dictionary, coords: Vector2i, direction: int):
	if !order.has(coords):
		order[coords] = []
	order[coords].append(direction)





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
	assert(false)
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

func get_biome_name(coords: Vector2i) -> String:
	var biome_name := ""
	if is_desert(coords):
		biome_name += "Desert"
	elif is_tundra(coords):
		biome_name += "Tundra"
	elif is_dry(coords):
		biome_name += "Grasslands"
	elif is_water(coords):
		biome_name += "Ocean"
	else:
		biome_name += "Meadow"
	
	if is_forested(coords):
		biome_name += " Forest"
	
	if is_hilly(coords):
		biome_name += " Hills"
	elif is_mountainous(coords):
		if is_desert(coords):
			biome_name = "Desert Mountains"
		else:
			biome_name = "Mountains"
	return biome_name

func is_forested(coords: Vector2i) -> bool:
	var atlas = get_cell_atlas_coords(coords)
	if (atlas.y >= 0 and atlas.y <= 2) and (atlas.x == 1 or atlas.x == 2 or atlas.x == 4):
		return true
	return false

func is_hilly(coords: Vector2i) -> bool:
	var atlas = get_cell_atlas_coords(coords)
	if (atlas == Vector2i(3, 0) or atlas == Vector2i(4, 0) or atlas == Vector2i(5, 1) or atlas == Vector2i(3, 2) or atlas == Vector2i(4, 2) or atlas == Vector2i(1, 3)):
		return true
	return false

func is_mountainous(coords: Vector2i) -> bool:
	var atlas = get_cell_atlas_coords(coords)
	if (atlas == Vector2i(5, 0) or atlas == Vector2i(3, 3)):
		return true
	return false

func is_desert(coords: Vector2i) -> bool:
	var atlas = get_cell_atlas_coords(coords)
	if (atlas.y == 3):
		return true
	return false

func is_tundra(coords: Vector2i) -> bool:
	var atlas = get_cell_atlas_coords(coords)
	if (atlas.y == 2):
		return true
	return false

func is_water(coords: Vector2i) -> bool:
	var atlas = get_cell_atlas_coords(coords)
	if (atlas.y == 0 and atlas.x >= 6):
		return true
	return false

func is_dry(coords: Vector2i) -> bool:
	var atlas = get_cell_atlas_coords(coords)
	if (atlas.y == 1):
		return true
	return false

#Tile Effects
func highlight_cell(coords: Vector2i):
	clear_highlights()
	var highlight: Sprite2D = Sprite2D.new()
	highlight.texture = load("res://Map_Icons/selected.png")
	add_child(highlight)
	highlight.name = "highlight"
	highlight.position = map_to_local(coords)

func clear_highlights():
	if has_node("highlight"):
		var node: Sprite2D = get_node("highlight")
		remove_child(node)
		node.queue_free()

#Money Stuff
func get_cash_of_firm(coords: Vector2i) -> int:
	return terminal_map.get_cash_of_firm(coords)

func add_money_to_player(id: int, amount: int):
	money_interface.add_money_to_player(id, amount)

func remove_money(id: int, amount: int):
	money_interface.add_money_to_player(id, -amount)

func player_has_enough_money(id: int, amount: int) -> bool:
	return get_money(id) >= amount

func get_money(id: int) -> int:
	return money_interface.get_money(id)

func get_money_of_all_players() -> Dictionary:
	return money_interface.get_money_dictionary()

@rpc("authority", "unreliable", "call_local")
func update_money_label(amount: int):
	camera.update_cash_label(amount)

#Tile Data
func get_tile_data():
	return tile_info

func get_tile_connections(coords: Vector2i):
	return rail_placer.get_track_connections(coords)

func request_tile_data(coordinates: Vector2i) -> TileData:
	return get_cell_tile_data(coordinates)

func do_tiles_connect(coord1: Vector2i, coord2: Vector2i) -> bool:
	return rail_placer.are_tiles_connected_by_rail(coord1, coord2, get_surrounding_cells(coord1))

func open_tile_window(coords: Vector2i):
	if !is_water(coords):
		tile_window.open_window(coords)
	else:
		tile_window.hide()

#Rail General
@rpc("authority", "call_local", "unreliable")
func place_tile(coords: Vector2i, orientation: int, type: int, _new_owner: int):
	rail_placer.place_tile(coords, orientation, type)

func set_cell_rail_placer_request(coords: Vector2i, orientation: int, type: int, new_owner: int):
	set_cell_rail_placer_server.rpc_id(1, coords, orientation, type, new_owner)

@rpc("any_peer", "call_remote", "unreliable")
func set_cell_rail_placer_server(coords: Vector2i, orientation: int, type: int, new_owner: int):
	if rail_check(coords) and is_owned(new_owner, coords):
		place_tile.rpc(coords, orientation, type, new_owner)
		if type == 1:
			encode_depot(coords, new_owner)
			var depot_name = tile_info.get_depot_name(coords)
			encode_depot_client.rpc(coords, depot_name, new_owner)
		elif type == 2:
			encode_station.rpc(coords, new_owner)
			terminal_map.create_station(coords, new_owner)
	else:
		rail_placer.clear_all_temps()

@rpc("authority", "call_local", "unreliable")
func encode_depot(coords: Vector2i, new_owner: int):
	tile_info.add_depot(coords, depot.new(coords, new_owner, self), new_owner)
@rpc("authority", "call_remote", "unreliable")
func encode_depot_client(coords: Vector2i, depot_name: String, new_owner: int):
	tile_info.add_depot(coords, depot_name, new_owner)
@rpc("authority", "call_local", "unreliable")
func encode_station(coords: Vector2i, new_owner: int):
	tile_info.add_hold(coords, "Station", new_owner)

#Rails, Depot, Station
func place_rail_general(coords: Vector2i, orientation: int, type: int):
	if unique_id == 1:
		set_cell_rail_placer_server(coords, orientation, type, unique_id)
	else:
		set_cell_rail_placer_request(coords, orientation, type, unique_id)
	
func rail_check(coords: Vector2i) -> bool:
	var atlas_coords = get_cell_atlas_coords(coords)
	return !untraversable_tiles.has(atlas_coords)
