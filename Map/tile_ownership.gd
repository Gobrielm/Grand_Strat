extends TileMapLayer

var tile_to_country_id := {}
var country_id_to_tiles_owned := {}

var country_id_to_player_id := {}
var player_id_to_country_id := {}

func _ready():
	Utils.assign_tile_ownership(self)
	call_deferred("create_countries")

func create_countries():
	var tile_info = Utils.tile_info
	var provinces_to_add := [Vector2i(89, -112), Vector2i(105, -116), Vector2i(103, -105), Vector2i(103, -97), Vector2i(114, -114)]
	for cell: Vector2i in provinces_to_add:
		var prov: province = tile_info.get_province(tile_info.get_province_id(cell))
		for tile: Vector2i in prov.tiles:
			add_tile_to_country(tile, 1)
			set_cell(tile, 0, Vector2i(0, 0))

func add_tile_to_country(tile: Vector2i, country_id: int):
	if !country_id_to_tiles_owned.has(country_id):
		country_id_to_tiles_owned[country_id] = []
	country_id_to_tiles_owned[country_id].append(tile)
	tile_to_country_id[tile] = country_id

@rpc("authority", "call_local", "reliable")
func refresh_tile_ownership(_resource: Dictionary):
	pass

@rpc("any_peer", "call_local", "reliable")
func prepare_refresh_tile_ownership():
	var dict := {}
	for cell in get_used_cells():
		dict[cell] = get_cell_atlas_coords(cell)
	refresh_tile_ownership.rpc_id(multiplayer.get_remote_sender_id(), dict)

@rpc("any_peer", "call_local", "unreliable")
func add_player_to_country(player_id: int, coords: Vector2i):
	var country_id: int = tile_to_country_id[coords]
	
	if !country_id_to_player_id.has(country_id):
		if player_id_to_country_id.has(player_id):
			var last_country_id: int = player_id_to_country_id[player_id]
			country_id_to_player_id.erase(last_country_id)
			unselect_nation.rpc(last_country_id)
		
		country_id_to_player_id[country_id] = player_id
		player_id_to_country_id[player_id] = country_id
		$click_noise.play()
		select_nation.rpc(country_id_to_tiles_owned[country_id])
		play_noise.rpc_id(player_id)

@rpc("any_peer", "call_local", "reliable")
func select_nation(cells_to_change: Array):
	var atlas = get_cell_atlas_coords(cells_to_change[0])
	for cell in cells_to_change:
		set_cell(cell, 1, atlas)

@rpc("authority", "call_local", "reliable")
func play_noise():
	$click_noise.play()

@rpc("any_peer", "call_local", "reliable")
func unselect_nation(cells_to_change: Array):
	var atlas = get_cell_atlas_coords(cells_to_change[0])
	for cell in cells_to_change:
		set_cell(cell, 0, atlas)

func is_owned(player_id: int, coords: Vector2i) -> bool:
	var country_id: int = tile_to_country_id[coords]
	return country_id_to_player_id.has(country_id) and country_id_to_player_id[country_id] == player_id

func get_owned_tiles(player_id: int) -> Array:
	if !player_id_to_country_id.has(player_id):
		return []
	return country_id_to_tiles_owned[player_id_to_country_id[player_id]]

func get_player_id_from_cell(cell: Vector2i) -> int:
	return country_id_to_player_id[tile_to_country_id[cell]]
	
