extends Sprite2D

@onready var window: Window = $Window
@onready var map: TileMapLayer = get_parent()

func _ready():
	window.hide()

func _input(event):
	if event.is_action_pressed("click") and is_selecting_route():
		do_add_stop.rpc_id(1, map.get_cell_position())
	elif event.is_action_pressed("click") and visible:
		open_menu(map.get_mouse_local_to_map())
	elif event.is_action_pressed("deselect"):
		window.deselect_add_stop()

func start_selecting_route():
	map.state_machine.start_selecting_route()

func stop_selecting_route():
	map.state_machine.stop_selecting_route()

func is_selecting_route() -> bool:
	return map.state_machine.is_selecting_route()

func did_mouse_click(mouse_pos: Vector2):
	var match_x = mouse_pos.x > position.x - 48 and mouse_pos.x < position.x + 48
	var match_y = mouse_pos.y > position.y - 48 and mouse_pos.y < position.y + 48
	return match_x and match_y

func open_menu(mouse_pos: Vector2):
	if did_mouse_click(mouse_pos):
		window.popup()

func _on_window_close_requested():
	window.deselect_add_stop()
	window.hide()

func _on_start_pressed():
	start_train.rpc_id(1)

func _on_stop_pressed():
	stop_train.rpc_id(1)

@rpc("any_peer", "unreliable", "call_local")
func start_train():
	pass

@rpc("any_peer", "unreliable", "call_local")
func stop_train():
	pass

@rpc("any_peer", "unreliable", "call_local")
func do_add_stop():
	pass

@rpc("authority", "unreliable", "call_local")
func update_train(new_position: Vector2i):
	position = new_position

@rpc("authority", "unreliable", "call_local")
func update_train_rotation(new_rotation: int):
	rotation_degrees = new_rotation

@rpc("authority", "unreliable", "call_local")
func create(new_location: Vector2i):
	position = map.map_to_local(new_location)

@rpc("authority", "unreliable", "call_local")
func add_stop(new_location: Vector2i):
	var routes: ItemList = $Window/Routes
	routes.add_item(str(new_location))

@rpc("any_peer", "unreliable", "call_local")
func remove_stop(index: int):
	var routes: ItemList = $Window/Routes
	routes.remove_item(index)

@rpc("authority", "unreliable", "call_local")
func update_cargo_gui(names: Array, amounts: Array):
	$Window/Goods.clear()
	for type in names.size():
		$Window/Goods.add_item(names[type] + ", " + str(amounts[type]))

@rpc("authority", "unreliable", "call_local")
func go_into_depot():
	visible = false

@rpc("authority", "unreliable", "call_local")
func go_out_of_depot():
	visible = true
