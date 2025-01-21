extends Node

var serviced = {}
var cargo_map_terminals = {} #Maps coords -> sink/source/hold
var cargo_types = {}


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
	#create_cargo_sources()

func create_cargo_sources():
	var cities = tile_info.get_cities()
	for coords in cities:
		create_terminal(town.new(coords, cities[coords][1]))

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

func get_terminal(coords: Vector2i):
	if cargo_map_terminals.has(coords):
		return cargo_map_terminals[coords]
	return null

@rpc("authority", "call_local", "reliable")
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
	terminal.set_number_of_goods(cargo_types.size())

func get_cargo_name(index: int) -> String:
	return cargo_types[index]

func get_cargo_array_at_location(coords: Vector2i) -> Array:
	return get_terminal(coords).get_current_hold()

func get_cargo_dict() -> Dictionary:
	return cargo_types
