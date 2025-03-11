extends Node


var last_state: float
var id := 1

#Set of States
var world_map: TileMapLayer
var tile_ownership: TileMapLayer
var cargo_map := terminal_map.cargo_map
var cargo_values = cargo_map.cargo_values
var rail_placer

#Set of Actions
enum aaaa {
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

func process():
	save_state()

func save_state():
	var file := FileAccess.open(statesOutput, FileAccess.READ)
	var string: String = file.get_as_text()
	file.close()
	file = FileAccess.open(statesOutput, FileAccess.WRITE)
	var string_array: PackedStringArray = []
	for tile: Vector2i in tile_ownership.get_owned_tiles(id):
		var amount = rail_placer.get_track_connection_count(tile)
		string_array.append(str(amount))
	for tile: Vector2i in tile_ownership.get_owned_tiles(id):
		var amount = -terminal_map.get_town_fulfillment(tile)
		string_array.append(str(amount))
	file.store_string(string)
	file.store_csv_line(string_array)
	file.close()
	
	file = FileAccess.open(rewardOutput, FileAccess.READ)
	string = file.get_as_text()
	file.close()
	
	file = FileAccess.open(rewardOutput, FileAccess.WRITE)
	string_array = [str(get_reward())]
	file.store_string(string)
	file.store_csv_line(string_array)
	file.close()
	

func get_status_state() -> float:
	return get_rail_state() + get_town_state()

func get_rail_state() -> float:
	var total := 0.0
	for tile: Vector2i in tile_ownership.get_owned_tiles(id):
		#Get amount of rails
		total += rail_placer.get_track_connection_count(tile)
	return total

func get_town_state() -> float:
	var total := 0.0
	for tile: Vector2i in tile_ownership.get_owned_tiles(id):
		#Get amount of rails
		total -= terminal_map.get_town_fulfillment(tile)
	return total

func get_reward() -> float:
	return get_status_state() - last_state

func choose_action():
	last_state = get_status_state()
	#Some function to choose state
