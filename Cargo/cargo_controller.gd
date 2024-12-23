extends Node

var serviced = {}
var cargo_map_terminals = {} #Maps coords -> sink/source/hold
var cargo_types = []


@onready var map: TileMapLayer = get_parent()
@onready var tile_info = map.find_child("tile_window").find_child("tile_info")

func _process(delta):
	for obj: terminal in cargo_map_terminals.values():
		if obj.has_method("process"):
			obj.process(delta)

func _ready():
	if multiplayer.get_unique_id() == 1:
		create_cargo_types()
		create_cargo_sources()

func create_cargo_sources():
	for coords in tile_info.tile_metadata:
		create_terminal(coords, town.new(coords, tile_info.tile_metadata[coords][2]))

func create_station(coords: Vector2i, new_owner: int):
	var new_station = station.new(coords, new_owner)
	create_terminal(coords, new_station)
	

func create_terminal(coords: Vector2i, new_terminal: terminal):
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

func is_location_hold(coords: Vector2i) -> bool:
	return cargo_map_terminals.has(coords) and cargo_map_terminals[coords] is hold

func get_terminal(coords: Vector2i):
	if cargo_map_terminals.has(coords):
		return cargo_map_terminals[coords]
	return null

@rpc("authority", "call_local", "reliable")
func create_cargo_types():
	cargo_types.insert(0, "passengers")
	cargo_types.insert(1, "lumber")
	cargo_types.insert(2, "iron")
	cargo_types.insert(3, "steel")
	cargo_types.insert(4, "stone")

func get_cargo_name(index: int) -> String:
	return cargo_types[index]

func get_cargo_array():
	return cargo_types
