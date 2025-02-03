class_name terminal_map extends Node
#Represents Singleton

static var serviced = {}
static var cargo_map_terminals = {} #Maps coords -> hold
static var cargo_types = [
	"clay", "sand", "sulfur", "lead", "iron", "coal", "copper", "zinc",
	"wood", "salt", "grain", "livestock", "fish", "fruit", "cotton",
	"silk", "spices", "coffee", "tea", "tobacco", "gold",
	
	"bricks", "glass", "lumber", "paper", "tools", "steel", "brass", "dynamite",
	"flour", "fabric", "liquor", "bread", "leather", "meat", "clothes",
	"wine", "luxury_clothes", "cigarettes", "perserved_fruit",
	"furniture", "wagons", "boats", "lanterns", "trains",
	"ammo", "guns", "artillery", "preserved_meat", "canned_food", "rations", "luxury_rations",
]
static var cargo_names_to_types = {}
static var base_prices = {}


static var map: TileMapLayer
static var tile_info

static func _on_day_tick_timeout():
	for obj: terminal in cargo_map_terminals.values():
		if obj.has_method("day_tick"):
			obj.day_tick()

static func _on_month_tick_timeout():
	for obj: terminal in cargo_map_terminals.values():
		if obj.has_method("month_tick"):
			obj.month_tick()

static func create(_map: TileMapLayer):
	map = _map
	tile_info = map.get_tile_data()
	create_cargo_types()
	create_base_prices()

static func create_station(coords: Vector2i, new_owner: int):
	var new_station = station.new(coords, new_owner)
	create_terminal(new_station)
	
static func create_terminal(new_terminal: terminal):
	var coords = new_terminal.get_location()
	cargo_map_terminals[coords] = new_terminal
	add_connected_terminals(coords, new_terminal)

static func add_connected_terminals(coords: Vector2i, new_terminal: terminal):
	for coord in map.get_surrounding_cells(coords):
		if cargo_map_terminals.has(coord):
			var term = cargo_map_terminals[coord]
			if new_terminal.has_method("add_connected_terminal"):
				new_terminal.add_connected_terminal(term)

static func is_hold(coords: Vector2i) -> bool:
	return cargo_map_terminals.has(coords) and cargo_map_terminals[coords] is hold

static func is_factory(coords: Vector2i) -> bool:
	if cargo_map_terminals.has(coords):
		var term = cargo_map_terminals[coords]
		return term is factory or term is apex_factory or term is base_factory
	return false

static func get_cash_of_firm(coords: Vector2i) -> int:
	if cargo_map_terminals.has(coords):
		var firm_inst = cargo_map_terminals[coords]
		if firm_inst is firm:
			return firm_inst.get_cash()
	return 0

static func get_local_prices(coords: Vector2i) -> Dictionary:
	if cargo_map_terminals.has(coords):
		var fact = cargo_map_terminals[coords]
		if fact is factory_template:
			return fact.get_local_prices()
	return {}

static func get_terminal(coords: Vector2i):
	if cargo_map_terminals.has(coords):
		return cargo_map_terminals[coords]
	return null

static func is_station(coords: Vector2i):
	return cargo_map_terminals.has(coords) and cargo_map_terminals[coords] is station

static func get_station(coords: Vector2i) -> station:
	if is_station(coords):
		return cargo_map_terminals[coords]
	return null

static func get_station_orders(coords: Vector2i) -> Dictionary:
	var toReturn = {}
	if is_station(coords):
		var orders = cargo_map_terminals[coords].get_orders()
		for type in orders:
			toReturn[type] = orders[type].convert_to_array()
	return toReturn

static func edit_order_station(coords: Vector2i, type: int, amount: int, buy: bool):
	if is_station(coords):
		cargo_map_terminals[coords].edit_order(type, amount, buy)

static func remove_order_station(coords: Vector2i, type: int):
	if is_station(coords):
		cargo_map_terminals[coords].remove_order(type)

static func create_cargo_types():
	for type in cargo_types:
		cargo_names_to_types[cargo_types[type]] = type

static func create_base_prices():
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("lumber")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	base_prices[get_cargo_type("wood")] = 10
	local_price_controller.set_base_prices(base_prices)
	assert(base_prices.size() == cargo_types.size())

static func get_number_of_goods() -> int:
	return cargo_types.size()

static func get_cargo_name(index: int) -> String:
	return cargo_types[index]

static func get_cargo_type(cargo_name: String) -> int:
	if cargo_names_to_types.has(cargo_name):
		return cargo_names_to_types[cargo_name]
	return -1

static func get_cargo_array_at_location(coords: Vector2i) -> Dictionary:
	return get_terminal(coords).get_current_hold()

static func get_cargo_dict() -> Dictionary:
	return cargo_types
