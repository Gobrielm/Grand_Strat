extends Node

var map: TileMapLayer

var depots = {}

var holds = {}

var population = {}

func _init(new_map):
	map = new_map
	Utils.assign_tile_info(self)

func add_depot(coords: Vector2i, depot: terminal, player_id: int):
	depots[coords] = [depot, player_id]

func get_depot(coords: Vector2i) -> terminal:
	if is_depot(coords):
		return depots[coords][0]
	return null

func get_depot_name(coords: Vector2i) -> String:
	if is_depot(coords):
		return depots[coords][0].get_depot_name()
	return ""

func is_depot(coords: Vector2i) -> bool:
	return depots.has(coords)

func is_owned_depot(coords: Vector2i, id: int) -> bool:
	return depots.has(coords) and depots[coords][1] == id

func add_hold(coords: Vector2i, hold_name: String, player_id: int):
	holds[coords] = [hold_name, player_id]

func get_hold_name(coords: Vector2i) -> String:
	if holds.has(coords):
		return holds[coords][0]
	return ""

func is_hold(coords: Vector2i) -> bool:
	return holds.has(coords)

func is_owned_hold(coords: Vector2i, id: int) -> bool:
	return holds.has(coords) and holds[coords][1] == id

func set_population(coords: Vector2i, amount: int):
	population[coords] = amount

func get_population(coords: Vector2i) -> int:
	return population[coords]
