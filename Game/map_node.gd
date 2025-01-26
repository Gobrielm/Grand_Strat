extends Node

@onready var tile_ownership = $tile_ownership
@onready var main_map = $main_map
@onready var camera = $main_map/player_camera
@onready var factory_window = $main_map/factory_window
@onready var depot_window = $main_map/depot_window
@onready var station_window = $main_map/station_window
@onready var unit_creator_window = $main_map/unit_creator_window
@onready var cargo_map = $cargo_map

var cargo_controller
var unique_id


func _ready():
	unique_id = multiplayer.get_unique_id()
	if unique_id == 1:
		if cargo_controller != null:
			cargo_map.assign_cargo_controller(cargo_controller)
	else:
		remove_child(cargo_map)
		cargo_map.queue_free()
		cargo_map = load("res://Client_Objects/client_cargo_map.tscn").instantiate() 
		add_child(cargo_map)
		remove_child(tile_ownership)
		tile_ownership.queue_free()
		tile_ownership = load("res://Client_Objects/client_tile_ownership.tscn").instantiate()
		tile_ownership.name = "tile_ownership"
		add_child(tile_ownership)
	enable_nation_picker()

func _input(event):
	main_map.update_hover()
	camera.update_coord_label(get_cell_position())
	if event.is_action_pressed("click"):
		if state_machine.is_picking_nation():
			pick_nation()
		elif state_machine.is_building():
			main_map.record_hover_click()
		elif state_machine.is_building_many_rails():
			main_map.record_start_rail()
		elif state_machine.is_building_units():
			main_map.create_unit()
		elif state_machine.is_selecting_unit() and main_map.is_unit_double_clicked():
			main_map.show_unit_info_window()
		else:
			if state_machine.is_selecting_unit():
				state_machine.unclick_unit()
			main_map.unit_map.select_unit(get_cell_position(), unique_id)
	elif event.is_action_released("click"):
		if state_machine.is_controlling_camera() and main_map.is_owned_station(get_cell_position()):
			station_window.open_window(get_cell_position())
		elif state_machine.is_controlling_camera() and main_map.is_factory(get_cell_position()):
			factory_window.open_window(get_cell_position())
		elif state_machine.is_controlling_camera() and main_map.is_owned_depot(get_cell_position()):
			depot_window.open_window(get_cell_position())
		elif state_machine.is_building_many_rails():
			main_map.place_rail_to_start()
		main_map.reset_start()
	elif event.is_action_pressed("deselect"):
		main_map.clear_all_temps()
		if !state_machine.is_picking_nation() and !state_machine.is_selecting_unit():
			camera.unpress_all_buttons()
		state_machine.default()
	elif event.is_action_pressed("debug_place_train") and state_machine.is_controlling_camera():
		main_map.create_train.rpc(get_cell_position())
	elif event.is_action_pressed("debug_print") and state_machine.is_controlling_camera():
		unit_creator_window.popup()

func assign_cargo_controller(new_cargo_controller):
	cargo_controller = new_cargo_controller
	if cargo_map != null:
		cargo_map.assign_cargo_controller(cargo_controller)

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

#Map Commands
func get_cell_position() -> Vector2i:
	return main_map.get_cell_position()
