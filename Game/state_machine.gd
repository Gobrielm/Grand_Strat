extends Node

var building = false
var building_many_rails = false
var hovering_over_gui = false
var controlling_camera = false
var unit_selected = false
var building_units = false

func default():
	all_off()
	controlling_camera = true

func all_off():
	building = false
	building_many_rails = false
	hovering_over_gui = false
	controlling_camera = false
	unit_selected = false
	building_units = false

func gui_button_pressed():
	all_off()
	building = true

func gui_button_unpressed():
	building = false
	default()

func unpress_gui():
	building = false
	building_many_rails = false
	default()

func many_track_button_toggled():
	building_many_rails = !building_many_rails
	if building_many_rails:
		all_off()
		building_many_rails = true
	else:
		default()

func track_button_toggled():
	building = !building
	if building:
		all_off()
		building = true
	else:
		default()

func depot_button_toggled():
	building = !building
	if building:
		all_off()
		building = true
	else:
		default()

func station_button_toggled():
	building = !building
	if building:
		all_off()
		building = true
	else:
		default()

func is_building_many_rails() -> bool:
	return building_many_rails

func is_controlling_camera() -> bool:
	return controlling_camera

func is_building() -> bool:
	return building

func is_selecting_unit() -> bool:
	return unit_selected

func click_unit():
	unit_selected = !unit_selected
	if click_unit:
		all_off()
		unit_selected = true
	else:
		default()

func start_building_units():
	all_off()
	building_units = true

func stop_building_units():
	all_off()
	default()

func is_building_units() -> bool:
	return building_units
