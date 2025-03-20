extends TileMapLayer

func _ready():
	prepare_refresh_tile_ownership.rpc_id(1)

@rpc("authority", "call_remote", "reliable")
func refresh_tile_ownership(resource: Dictionary):
	clear()
	for tile: Vector2i in resource:
		set_cell(tile, 0, resource[tile])

@rpc("any_peer", "call_local", "reliable")
func prepare_refresh_tile_ownership():
	pass

@rpc("any_peer", "call_local", "reliable")
func select_nation(color: Vector2i, past_color: Vector2i):
	if past_color != Vector2i(-1, -1):
		for cell in get_used_cells_by_id(1, past_color):
			set_cell(cell, 0, past_color)
	$click_noise.play()
	for cell in get_used_cells_by_id(0, color):
		set_cell(cell, 1, color)

@rpc("any_peer", "call_local", "unreliable")
func add_player_to_country(player_id: int, coords: Vector2i):
	pass
