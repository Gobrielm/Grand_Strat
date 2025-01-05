extends TileMapLayer

@rpc("any_peer", "call_remote", "unreliable")
func create_unit(location: Vector2i):
	set_cell(location, 1, Vector2i(0, 0))

func move_unit(position_soldier: Vector2i, move_to: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(position_soldier)
	set_cell(move_to, 1, soldier_atlas)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
