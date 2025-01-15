extends Node

@onready var tile_ownership = $tile_ownership
@onready var main_map = $main_map
@onready var camera = $main_map/player_camera
var state_machine
var unique_id

func _ready():
	unique_id = multiplayer.get_unique_id()
	if unique_id != 1:
		tile_ownership = load("res://Client_Objects/client_tile_ownership.tscn").instantiate()
		tile_ownership.name = "tile_ownership"
		add_child(tile_ownership)
	enable_nation_picker()

func _input(event):
	if event.is_action_pressed("click"):
		if state_machine.is_picking_nation():
			pick_nation()

#Tile_Ownership
func toggle_ownership_view():
	tile_ownership.visible = !tile_ownership.visible

func is_owned(player_id: int, coords: Vector2i) -> bool:
	return tile_ownership.is_owned(player_id, coords)

#Nation_Picker
func enable_nation_picker():
	camera.get_node("CanvasLayer").visible = false
	state_machine.start_picking_nation()

func disable_nation_picker():
	camera.get_node("CanvasLayer").visible = true
	state_machine.stop_picking_nation()

func pick_nation():
	var coords = main_map.get_cell_position()
	tile_ownership.add_player_to_color.rpc_id(1, unique_id, coords)
