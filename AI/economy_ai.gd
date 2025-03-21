extends Node

#AI States
var id := 1
var thread: Thread

#Set of States
var world_map: TileMapLayer
var tile_ownership: TileMapLayer
var cargo_map := terminal_map.cargo_map
var cargo_values = cargo_map.cargo_values
var magnitude_layers := []
var rail_placer

#

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
	tile_ownership.add_player_to_country(id, Vector2i(96, -111))
	magnitude_layers = cargo_values.get_layers()

func process():
	if thread != null and thread.is_alive():
		return
	thread = Thread.new()
	thread.start(run_ai_cycle.bind())

func run_ai_cycle():
	var start: float = Time.get_ticks_msec()
	var action_type := choose_type_of_action()
	#Add more actions later
	if action_type == ai_actions.PLACE_FACTORY:
		place_factory(get_most_needed_cargo())
	
	var end: float = Time.get_ticks_msec()
	print(str((end - start) / 1000) + " Seconds passed for one cycle")

func choose_type_of_action() -> ai_actions:
	#Criteria to choose later
	return ai_actions.PLACE_FACTORY

func place_factory(type: int):
	var best_tile: Vector2i
	if is_cargo_primary(type):
		best_tile = get_optimal_primary_industry(type)
		if best_tile != Vector2i(0, 0):
			create_factory(best_tile, type)

func create_factory(location: Vector2i, type: int):
	cargo_map.create_factory(id, location)

func get_optimal_primary_industry(type: int) -> Vector2i:
	var best_location: Vector2i
	var score := -10000
	for tile: Vector2i in get_owned_tiles():
		if terminal_map.is_tile_taken(tile):
			continue
		var current_score = get_cargo_magnitude(tile, type) - distance_to_closet_town(tile) / 3
		if current_score > score:
			score = current_score
			best_location = tile
	return best_location

func get_cargo_magnitude(coords: Vector2i, type: int) -> int:
	var layer: TileMapLayer = magnitude_layers[type]
	var atlas := layer.get_cell_atlas_coords(coords)
	if atlas == Vector2i(-1, -1):
		return 0
	return atlas.y * cargo_values.TILES_PER_ROW + atlas.x

func distance_to_closet_town(coords: Vector2i) -> int:
	var queue := [coords]
	var visited := {}
	visited[coords] = 0
	while !queue.is_empty():
		var curr: Vector2i = queue.pop_front()
		for tile in world_map.get_surrounding_cells(curr):
			#TODO: Add logic to account for docks and disconnected territory
			if !visited.has(tile):
				if terminal_map.is_town(tile):
					return (visited[curr] + 1)
				elif tile_ownership.is_owned(id, tile):
					visited[tile] = visited[curr] + 1
					queue.append(tile)
	return 10000000

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

func get_owned_tiles() -> Array:
	return tile_ownership.get_owned_tiles(id)

func get_town_tiles() -> Array:
	var toReturn := []
	for tile in get_owned_tiles():
		if terminal_map.is_town(tile):
			toReturn.append(tile)
	return toReturn

func get_reward() -> float:
	return 0.0

func build_rail(x1: int, y1: int, x2: int, y2: int):
	place_to_end_rail(Vector2i(x1, y1), Vector2i(x2, y2))

func place_rail(coords: Vector2i):
	#TODO
	pass

func place_to_end_rail(start: Vector2i, end: Vector2i):
	#TODO, Broken
	assert(false)
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
