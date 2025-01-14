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
@onready var game = get_parent().get_parent()
@onready var rail_placer = $Rail_Placer
@onready var hold_window: Window = $hold_window
@onready var depot_window: Window = $depot_window
var tile_info
var cargo_controller
var unit_map
var money_controller
var state_machine
var untraversable_tiles = {}
var visible_tiles = []
var cargo_index_to_name = []
var tile_ownership: TileMapLayer

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
	state_machine = preload("res://Game/state_machine.gd").new()
	camera.assign_state_machine(state_machine)
	if unique_id == 1:
		
		create_untraversable_tiles()
		money_controller = load("res://Player/money_controller.gd").new(multiplayer.get_peers(), self)
		for peer in multiplayer.get_peers():
			heart_beat[peer] = 0
			update_money_label.rpc_id(peer, get_money(peer))
		update_money_label.rpc_id(1, get_money(1))
		unit_map = load("res://Map/unit_map.tscn").instantiate()
		add_child(unit_map)
		for cell in get_used_cells():
			rail_placer.init_track_connection.rpc(cell)
		testing = preload("res://Test/testing.gd").new(self)
		tile_info = load("res://tile_info.gd").new(self)
		create_client_tile_info.rpc(tile_info.get_cities())
		cargo_controller = load("res://Cargo/cargo_controller.tscn").instantiate()
		add_child(cargo_controller)
		create_cargo_index_to_name.rpc(cargo_controller.cargo_types)
		$player_camera/CanvasLayer/Desync_Label.visible = true
		tile_ownership = $tile_ownership
	else:
		unit_map = load("res://Client_Objects/client_unit_map.tscn").instantiate()
		unit_map.name = "unit_map"
		add_child(unit_map)
		for tile in get_used_cells():
			visible_tiles.append(tile)
		var node = get_node("tile_ownership")
		remove_child(node)
		node.queue_free()
		tile_ownership = load("res://Client_Objects/client_tile_ownership.tscn").instantiate()
		tile_ownership.name = "tile_ownership"
		add_child(tile_ownership)
	tile_ownership.prepare_refresh_tile_ownership.rpc_id(1)
	enable_nation_picker()

func _input(event):
	update_hover()
	camera.update_coord_label(get_cell_position())
	if event.is_action_pressed("click"):
		if state_machine.is_building():
			record_hover_click()
		elif state_machine.is_building_many_rails():
			record_start_rail()
		elif state_machine.is_building_units():
			create_unit(get_cell_position(), unit_creator_window.get_type_selected(), unique_id)
		elif state_machine.is_selecting_unit() and unit_map.is_unit_double_clicked(get_cell_position(), unique_id):
			show_unit_info_window(unit_map.get_unit_client_array(get_cell_position()))
		elif state_machine.is_picking_nation():
			pick_nation()
		else:
			unit_map.select_unit(get_cell_position(), unique_id)
	elif event.is_action_released("click"):
		if state_machine.is_controlling_camera() and tile_info.is_owned_hold(get_cell_position(), unique_id):
			hold_window.open_window(get_cell_position())
		elif state_machine.is_controlling_camera() and tile_info.is_owned_depot(get_cell_position(), unique_id):
			depot_window.open_window(get_cell_position())
		elif state_machine.is_building_many_rails():
			place_to_end_rail(start, get_cell_position())
		start = null
	elif event.is_action_pressed("deselect"):
		if state_machine.is_selecting_unit():
			unit_map.set_selected_unit_route(unit_map.get_selected_coords(), get_cell_position())
			unit_map.set_selected_unit_route.rpc_id(1, unit_map.get_selected_coords(), get_cell_position())
			update_info_window(unit_map.get_unit_client_array(unit_map.get_selected_coords()))
		else:
			rail_placer.clear_all_temps()
			camera.unpress_all_buttons()
	elif event.is_action_pressed("debug_place_train") and state_machine.is_controlling_camera():
		create_train.rpc(get_cell_position())
	elif event.is_action_pressed("debug_print") and state_machine.is_controlling_camera():
		unit_creator_window.popup()

#Constants
@rpc("authority", "call_local", "reliable")
func create_cargo_index_to_name(array: Array):
	cargo_index_to_name = array

func get_cargo_index_to_name() -> Array:
	return cargo_index_to_name

@rpc("authority", "call_remote", "reliable")
func create_client_tile_info(cities: Dictionary):
	tile_info = load("res://Client_Objects/client_tile_info.gd").new(self, cities)

#State_Machine
func click_unit():
	state_machine.click_unit()

func start_building_units():
	state_machine.start_building_units()

func is_controlling_camera() -> bool:
	return state_machine.is_controlling_camera()

#Tile_Ownership
func toggle_ownership_view():
	tile_ownership.visible = !tile_ownership.visible

func is_owned(player_id: int, coords: Vector2i) -> bool:
	return tile_ownership.is_owned(player_id, coords)

#Nation_Picker
func enable_nation_picker():
	print("A")
	camera.get_node("CanvasLayer").visible = false
	state_machine.start_picking_nation()
	print(state_machine.is_picking_nation())

func disable_nation_picker():
	camera.get_node("CanvasLayer").visible = true
	state_machine.stop_picking_nation()

func pick_nation():
	var coords = get_cell_position()
	tile_ownership.add_player_to_color.rpc_id(1, unique_id, coords)

#Units
func create_untraversable_tiles():
	untraversable_tiles[Vector2i(5, 0)] = 1
	untraversable_tiles[Vector2i(6, 0)] = 1
	untraversable_tiles[Vector2i(7, 0)] = 1
	untraversable_tiles[Vector2i(-1, -1)] = 1

func is_tile_traversable(tile_to_check: Vector2i) -> bool:
	var atlas_coords = get_cell_atlas_coords(tile_to_check)
	return !untraversable_tiles.has(atlas_coords)

func show_unit_info_window(unit_info_array: Array):
	$unit_info_window.show_unit(unit_info_array)

func update_info_window(unit_info_array: Array):
	$unit_info_window.update_unit(unit_info_array)

func create_unit(coords: Vector2i, type: int, id: int):
	unit_map.check_before_create.rpc_id(1, coords, type, id)

@rpc("authority", "call_remote", "unreliable")
func refresh_unit_map(unit_tiles: Dictionary):
	unit_map.refresh_map(visible_tiles, unit_tiles)

func close_unit_box():
	$unit_info_window.hide()

#Tracks
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

#Cargo
func get_cargo_array() -> Array:
	return cargo_controller.get_cargo_array()

func is_location_depot(coords: Vector2i) -> bool:
	return tile_info.is_depot(coords)

func is_location_hold(coords: Vector2i) -> bool:
	return cargo_controller.is_location_hold(coords)

func is_location_valid_stop(coords: Vector2i) -> bool:
	return tile_info.is_hold(coords) or tile_info.is_depot(coords)

@rpc("any_peer", "call_remote", "unreliable")
func get_cargo_array_at_location(coords: Vector2i) -> Dictionary:
	if cargo_controller.is_location_hold(coords):
		return cargo_controller.get_terminal(coords).get_current_hold()
	return {}

func get_depot_or_terminal(coords: Vector2i) -> terminal:
	var depot = tile_info.get_depot(coords)
	if depot != null:
		return depot
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

func get_trains_in_depot(coords: Vector2i) -> Array:
	if tile_info.is_depot(coords):
		return tile_info.get_depot(coords).get_trains_simplified()
	return []

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
			place_rail_general(current, orientation, 0)
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
func add_money_to_player(id: int, amount: int):
	money_controller.add_money_to_player(id, amount)

func remove_money(id: int, amount: int):
	money_controller.add_money_to_player(id, -amount)

func player_has_enough_money(id: int, amount: int) -> bool:
	return get_money(id) >= amount

func get_money(id: int) -> int:
	return money_controller.get_money(id)

func get_money_of_all_players() -> Dictionary:
	return money_controller.get_money_dictionary()

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
	return rail_placer.are_tiles_connected_by_rail(coord1, coord2)
#Rail General

@rpc("authority", "call_local", "unreliable")
func place_tile(coords: Vector2i, orientation: int, type: int, _new_owner: int):
	rail_placer.place_tile(coords, orientation, type)

func set_cell_rail_placer_request(coords: Vector2i, orientation: int, type: int, new_owner: int):
	set_cell_rail_placer_server.rpc_id(1, coords, orientation, type, unique_id)

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
			cargo_controller.create_station(coords, new_owner)
	else:
		rail_placer.clear_all_temps()

@rpc("authority", "call_local", "unreliable")
func encode_depot(coords: Vector2i, new_owner: int):
	tile_info.add_depot(coords, depot.new(coords, self), new_owner)
@rpc("authority", "call_remote", "unreliable")
func encode_depot_client(coords: Vector2i, depot_name: String, new_owner: int):
	tile_info.add_depot(coords, depot_name, new_owner)
@rpc("authority", "call_local", "unreliable")
func encode_station(coords: Vector2i, new_owner: int):
	tile_info.add_hold(coords, "Station", new_owner)

@rpc("any_peer", "call_local", "unreliable")
func set_cell_rail_placer_client(coords: Vector2i, orientation: int, type: int, new_owner: int):
	if type == 1:
		encode_depot(coords, new_owner)
	elif type == 2:
		encode_station(coords, new_owner)

#Rails, Depot, Station
func place_rail_general(coords: Vector2i, orientation: int, type: int):
	if unique_id == 1:
		set_cell_rail_placer_server(coords, orientation, type, unique_id)
	else:
		set_cell_rail_placer_request(coords, orientation, type, unique_id)
	
func rail_check(coords: Vector2i) -> bool:
	var atlas_coords = get_cell_atlas_coords(coords)
	return !untraversable_tiles.has(atlas_coords)
