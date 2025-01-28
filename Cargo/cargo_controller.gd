extends Node

var serviced = {}
var cargo_map_terminals = {} #Maps coords -> hold
var cargo_types = {}
var base_prices = {}


@onready var map: TileMapLayer
@onready var tile_info

func _process(delta):
	for obj: terminal in cargo_map_terminals.values():
		if obj.has_method("process"):
			obj.process(delta)

func _on_month_tick_timeout():
	for obj: terminal in cargo_map_terminals.values():
		if obj.has_method("month_tick"):
			obj.month_tick()


func _ready():
	map = get_parent()
	tile_info = map.get_tile_data()
	create_cargo_types()
	create_base_prices()

func create_station(coords: Vector2i, new_owner: int):
	var new_station = station.new(coords, new_owner)
	create_terminal(new_station)
	
func create_terminal(new_terminal: terminal):
	var coords = new_terminal.get_location()
	cargo_map_terminals[coords] = new_terminal
	add_connected_terminals(coords, new_terminal)

func add_connected_terminals(coords: Vector2i, new_terminal: terminal):
	for coord in map.get_surrounding_cells(coords):
		if cargo_map_terminals.has(coord):
			var term = cargo_map_terminals[coord]
			if term.has_method("add_terminal"):
				term.add_terminal(coords, new_terminal)
			if new_terminal.has_method("add_connected_terminal"):
				new_terminal.add_connected_terminal(term)

func is_hold(coords: Vector2i) -> bool:
	return cargo_map_terminals.has(coords) and cargo_map_terminals[coords] is hold

func is_factory(coords: Vector2i) -> bool:
	if cargo_map_terminals.has(coords):
		var term = cargo_map_terminals[coords]
		return term is factory or term is apex_factory or term is base_factory
	return false

func get_local_prices(coords: Vector2i) -> Dictionary:
	if cargo_map_terminals.has(coords):
		var fact = cargo_map_terminals[coords]
		if fact is factory_template:
			return fact.get_local_prices()
	return {}

func get_terminal(coords: Vector2i):
	if cargo_map_terminals.has(coords):
		return cargo_map_terminals[coords]
	return null

func is_station(coords: Vector2i):
	return cargo_map_terminals.has(coords) and cargo_map_terminals[coords] is station

func get_ingoing_cargo(coords: Vector2i) -> Dictionary:
	return cargo_map_terminals[coords].get_ingoing_cargo()

func get_outgoing_cargo(coords: Vector2i) -> Dictionary:
	return cargo_map_terminals[coords].get_outgoing_cargo()

func swap_good_to_ingoing_station(coords: Vector2i, good_index: int):
	if is_station(coords):
		cargo_map_terminals[coords].swap_good_to_ingoing(good_index)

func swap_good_to_outgoing_station(coords: Vector2i, good_index: int):
	if is_station(coords):
		cargo_map_terminals[coords].swap_good_to_outgoing(good_index)

func create_cargo_types():
	cargo_types[0] = "wood"
	cargo_types[1] = "lumber"
	cargo_types[2] = "iron"
	cargo_types[3] = "steel"
	cargo_types[4] = "stone"
	cargo_types[5] = "grain"
	cargo_types[6] = "livestock"
	cargo_types[7] = "wine"
	cargo_types[8] = "iron"
	cargo_types[9] = "gold"
	cargo_types[10] = "silver"
	cargo_types[11] = "copper"
	cargo_types[12] = "wool"
	cargo_types[13] = "silk"
	cargo_types[14] = "spices"
	cargo_types[15] = "porcelain"
	cargo_types[16] = "salt"
	cargo_types[17] = "sulfur"
	cargo_types[18] = "lead"
	cargo_types[19] = "leather"
	cargo_types[20] = "meat"

func create_base_prices():
	base_prices[0] = 10
	base_prices[1] = 10
	base_prices[2] = 10
	base_prices[3] = 10
	base_prices[4] = 10
	base_prices[5] = 10
	base_prices[6] = 10
	base_prices[7] = 10
	base_prices[8] = 10
	base_prices[9] = 10
	base_prices[10] = 10
	base_prices[11] = 10
	base_prices[12] = 10
	base_prices[13] = 10
	base_prices[14] = 10
	base_prices[15] = 10
	base_prices[16] = 10
	base_prices[17] = 10
	base_prices[18] = 10
	base_prices[19] = 10
	base_prices[20] = 10
	terminal.set_base_prices(base_prices)
	local_price_controller.set_base_prices(base_prices)
	assert(base_prices.size() == cargo_types.size())
	

func get_cargo_name(index: int) -> String:
	return cargo_types[index]

func get_cargo_array_at_location(coords: Vector2i) -> Array:
	return get_terminal(coords).get_current_hold()

func get_cargo_dict() -> Dictionary:
	return cargo_types
