class_name Utils extends Node

static var cargo_values
static var tile_ownership: TileMapLayer
static var world_map: TileMapLayer
static var tile_info
static var rail_placer

static func round(num, places) -> float:
	return round(num * pow(10, places)) / pow(10, places)

static func assign_cargo_values(_cargo_values):
	cargo_values = _cargo_values

static func assign_tile_ownership(_tile_ownership):
	tile_ownership = _tile_ownership

static func assign_rail_placer(_rail_placer):
	rail_placer = _rail_placer

static func assign_world_map(_world_map):
	world_map = _world_map

static func assign_tile_info(_tile_info):
	tile_info = _tile_info

static func is_tile_water(coords: Vector2i) -> bool:
	var atlas = world_map.get_cell_atlas_coords(coords)
	return atlas == Vector2i(6, 0) or atlas == Vector2i(7, 0) or atlas == Vector2i(-1, -1)

static func is_tile_open(coords: Vector2i, id: int) -> bool:
	return !terminal_map.is_tile_taken(coords) and rail_placer.get_track_connection_count(coords) == 0 and tile_ownership.is_owned(id, coords)
