extends TileMapLayer

@rpc("authority", "call_remote", "unreliable")
func refresh_tile_ownership(resource: Dictionary):
	clear()
	for tile in resource:
		set_cell(tile, 0, resource[tile])

@rpc("any_peer", "call_local", "unreliable")
func prepare_refresh_tile_ownership():
	pass
