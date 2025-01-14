extends TileMapLayer

var id_to_atlas: Dictionary = {}
var colors_owned: Dictionary = {}

@rpc("authority", "call_local", "unreliable")
func refresh_tile_ownership(resource: Dictionary):
	pass

@rpc("any_peer", "call_local", "unreliable")
func prepare_refresh_tile_ownership():
	var dict: Dictionary = {}
	for cell in get_used_cells():
		dict[cell] = get_cell_atlas_coords(cell)
	refresh_tile_ownership.rpc_id(multiplayer.get_remote_sender_id(), dict)

@rpc("any_peer", "call_local", "unreliable")
func add_player_to_color(player_id: int, coords: Vector2i):
	var color = get_cell_atlas_coords(coords)
	if color == Vector2i(-1, -1):
		return
	if !colors_owned.has(color):
		var past_color = Vector2i(-1, -1)
		if id_to_atlas.has(player_id):
			past_color = id_to_atlas[player_id]
			colors_owned.erase(past_color)
		select_nation.rpc_id(player_id, color, past_color)
		id_to_atlas[player_id] = color
		colors_owned[color] = true

@rpc("any_peer", "call_local", "reliable")
func select_nation(color: Vector2i, past_color: Vector2i):
	if past_color != Vector2i(-1, -1):
		for cell in get_used_cells_by_id(1, past_color):
			set_cell(cell, 0, past_color)
	$click_noise.play()
	for cell in get_used_cells_by_id(0, color):
		set_cell(cell, 1, color)

func is_owned(player_id: int, coords: Vector2i) -> bool:
	var color = get_cell_atlas_coords(coords)
	return id_to_atlas.has(player_id) and id_to_atlas[player_id] == color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
