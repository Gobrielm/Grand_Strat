class_name state_machine extends Node

static var building = false
static var building_many_rails = false
static var hovering_over_gui = false
static var controlling_camera = false
static var unit_selected = false
static var building_units = false
static var selecting_route = false
static var picking_nation = false

static func print_all():
	print(building)
	print(building_many_rails)
	print(hovering_over_gui)
	print(controlling_camera)
	print(unit_selected)
	print(building_units)
	print(selecting_route)
	print(picking_nation)
	print("-----------")

static func default():
	all_off()
	controlling_camera = true

static func all_off():
	building = false
	building_many_rails = false
	hovering_over_gui = false
	controlling_camera = false
	unit_selected = false
	building_units = false
	selecting_route = false
	picking_nation = false

static func gui_button_pressed():
	all_off()
	building = true

static func gui_button_unpressed():
	building = false
	default()

static func unpress_gui():
	building = false
	building_many_rails = false
	default()

static func many_track_button_toggled():
	building_many_rails = !building_many_rails
	if building_many_rails:
		all_off()
		building_many_rails = true
	else:
		default()

static func track_button_toggled():
	building = !building
	if building:
		all_off()
		building = true
	else:
		default()

static func depot_button_toggled():
	building = !building
	if building:
		all_off()
		building = true
	else:
		default()

static func station_button_toggled():
	building = !building
	if building:
		all_off()
		building = true
	else:
		default()

static func is_building_many_rails() -> bool:
	return building_many_rails and !hovering_over_gui

static func is_controlling_camera() -> bool:
	return controlling_camera

static func is_building() -> bool:
	return building and !hovering_over_gui

static func is_selecting_unit() -> bool:
	return unit_selected and !hovering_over_gui

static func click_unit():
	all_off()
	unit_selected = true

static func unclick_unit():
	unit_selected = false
	controlling_camera = true

static func start_building_units():
	all_off()
	building_units = true

static func stop_building_units():
	all_off()
	default()

static func is_building_units() -> bool:
	return building_units and !hovering_over_gui

static func start_selecting_route():
	all_off()
	selecting_route = true

static func stop_selecting_route():
	all_off()
	default()

static func is_selecting_route() -> bool:
	return selecting_route and !hovering_over_gui

static func start_picking_nation():
	all_off()
	picking_nation = true

static func stop_picking_nation():
	all_off()
	default()

static func is_picking_nation() -> bool:
	return picking_nation and !hovering_over_gui

static func hovering_over_gui_active():
	hovering_over_gui = true

static func hovering_over_gui_inactive():
	hovering_over_gui = false

static func is_hovering_over_gui() -> bool:
	return hovering_over_gui
