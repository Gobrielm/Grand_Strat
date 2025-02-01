extends Window

signal selected_good

var completed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func _on_about_to_popup():
	if !completed:
		var cargo_list: ItemList = $Control/Cargo_List
		for type: String in terminal_map.get_cargo_dict().values():
			cargo_list.add_item(type)
		completed = true

func _on_cargo_list_item_selected(index):
	hide()
	$Control/Cargo_List.deselect(index)
	selected_good.emit(index)
	
