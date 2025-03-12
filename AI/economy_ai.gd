extends Node

var map := {}

var last_state: float
var id := 1
const CARGO_TYPE = 0
var available_tiles = []

#Q - Table
var q_table = {}  # Stores Q-values as a dictionary { "state_action": value }
var alpha = 0.1    # Learning rate
var gamma = 0.9    # Discount factor
var epsilon = 0.1  # Exploration rate

#Set of States
var world_map: TileMapLayer
var tile_ownership: TileMapLayer
var cargo_map := terminal_map.cargo_map
var cargo_values = cargo_map.cargo_values
var rail_placer
var cargo_layer: TileMapLayer

#Set of Actions
enum ai_actions {
	PLACE_RAIL,
	PLACE_FACTORY,
	PLACE_STATION
}

#Files
var statesOutput := "res://AI/AI_Data/state_outputs.csv"
var rewardOutput := "res://AI/AI_Data/rewards.csv"

func _init(_world_map: TileMapLayer, _tile_ownership: TileMapLayer): 
	world_map = _world_map
	rail_placer = world_map.rail_placer
	tile_ownership = _tile_ownership
	tile_ownership.add_player_to_color(id, Vector2i(113, -108))
	create_available_tiles()
	for tile in available_tiles:
		if terminal_map.get_terminal(tile) is apex_factory:
			build_town(tile)
	cargo_layer = cargo_values.get_layer(CARGO_TYPE)
	var thread := Thread.new()
	thread.start(train.bind(5000))

func create_available_tiles():
	for tile in tile_ownership.get_owned_tiles(id):
		if world_map.get_cell_atlas_coords(tile) != Vector2i(5, 0):
			available_tiles.append(tile)

func build_town(coords: Vector2i):
	map[coords] = 2

#func process():
	#choose_action()

func train(num_episodes):
	var start: float = Time.get_ticks_msec()
	for episode in range(1, num_episodes):
		var state = get_state()
		var actions = get_valid_actions()
		if actions.is_empty() or get_town_state() > 14:
			return
		var action = choose_action(state, actions)
		var reward = get_reward()
		take_action(action)
		var next_state = get_state()
		var next_actions = get_valid_actions()
		
		update_q_value(state, action, reward, next_state, next_actions)
		state = next_state
		print(str(episode))
		if episode == 20:
			var end: float = Time.get_ticks_msec()
			print(str((end - start) / 1000 / 20) + " Seconds passed for each episode")

func choose_action(state: Array, actions: Array):
	if randf() < epsilon:  # Explore
		return actions[randi() % actions.size()]
		
	# Exploit (pick best action from Q-table)
	var best_action = actions[0]
	var max_q_value = -INF
	
	for action in actions:
		var state_action = str(state) + "|" + str(action)
		if q_table.has(state_action) and q_table[state_action] > max_q_value:
			max_q_value = q_table[state_action]
			best_action = action
		
		return best_action

func update_q_value(state, action, reward, next_state, next_actions):
	var state_action = str(state) + "|" + str(action)
	
	# Initialize Q-value if not in table
	if not q_table.has(state_action):
		q_table[state_action] = 0
		
	# Find max future reward
	var max_future_q = -INF
	for next_action in next_actions:
		var next_state_action = str(next_state) + "|" + str(next_action)
		if q_table.has(next_state_action):
			max_future_q = max(max_future_q, q_table[next_state_action])
	
	if max_future_q == -INF:
		max_future_q = 0  # No future action known yet
		
	# Update Q-value
	q_table[state_action] = q_table[state_action] + alpha * (reward + gamma * max_future_q - q_table[state_action])

func get_valid_actions() -> Array:
	var toReturn = []
	for tile in available_tiles:
		var actions = get_encoded_action(tile)
		for action in actions:
			toReturn.append(action)
	return toReturn

func get_magnitude(coords: Vector2i) -> int:
	var atlas := cargo_layer.get_cell_atlas_coords(coords)
	if atlas == Vector2i(-1, -1):
		return 0
	return atlas.y * 8 + atlas.x

func get_encoded_action(coords: Vector2i) -> Array:
	if map.has(coords):
		return []
	
	if get_magnitude(coords) > 0:
		return [[coords.x, coords.y, 2], [coords.x, coords.y, 1]]
	return [[coords.x, coords.y, 1]]

func get_state() -> Array:
	var toReturn := []
	for tile in available_tiles:
		toReturn.append(get_encoded_vector(tile))
	return toReturn

func get_encoded_vector(coords: Vector2i) -> Array:
	var toReturn = []
	toReturn.append(coords.x)
	toReturn.append(coords.y)
	toReturn.append(0 if !map.has(coords) else map[coords])
	toReturn.append(get_magnitude(coords))
	return toReturn

func get_status_state() -> float:
	return get_rail_state() / 15 + get_town_state()

func get_rail_state() -> float:
	var total := 0.0
	for tile: Vector2i in available_tiles:
		#Get amount of rails
		if map.has(tile) and map[tile] == 3:
			total -= 1
	return total

func get_town_state() -> float:
	var total := 0.0
	for tile: Vector2i in available_tiles:
		#Get Town Status
		if map.has(tile) and map[tile] == 2:
			total += get_town_fulfillment(tile)
	return total

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
	return get_status_state() - last_state

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
