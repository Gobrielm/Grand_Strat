extends Window
var location = null
var hold_name: String
var current_cargo: Dictionary
var current_prices: Dictionary
var current_cash: int

const time_every_update = 1
var progress: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
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
		request_current_cargo.rpc_id(1, location)
		request_current_name.rpc_id(1, location)
		request_current_prices.rpc_id(1, location)
		request_current_cash.rpc_id(1, location)

@rpc("any_peer", "call_local", "unreliable")
func request_current_name(coords: Vector2i):
	var current_name = terminal_map.tile_info.get_hold_name(coords)
	update_current_name.rpc_id(multiplayer.get_remote_sender_id(), current_name)

@rpc("any_peer", "call_local", "unreliable")
func request_current_cargo(coords: Vector2i):
	var dict = terminal_map.get_cargo_array_at_location(coords)
	update_current_cargo.rpc_id(multiplayer.get_remote_sender_id(), dict)

@rpc("any_peer", "call_local", "unreliable")
func request_current_cash(coords: Vector2i):
	var current_cash = terminal_map.get_cash_of_firm(coords)
	update_current_cash.rpc_id(multiplayer.get_remote_sender_id(), current_cash)

@rpc("any_peer", "call_local", "unreliable")
func request_current_prices(coords: Vector2i):
	var dict = terminal_map.get_local_prices(coords)
	update_current_prices.rpc_id(multiplayer.get_remote_sender_id(), dict)

@rpc("authority", "call_local", "unreliable")
func update_current_cargo(new_current_cargo: Dictionary):
	current_cargo = new_current_cargo
	factory_window()

@rpc("authority", "call_local", "unreliable")
func update_current_name(new_name: String):
	hold_name = new_name
	$Name.text = "[center][font_size=30]" + hold_name + "[/font_size][/center]"

@rpc("authority", "call_local", "unreliable")
func update_current_cash(new_cash: int):
	current_cash = new_cash
	$Cash.text = "$" + str(current_cash)

@rpc("authority", "call_local", "unreliable")
func update_current_prices(new_prices: Dictionary):
	current_prices = new_prices
	display_current_prices()

func factory_window():
	var cargo_list: ItemList = $Cargo_Node/Cargo_List
	var names = terminal_map.get_cargo_dict()
	var selected_name = get_selected_name()
	
	for i in cargo_list.item_count:
		cargo_list.remove_item(0)
	for cargo in current_cargo.size():
		if current_cargo[cargo] != 0:
			var cargo_name: String = names[cargo]
			cargo_list.add_item(cargo_name + ", " + str(current_cargo[cargo]))
			if cargo_name == selected_name:
				cargo_list.select(cargo)

func display_current_prices():
	var price_list: ItemList = $Price_Node/Price_List
	price_list.clear()
	var names = terminal_map.get_cargo_dict()
	for i in current_prices:
		price_list.add_item(names[i] + ": " + str(current_prices[i]))

func get_selected_name() -> String:
	var cargo_list: ItemList = $Cargo_Node/Cargo_List
	var selected_items: Array = cargo_list.get_selected_items()
	if selected_items.size() > 0:
		var toReturn = ""
		for i in cargo_list.get_item_text(selected_items[0]):
			if i == ',':
				break
			toReturn += i
		return toReturn
	return ""
	
