extends TileMapLayer

var tile_to_country_id := {}
var country_id_to_tiles_owned := {}

var country_id_to_player_id := {}
var player_id_to_country_id := {}

var id_to_atlas: Dictionary = {}
var colors_owned: Dictionary = {}

func _ready():
	Utils.assign_tile_ownership(self)
	call_deferred("create_countries")

func create_countries():
	var tile_info = Utils.tile_info
	var provinces_to_add := [Vector2i(89, -112), Vector2i(105, -116), Vector2i(103, -105), Vector2i(103, -97), Vector2i(114, -114)]
	for cell: Vector2i in provinces_to_add:
		var prov: province = tile_info.get_province(tile_info.get_province_id(cell))
		for tile: Vector2i in prov.tiles:
			tile_to_country_id[tile] = 1
			set_cell(tile, 0, Vector2i(0, 0))

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
			country_id_to_player_id.erase(player_id_to_country_id[player_id])
		
		country_id_to_player_id[country_id] = player_id
		player_id_to_country_id[player_id] = country_id
	
	#var color = get_cell_atlas_coords(coords)
	#if color == Vector2i(-1, -1):
		#return
	#if !colors_owned.has(color):
		#var past_color = Vector2i(-1, -1)
		#if id_to_atlas.has(player_id):
			#past_color = id_to_atlas[player_id]
			#colors_owned.erase(past_color)
		#select_nation.rpc_id(player_id, color, past_color)
		#id_to_atlas[player_id] = color
		#colors_owned[color] = true

@rpc("any_peer", "call_local", "reliable")
func select_nation(color: Vector2i, past_color: Vector2i):
	if past_color != Vector2i(-1, -1):
		for cell in get_used_cells_by_id(1, past_color):
			set_cell(cell, 0, past_color)
	$click_noise.play()
	for cell in get_used_cells_by_id(0, color):
		set_cell(cell, 1, color)

func is_owned(player_id: int, coords: Vector2i) -> bool:
	var country_id: int = tile_to_country_id[coords]
	return country_id_to_player_id.has(country_id) and country_id_to_player_id[country_id] == player_id

func get_owned_tiles(player_id: int) -> Array:
	if !player_id_to_country_id.has(player_id):
		return []
	return country_id_to_tiles_owned[player_id_to_country_id[player_id]]

func get_player_id_from_cell(cell: Vector2i) -> int:
	return country_id_to_player_id[tile_to_country_id[cell]]
	
