extends Window

func show_unit(unit_info_array: Array):
	update_unit(unit_info_array)
	popup()

func update_unit(unit_info_array: Array):
	if !unit_info_array.is_empty():
		$stat_label.text = "manpower: " + str(unit_info_array[3]) + '\n' + "morale: " + str(unit_info_array[4])
		$destination_label.text = "destination: " + str(unit_info_array[2])

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_close_requested():
	hide()
