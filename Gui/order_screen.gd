extends Control

@onready var station_window = get_parent()

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

func _on_order_window_selected_good(type: int):
	var location = station_window.get_location()
	var good_name = terminal_map.get_cargo_name(type)
	var count = $Cargo_List.item_count
	for item in count:
		if $Cargo_List.get_item_text(item).begins_with(good_name):
			return
	$Cargo_List.add_item(terminal_map.get_cargo_name(type) + ": 1")
	terminal_map.add_order_station(location, type, true)

func remove_order(index: int):
	var text: String = $Cargo_List.get_item_text(index)
	text = text.left(text.length() - 3)
	var location = station_window.get_location()
	var type = terminal_map.get_cargo_type(text)
	terminal_map.remove_order_station(location, type)
	$Cargo_List.remove_item(index)
