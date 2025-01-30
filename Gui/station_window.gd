extends Window
var location = null
var hold_name: String
var current_in_cargo: Dictionary
var current_out_cargo: Dictionary
var current_cash: int

const time_every_update = 1
var progress: float = 0.0

var map: TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	map = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress += delta
	if progress > time_every_update:
		refresh_window()

func _on_close_requested():
	hide()

func open_window(new_location: Vector2i):
	location = new_location
	refresh_window()
	popup()

func refresh_window():
	progress = 0
	if location != null:
		request_station_cargo.rpc_id(1, location)
		request_current_name.rpc_id(1, location)
		request_current_cash.rpc_id(1, location)
		station_window()

@rpc("any_peer", "call_local", "unreliable")
func request_current_name(coords: Vector2i):
	var current_name = map.tile_info.get_hold_name(coords)
	update_current_name.rpc_id(multiplayer.get_remote_sender_id(), current_name)

@rpc("any_peer", "call_local", "unreliable")
func request_station_cargo(coords: Vector2i):
	var in_dict = map.get_in_station_cargo(coords)
	var out_dict = map.get_out_station_cargo(coords)
	update_current_cargo.rpc_id(multiplayer.get_remote_sender_id(), in_dict, out_dict)

@rpc("any_peer", "call_local", "unreliable")
func request_current_cash(coords: Vector2i):
	var current_cash = map.get_cash_of_firm(coords)
	update_current_cash.rpc_id(multiplayer.get_remote_sender_id(), current_cash)

@rpc("authority", "call_local", "unreliable")
func update_current_cargo(new_in_cargo: Dictionary, new_out_cargo: Dictionary):
	current_in_cargo = new_in_cargo
	current_out_cargo = new_out_cargo

@rpc("authority", "call_local", "unreliable")
func update_current_name(new_name: String):
	$Name.text = "[center][font_size=30]" + hold_name + "[/font_size][/center]"

@rpc("authority", "call_local", "unreliable")
func update_current_cash(new_cash: int):
	current_cash = new_cash
	$Cash.text = "$" + str(current_cash)

func station_window():
	var in_cargo_list: ItemList = $In_Node/Cargo_List
	var out_cargo_list: ItemList = $Out_Node/Cargo_List
	var names = map.get_cargo_index_to_name()
	var selected_name = get_selected_in_name()
	
	for i in in_cargo_list.item_count:
		in_cargo_list.remove_item(0)
	for cargo in current_in_cargo.size():
		if current_in_cargo[cargo] != 0:
			var cargo_name: String = names[cargo]
			in_cargo_list.add_item(cargo_name + ", " + str(current_in_cargo[cargo]))
			if cargo_name == selected_name:
				in_cargo_list.select(cargo)
	
	selected_name = get_selected_out_name()
	
	for i in out_cargo_list.item_count:
		out_cargo_list.remove_item(0)
	for cargo in current_out_cargo.size():
		if current_out_cargo[cargo] != 0:
			var cargo_name: String = names[cargo]
			out_cargo_list.add_item(cargo_name + ", " + str(current_out_cargo[cargo]))
			if cargo_name == selected_name:
				out_cargo_list.select(cargo)


func get_selected_out_name() -> String:
	var out_cargo_list: ItemList = $Out_Node/Cargo_List
	var selected_items: Array = out_cargo_list.get_selected_items()
	if selected_items.size() > 0:
		var toReturn = ""
		for i in out_cargo_list.get_item_text(selected_items[0]):
			if i == ',':
				break
			toReturn += i
		return toReturn
	return ""

func get_selected_in_name() -> String:
	var in_cargo_list: ItemList = $In_Node/Cargo_List
	var selected_items: Array = in_cargo_list.get_selected_items()
	if selected_items.size() > 0:
		var toReturn = ""
		for i in in_cargo_list.get_item_text(selected_items[0]):
			if i == ',':
				break
			toReturn += i
		return toReturn
	return ""
	


func _on_out_switch_sides_pressed():
	var name_item = get_selected_out_name()
	var names = map.get_cargo_index_to_name()
	var cargo_index = -1
	for index in names:
		if names[index] == name_item:
			cargo_index = index
			request_swap_to_in(location, index)
			break

func _on_in_switch_sides_pressed():
	var name_item = get_selected_in_name()
	var names = map.get_cargo_index_to_name()
	var cargo_index = -1
	for index in names:
		if names[index] == name_item:
			cargo_index = index
			request_swap_to_out(location, index)
			break

@rpc("any_peer", "call_local", "unreliable")
func request_swap_to_out(coords: Vector2i, index: int):
	map.request_swap_to_out(coords, index)

@rpc("any_peer", "call_local", "unreliable")
func request_swap_to_in(coords: Vector2i, index: int):
	map.request_swap_to_in(coords, index)
