extends Control

@onready var station_window = get_parent()

var buy_icon = preload("res://Gui/Icons/buy.png")
var sell_icon = preload("res://Gui/Icons/sell.png")

func _input(event):
	if event.is_action_pressed("delete"):
		var index = get_selected_item()
		if index != -1:
			remove_order(index)
		

func get_selected_item() -> int:
	var items: Array = $Cargo_List.get_selected_items()
	if items.size() == 0:
		return -1
	else:
		return items[0]

func _on_add_order_pressed():
	$Order_Window.popup()

func _on_order_window_placed_order(type: int, amount: int, buy: bool):
	var location = station_window.get_location()
	var good_name = terminal_map.get_cargo_name(type)
	var count = $Cargo_List.item_count
	for item in count:
		if $Cargo_List.get_item_text(item).begins_with(good_name):
			edit_order(item, type, amount, buy)
			terminal_map.edit_order_station(location, type, amount, buy)
			return
	create_order_locally(type, amount, buy)
	terminal_map.edit_order_station(location, type, amount, buy)

func edit_order(index: int, type: int, amount: int, buy: bool):
	set_order_icon(index, buy)
	$Cargo_List.set_item_text(index, terminal_map.get_cargo_name(type) + ": " + str(amount))

func create_order_locally(type: int, amount: int, buy: bool):
	$Cargo_List.add_item(terminal_map.get_cargo_name(type) + ": " + str(amount))
	set_order_icon($Cargo_List.item_count - 1, buy)

func set_order_icon(index: int, buy: bool):
	if buy:
		$Cargo_List.item_count
		$Cargo_List.set_item_icon(index, buy_icon)
	else:
		$Cargo_List.set_item_icon(index, sell_icon)

func remove_order(index: int):
	var text: String = $Cargo_List.get_item_text(index)
	while text.length() > 0:
		var arg: String = text.right(1)
		if !arg.is_valid_int() and !arg == ":" and !arg == " ":
			break
		text = text.left(text.length() - 1)
	
	var location = station_window.get_location()
	var type = terminal_map.get_cargo_type(text)
	terminal_map.remove_order_station(location, type)
	$Cargo_List.remove_item(index)
