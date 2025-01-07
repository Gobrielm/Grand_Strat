extends Window

func show_unit(unit: base_unit):
	$stat_label.text = "manpower: " + str(unit.get_manpower()) + '\n' + "morale: " + str(unit.get_morale())
	$destination_label.text = "destination: " + str(unit.get_destination())
	popup()


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_close_requested():
	hide()
