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

func add_player_to_color(player_id: int, coords: Vector2i):
	var color = get_cell_atlas_coords(coords)
	if !colors_owned[color]:
		id_to_atlas[player_id] = color
		colors_owned[color] = true

func is_owned(player_id: int, coords: Vector2i) -> bool:
	var color = get_cell_atlas_coords(coords)
	return id_to_atlas.has(player_id) and id_to_atlas[player_id] == color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass