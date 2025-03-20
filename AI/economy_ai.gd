extends Node

var map := {}

var last_state: float
var id := 1
const CARGO_TYPE = 0

#Q - Table
var alpha = 0.1    # Learning rate
var epsilon = 0.1  # Exploration rate

#Set of States
var world_map: TileMapLayer
var tile_ownership: TileMapLayer
var cargo_map := terminal_map.cargo_map
var cargo_values = cargo_map.cargo_values
var rail_placer
var cargo_layer: TileMapLayer

#Just to test system
var num_mines = 0

#Set of Actions
enum ai_actions {
	PLACE_RAIL,
	PLACE_FACTORY,
	PLACE_STATION
}

func _init(_world_map: TileMapLayer, _tile_ownership: TileMapLayer): 
	world_map = _world_map
	rail_placer = world_map.rail_placer
	tile_ownership = _tile_ownership
	tile_ownership.add_player_to_color(id, Vector2i(113, -108))
	for tile in []:
		if terminal_map.get_terminal(tile) is apex_factory:
			build_town(tile)
	cargo_layer = cargo_values.get_layer(CARGO_TYPE)

func build_town(coords: Vector2i):
	map[coords] = 2

func process():
	var thread := Thread.new()
	thread.start(run_ai_cycle.bind())

func run_ai_cycle():
	var start: float = Time.get_ticks_msec()
	var action_type = get_type_of_action()
	
	var actions = get_valid_actions(action_type)
	var state = get_state()
	if actions.is_empty():
		return
	var action = choose_action(state, actions)
	var reward = get_reward()
	take_action(action)
		
	
	var end: float = Time.get_ticks_msec()
	print(str((end - start) / 1000) + " Seconds passed for one cycle")

func choose_action(state: Array, actions: Array):
	if randf() < epsilon:  # Explore
		return actions[randi() % actions.size()]
	return actions[0]

func get_type_of_action():
	if num_mines == 0:
		#Build mine
		return 1
	elif num_mines > 0:
		#Build rail
		return 2
	#Do Nothing
	return 0


func get_valid_actions(action_type) -> Array:
	var toReturn = []
	for tile in []:
		var action = get_encoded_action(tile, action_type)
		if !action.is_empty():
			toReturn.append(action)
	return toReturn

func get_magnitude(coords: Vector2i) -> int:
	var atlas := cargo_layer.get_cell_atlas_coords(coords)
	if atlas == Vector2i(-1, -1):
		return 0
	return atlas.y * 8 + atlas.x

func get_encoded_action(coords: Vector2i, action_type) -> Array:
	if map.has(coords) or action_type == 0:
		#Return nothing
		return []
	
	if get_magnitude(coords) > 0 and action_type == 1:
		#Returning mine
		return [coords.x, coords.y, 2]
	#Retutning rail
	return [coords.x, coords.y, 1]

func get_state() -> Array:
	var toReturn := []
	for tile in []:
		toReturn.append(get_encoded_vector(tile))
	return toReturn

func get_encoded_vector(coords: Vector2i) -> Array:
	var toReturn = []
	toReturn.append(coords.x)
	toReturn.append(coords.y)
	toReturn.append(0 if !map.has(coords) else map[coords])
	toReturn.append(get_magnitude(coords))
	return toReturn

func get_rail_state() -> float:
	var total := 0.0
	for tile: Vector2i in []:
		#Get amount of rails
		if map.has(tile) and map[tile] == 3:
			total -= 1
	return total

func get_town_state(type: int) -> float:
	var total := 0.0
	var towns := 0
	for tile: Vector2i in []:
		#Get Town Status
		if map.has(tile) and map[tile] == 2:
			total += get_town_fulfillment(tile)
	return total

func get_town_tiles() -> Array:
	return []

func get_town_fulfillment(coords: Vector2i) -> float:
	var demand = 5
	var supply = 0
	var queue = [coords]
	var visited = {}
	while !queue.is_empty():
		var current: Vector2i = queue.pop_front()
		if map.has(current) and map[current] == 1:
			supply += get_magnitude(coords)
			continue
		elif map.has(current) and map[current] == 2:
			demand += 5
		for tile in world_map.get_surrounding_cells(current):
			if !visited.has(tile) and map.has(current) and map[current] == 3:
				visited[tile] = 1
				queue.append(tile)
	return supply / demand * 5

func take_action(action):
	var coords = Vector2i(action[0], action[1])
	if action[2] == 2:
		build_mine(action[0], action[1])
	else:
		place_rail(coords)

func get_reward() -> float:
	return 0.0

func build_mine(x: int, y: int):
	cargo_map.create_factory(id, Vector2i(x, y))
	map[Vector2i(x, y)] = 1

func build_rail(x1: int, y1: int, x2: int, y2: int):
	place_to_end_rail(Vector2i(x1, y1), Vector2i(x2, y2))

func place_rail(coords: Vector2i):
	if !map.has(coords):
		rail_placer.place_tile(coords, 0, 0)
		map[coords] = 3

func place_to_end_rail(start: Vector2i, end: Vector2i):
	var queue = []
	var current: Vector2i
	var prev = null
	queue.push_back(start)
	while !queue.is_empty():
		current = queue.pop_front()
		place_rail(current)
		if current == end:
			break
		queue.push_back(find_tile_with_min_distance(world_map.get_surrounding_cells(current), end))

func find_tile_with_min_distance(tiles_to_check: Array[Vector2i], target_tile: Vector2i):
	var min_distance = 10000
	var to_return
	for cell in tiles_to_check:
		if cell.distance_to(target_tile) < min_distance:
			min_distance = cell.distance_to(target_tile)
			to_return = cell
	return to_return
