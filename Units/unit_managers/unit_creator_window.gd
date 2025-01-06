extends Window
var type_selected
var map: TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready():
	map = get_parent()
	hide()

func _on_close_requested():
	hide()

func clear_type_selected():
	type_selected = null

func _on_infantry_button_pressed():
	type_selected = infantry
	map.start_building_units()
	hide()


func _on_calvary_button_pressed():
	type_selected = calvary
	map.start_building_units()
	hide()


func _on_artillery_button_pressed():
	type_selected = artillery
	map.start_building_units()
	hide()


func _on_engineer_button_pressed():
	type_selected = engineer
	map.start_building_units()
	hide()


func _on_officer_button_pressed():
	type_selected = officer
	map.start_building_units()
	hide()

func get_type_selected():
	return type_selected
