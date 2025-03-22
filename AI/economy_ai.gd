extends Node

#AI States
var id := 1
var thread: Thread
var stored_tile: Vector2i

#Set of States
var world_map: TileMapLayer
var tile_ownership: TileMapLayer
var cargo_map := terminal_map.cargo_map
var cargo_values = cargo_map.cargo_values
var rail_placer

#

#Set of Actions
enum ai_actions {
	PLACE_FACTORY,
	CONNECT_FACTORY,
	CONNECT_STATION
}

func _init(_world_map: TileMapLayer, _tile_ownership: TileMapLayer): 
	thread = Thread.new()
	world_map = _world_map
	rail_placer = world_map.rail_placer
	tile_ownership = _tile_ownership
	tile_ownership.add_player_to_country(id, Vector2i(96, -111))

func process():
	if thread.is_alive():
		return
	elif thread.is_started():
		thread.wait_to_finish()
	thread.start(run_ai_cycle.bind())

func _exit_tree():
	thread.wait_to_finish()

func run_ai_cycle():
	var start: float = Time.get_ticks_msec()
	var action_type := choose_type_of_action()
	#Add more actions later
	if action_type == ai_actions.PLACE_FACTORY:
		place_factory(get_most_needed_cargo())
	elif action_type == ai_actions.CONNECT_FACTORY:
		connect_factory(stored_tile)
	elif action_type == ai_actions.CONNECT_STATION:
		connect_station(stored_tile)
	var end: float = Time.get_ticks_msec()
	print(str((end - start) / 1000) + " Seconds passed for one cycle")

func choose_type_of_action() -> ai_actions:
	#Criteria to choose later
	if is_unconnected_buildings():
		return ai_actions.CONNECT_FACTORY
	elif is_unconnected_stations():
		return ai_actions.CONNECT_STATION
	return ai_actions.PLACE_FACTORY

func is_unconnected_buildings() -> bool:
	for tile: Vector2i in get_owned_tiles():
		if terminal_map.is_owned_construction_site(tile):
			var found := false
			for cell in world_map.get_surrounding_cells(tile):
				if tile_ownership.is_owned(id, cell) and terminal_map.is_station(cell):
					found = true
			if !found:
				stored_tile = tile
				return true
	return false

func is_unconnected_stations() -> bool:
	for tile: Vector2i in get_owned_tiles():
		if terminal_map.is_station(tile):
			var found := false
			for cell in world_map.get_surrounding_cells(tile):
				if world_map.do_tiles_connect(tile, cell):
					found = true
				#Check if there is rail
			if !found:
				stored_tile = tile
				return true
	return false

func place_factory(type: int):
	var best_tile: Vector2i
	if is_cargo_primary(type):
		best_tile = get_optimal_primary_industry(type)
		if best_tile != Vector2i(0, 0):
			create_factory(best_tile, type)

func create_factory(location: Vector2i, type: int):
	cargo_map.create_factory(id, location)
	#TODO: Pick Recipe

func get_optimal_primary_industry(type: int) -> Vector2i:
	var best_location: Vector2i
	var score := -10000
	for tile: Vector2i in get_owned_tiles():
		if !is_cell_available(tile):
			continue
		var current_score = get_cargo_magnitude(tile, type) - round(distance_to_closest_station(tile) / 7.0)
		var free_tile := false
		for cell in world_map.get_surrounding_cells(tile):
			if is_cell_available(cell):
				free_tile = true
		if !free_tile:
			continue
		if current_score > score:
			score = current_score
			best_location = tile
	return best_location

func get_cargo_magnitude(coords: Vector2i, type: int) -> int:
	return cargo_values.get_tile_magnitude(coords, type)

func distance_to_closest_station(coords: Vector2i) -> int:
	return info_of_closest_station(coords)[0]

func coords_of_closest_station(coords: Vector2i) -> Vector2i:
	return info_of_closest_station(coords)[1]

func info_of_closest_station(coords: Vector2i) -> Array:
	var queue := [coords]
	var visited := {}
	visited[coords] = 0
	while !queue.is_empty():
		var curr: Vector2i = queue.pop_front()
		for tile in world_map.get_surrounding_cells(curr):
			#TODO: Add logic to account for docks and disconnected territory
			if !visited.has(tile):
				if terminal_map.is_station(tile) or terminal_map.is_town(tile):
					return [(visited[curr] + 1), tile]
				elif tile_ownership.is_owned(id, tile):
					visited[tile] = visited[curr] + 1
					queue.append(tile)
	return [1000000, null]

func is_cargo_primary(type: int) -> bool:
	return terminal_map.amount_of_primary_goods > type

func get_most_needed_cargo() -> int:
	var cargo_fulfillment := get_town_fulfillment()
	var min_fulfilled := 100.0
	var type_to_return := -1
	for type in cargo_fulfillment:
		if cargo_fulfillment[type] < min_fulfilled:
			min_fulfilled = cargo_fulfillment[type]
			type_to_return = type
		#Grain
		elif type == 12 and cargo_fulfillment[type] * 0.8 < min_fulfilled:
			min_fulfilled = cargo_fulfillment[type]
			type_to_return = type
	return type_to_return

func get_town_fulfillment() -> Dictionary:
	var town_tiles := get_town_tiles()
	var total := {}
	var towns: float = town_tiles.size()
	for town_tile: Vector2i in town_tiles:
		for type in terminal_map.get_town_wants(town_tile):
			if !total.has(type):
				total[type] = 0.0
			total[type] += terminal_map.get_town_fulfillment(town_tile, type)
	for type: int in total:
		total[type] = total[type] / towns
	return total

func connect_factory(coords: Vector2i):
	var closest_station: Vector2i = coords_of_closest_station(coords)
	place_station(coords, closest_station)

func place_station(center: Vector2i, dest: Vector2i):
	var score := -1000
	var best: Vector2i
	var orientation: int
	var orientation_tracker := 2
	for tile in world_map.get_surrounding_cells(center):
		if is_cell_available(tile):
			var curr_score = round(20.0 / center.distance_to(dest))
			if curr_score > score:
				score = curr_score
				best = tile
				orientation = orientation_tracker
		orientation_tracker = (orientation_tracker + 1) % 6
	if best == Vector2i(0, 0):
		print("problems")
		return
	create_station(best, orientation)

func create_station(location: Vector2i, orientation: int):
	world_map.call_deferred("place_rail_general", location, orientation, 2)

func connect_station(coords: Vector2i):
	var closest_station := coords_of_closest_station(coords)
	build_rail(coords, closest_station)

func get_owned_tiles() -> Array:
	return tile_ownership.get_owned_tiles(id)

func is_cell_available(coords: Vector2i) -> bool:
	return !terminal_map.is_tile_taken(coords) and tile_ownership.is_owned(id, coords) 

func get_town_tiles() -> Array:
	var toReturn := []
	for tile in get_owned_tiles():
		if terminal_map.is_town(tile):
			toReturn.append(tile)
	return toReturn

func get_reward() -> float:
	return 0.0

func build_rail(start: Vector2i, end: Vector2i):
	var route: Dictionary = world_map.get_rails_from(start, end)
	for tile: Vector2i in route:
		for cell: Vector2i in route[tile]:
			place_rail(tile, cell.x)

func place_rail(coords: Vector2i, orientation: int):
	world_map.call_deferred("place_rail_general", coords, orientation, 0)

func debug() -> Dictionary:
	#var dict := get_rails_to_build(Vector2i(100, -115), 0, get_cell_position(), 0)
	#for tile in dict:
		#for orientation: int in dict[tile]:
			#rail_placer.hover_debug(tile, orientation)
	#return dict
	return {}


func get_rails_to_build(from: Vector2i, starting_orientation: int, to: Vector2i, ending_orientation: int) -> Dictionary:
	var queue := [from]
	var tile_to_prev := {} # Vector2i -> Array[Tile for each direction]
	var order := {} # Vector2i -> Array[indices in order for tile_to_prev, first one is the fastest]
	var visited := {} # Vector2i -> Array[Bool for each direction]
	visited[from] = [false, false, false, false, false, false]
	visited[from][swap_direction(starting_orientation)] = true
	visited[from][(starting_orientation)] = true
	var found = false
	var curr: Vector2i
	while !queue.is_empty() and !found:
		curr = queue.pop_front()
		var cells_to_check = get_cells_in_front(curr, visited[curr])
		for direction in cells_to_check.size():
			var cell = cells_to_check[direction]
			if cell == to and (direction == ending_orientation or direction == swap_direction(ending_orientation)):
				intialize_visited(visited, cell, direction)
				intialize_order(order, cell, direction)
				intialize_tile_to_prev(tile_to_prev, cell, direction, curr)
				found = true
				break
			elif cell != null and !check_visited(visited, cell, direction) and Utils.is_tile_open(cell, id):
				intialize_visited(visited, cell, direction)
				intialize_order(order, cell, direction)
				intialize_tile_to_prev(tile_to_prev, cell, direction, curr)
				queue.append(cell)
	
	var toReturn := {}
	var direction = null
	var prev = null
	if found:
		direction = order[to][0]
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
	for cell in world_map.get_surrounding_cells(coords):
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
