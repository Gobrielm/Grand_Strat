extends Window

signal resource_window_picked

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_close_requested():
	hide()

func _on_item_list_item_selected(index):
	$ItemList.deselect_all()
	resource_window_picked.emit(index)
	hide()
