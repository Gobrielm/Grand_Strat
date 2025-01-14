extends TileMapLayer

var map: TileMapLayer
var unit_creator
var unit_data: Dictionary = {}
var temp_unit_data: Dictionary = {}
var battle_script
var selected_coords: Vector2i

var units_to_kill = []
var units_to_retreat = []

var state_machine

func _ready():
	battle_script = load("res://Units/unit_managers/battle_script.gd").new(self)
	unit_creator = load("res://Units/unit_managers/unit_creator.gd").new()
	map = get_parent()

func _input(event):
	if event.is_action_pressed("deselect"):
		if state_machine.is_selecting_unit():
			set_selected_unit_route(get_selected_coords(), map.get_cell_position())
			set_selected_unit_route.rpc_id(1, get_selected_coords(), map.get_cell_position())
			map.update_info_window(get_unit_client_array(get_selected_coords()))

func assign_state_machine(new_state_machine):
	state_machine = new_state_machine

func send_data_to_clients():
	map.refresh_unit_map.rpc(get_used_cells_dictionary())

@rpc("any_peer", "call_remote", "unreliable")
func request_refresh_map():
	map.refresh_unit_map.rpc_id(multiplayer.get_remote_sender_id(), get_used_cells_dictionary())

@rpc("authority", "call_remote", "unreliable")
func refresh_map(_visible_tiles: Array, _unit_atlas: Dictionary):
	pass

@rpc("any_peer", "call_remote", "unreliable")
func request_refresh(tile: Vector2i):
	var sender_id = multiplayer.get_remote_sender_id()
	if unit_data.has(tile):
		refresh_unit.rpc_id(sender_id, unit_data[tile].convert_to_client_array())

func get_used_cells_dictionary() -> Dictionary:
	var toReturn: Dictionary = {}
	for tile in get_used_cells():
		toReturn[tile] = get_cell_atlas_coords(tile)
	return toReturn

func tile_has_enemy_unit(tile_to_check: Vector2i, player_id):
	return unit_data.has(tile_to_check) and unit_data[tile_to_check].get_player_id() != player_id

func tile_has_no_unit(tile_to_check: Vector2i) -> bool:
	return !unit_data.has(tile_to_check)

func is_player_id_match(coords: Vector2i, player_id: int) -> bool:
	return unit_data.has(coords) and unit_data[coords].get_player_id() == player_id

#Creating Units
@rpc("any_peer", "call_local", "unreliable")
func check_before_create(coords: Vector2i, type: int, player_id: int):
	var unit_class = get_unit_class(type)
	var cost = unit_class.get_cost()
	if !unit_data.has(coords) and map.player_has_enough_money(player_id, cost):
		map.remove_money(player_id, cost)
		create_unit.rpc(coords, type, player_id)

@rpc("authority", "call_local", "unreliable")
func create_unit(coords: Vector2i, type: int, player_id: int):
	set_cell(coords, 0, Vector2i(0, type))
	var unit_class = get_unit_class(type)
	unit_data[coords] = unit_class.new(coords, player_id)
	create_label(coords, str(unit_data[coords]))
	prepare_refresh_unit(unit_data[coords])
	

func get_unit_class(type):
	return unit_creator.get_unit_class(type)

func create_label(coords: Vector2i, text: String):
	var label: Label = Label.new()
	label.name = "Label"
	var node = Control.new()
	add_child(node)
	node.add_child(label)
	node.name = str(coords)
	label.text = text
	move_label(coords, coords)
	label.position = Vector2(-label.size.x / 2, label.size.y)
	var morale_bar = create_morale_bar(label.size)
	node.add_child(morale_bar)
	var manpower_label = create_manpower_label(label.size)
	node.add_child(manpower_label)

func create_morale_bar(size: Vector2) -> ProgressBar:
	var morale_bar: ProgressBar = ProgressBar.new()
	morale_bar.name = "MoraleBar"
	morale_bar.show_percentage = false
	morale_bar.value = 100
	morale_bar.size = size
	morale_bar.position = Vector2(-size.x / 2, size.y * 2)
	var background_color = StyleBoxFlat.new()
	background_color.bg_color = Color(1, 1, 1, 0)
	var fill_color = StyleBoxFlat.new()
	fill_color.bg_color = Color(0.5, 1, 0.5, 1)
	morale_bar.add_theme_stylebox_override("background", background_color)
	morale_bar.add_theme_stylebox_override("fill", fill_color)
	return morale_bar

func create_manpower_label(size: Vector2) -> RichTextLabel:
	var manpower_label: RichTextLabel = RichTextLabel.new()
	manpower_label.name = "Manpower_Label"
	manpower_label.size = size
	manpower_label.bbcode_enabled = true
	manpower_label.text = "[center]" + str(0) + "[/center]"
	manpower_label.position = Vector2(-size.x / 2, size.y * 2)
	return manpower_label

#Moving Units
@rpc("any_peer", "call_local", "unreliable")
func set_selected_unit_route(coords: Vector2i, move_to: Vector2i):
	if unit_data.has(coords) and unit_data[coords].get_player_id() == multiplayer.get_remote_sender_id():
		var soldier_data: base_unit = unit_data[coords]
		set_unit_route(soldier_data, move_to)
		refresh_unit.rpc_id(multiplayer.get_remote_sender_id(), soldier_data.convert_to_client_array())
		
func get_selected_coords() -> Vector2i:
	return selected_coords

func set_unit_route(unit_to_move: base_unit, move_to: Vector2i):
	unit_to_move.set_route(dfs_to_destination(unit_to_move.get_location(), move_to))
	if unit_to_move.get_player_id() == multiplayer.get_unique_id():
		$dest_sound.play(0.3)
		highlight_dest()

func check_move(coords: Vector2i):
	var unit: base_unit = unit_data[coords]
	var move_to = unit.pop_next_location()
	if next_location_is_available(move_to):
		move_unit.rpc(coords, move_to)
	elif !unit.is_route_empty():
		var end = unit.get_destination()
		set_selected_unit_route(selected_coords, end)

@rpc("authority", "call_local", "unreliable")
func move_unit(coords: Vector2i, move_to: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(coords)
	var soldier_data: base_unit = unit_data[coords]
	soldier_data.set_location(move_to)
	erase_cell(coords)
	set_cell(move_to, 0, soldier_atlas)
	unit_data.erase(coords)
	unit_data[move_to] = soldier_data
	if coords == selected_coords:
		selected_coords = move_to
	move_label(coords, move_to)
	if soldier_data.get_destination() == null:
		map.clear_highlights()

func move_label(coords: Vector2i, move_to: Vector2i):
	var node = get_node(str(coords))
	node.name = str(move_to)
	node.position = map_to_local(move_to)

func location_is_attack(coords_of_defender: Vector2i, attacker: base_unit) -> bool:
	return unit_data.has(coords_of_defender) and unit_data[coords_of_defender].get_player_id() != attacker.get_player_id()

func next_location_is_available(coords: Vector2i) -> bool:
	return !unit_data.has(coords)

func dfs_to_destination(coords: Vector2i, destination: Vector2i) -> Array:
	#FIXME
	var current
	var unit = unit_data[coords]
	var queue: priority_queue = priority_queue.new()
	var tile_to_prev = {}
	var visited = {}
	var found = false
	queue.add_item(0, coords)
	while !queue.is_empty():
		current = queue.pop_top()
		if current == destination or found:
			found = true
			break
		for tile in map.get_surrounding_cells(current):
			if !visited.has(tile) and map.is_tile_traversable(tile) and tile_has_no_unit(tile):
				queue.add_item(tile.distance_to(destination), tile)
				visited[tile] = true
				tile_to_prev[tile] = current
			elif tile == destination:
				if tile_has_enemy_unit(tile, unit.get_player_id()):
					tile_to_prev[tile] = current
					found = true
					break
				return create_route_from_tile_to_prev(coords, current, tile_to_prev)
	if found:
		return create_route_from_tile_to_prev(coords, destination, tile_to_prev)
	else:
		return []
	
func create_route_from_tile_to_prev(start: Vector2i, destination: Vector2i, tile_to_prev: Dictionary) -> Array:
	var current = destination
	var route = []
	while current != start:
		route.push_front(current)
		current = tile_to_prev[current]
	return route

func unit_battle(attacker: base_unit, defender: base_unit):
	var result = battle_script.unit_battle(attacker, defender)
	#Defender killed
	if result == 0:
		units_to_kill.append(defender)
	#Defender retreated
	elif result == 1:
		units_to_retreat.append(defender)
	#Attacker killed
	elif result == 2:
		units_to_kill.append(attacker)
	#Attacker retreated
	elif result == 3:
		units_to_retreat.append(attacker)

@rpc("authority", "call_local", "unreliable")
func kill_unit(coords: Vector2i):
	var node: Control = get_node(str(coords))
	for child in node.get_children():
		child.queue_free()
	node.queue_free()
	unit_data[coords].queue_free()
	unit_data.erase(coords)
	erase_cell(coords)

#Selecting Units

func get_selected_unit() -> base_unit:
	if unit_data.has(selected_coords):
		return unit_data[selected_coords]
	return null

func unit_is_owned(coords: Vector2i) -> bool:
	return unit_data.has(coords) and unit_data[coords].get_player_id() == multiplayer.get_unique_id()

func select_unit(coords: Vector2i, player_id: int):
	unhightlight_name()
	selected_coords = coords
	highlight_dest()
	highlight_name()
	if is_player_id_match(coords, player_id):
		var soldier_atlas = get_cell_atlas_coords(coords)
		if soldier_atlas != Vector2i(-1, -1):
			$select_unit_sound.play(0.5)
			map.click_unit()
	else:
		map.close_unit_box()

func highlight_name():
	if has_node(str(selected_coords)) and unit_is_owned(selected_coords):
		var node = get_node(str(selected_coords))
		var unit_name: Label = node.get_node("Label")
		unit_name.add_theme_color_override("font_color", Color(1, 0, 0, 1))

func unhightlight_name():
	if has_node(str(selected_coords)):
		var node = get_node(str(selected_coords))
		var unit_name: Label = node.get_node("Label")
		unit_name.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func highlight_dest():
	if unit_data.has(selected_coords):
		var unit = unit_data[selected_coords]
		if unit.get_destination() != null and unit_is_owned(selected_coords):
			map.highlight_cell(unit.get_destination())
		else:
			map.clear_highlights()
	else:
		map.clear_highlights()

func is_unit_double_clicked(coords: Vector2i, player_id: int) -> bool:
	return is_player_id_match(coords, player_id) and selected_coords == coords

func _process(delta):
	for location: Vector2i in unit_data:
		var unit: base_unit = unit_data[location]
		if units_to_kill.has(unit):
		 #or units_to_retreat.has(unit):
			continue
		unit.update_progress(delta)
		var next_location = unit.get_next_location()
		if next_location != location:
			#TODO: Terrain check
			var terrain = map.get_cell_tile_data(next_location).terrain
			if unit.ready_to_move(100.0 / unit.get_speed() / unit.get_speed_mult(terrain)):
				var next_next_location = unit.get_next_location(1)
				if location_is_attack(next_next_location, unit) and unit.get_unit_range() >= 2:
					unit_battle(unit, unit_data[next_next_location])
					prepare_refresh_unit(unit_data[next_next_location])
				elif location_is_attack(next_location, unit):
					unit_battle(unit, unit_data[next_location])
					prepare_refresh_unit(unit_data[next_location])
				else:
					check_move(location)
				prepare_refresh_unit(unit)
	retreat_units()
	clean_up_killed_units()

func prepare_refresh_unit(unit: base_unit):
	var info_array = unit.convert_to_client_array()
	refresh_unit.rpc(info_array)

func get_unit_client_array(coords: Vector2i) -> Array:
	if unit_data.has(coords):
		return unit_data[coords].convert_to_client_array()
	return []

@rpc("authority", "call_local", "unreliable")
func refresh_unit(info_array: Array):
	var coords = info_array[1]
	if coords == selected_coords:
		map.update_info_window(info_array)
	var morale_bar: ProgressBar = get_node(str(coords)).get_node("MoraleBar")
	morale_bar.value = info_array[4]
	var manpower_label: RichTextLabel = get_node(str(coords)).get_node("Manpower_Label")
	manpower_label.text = "[center]" + str(info_array[3]) + "[/center]"

func clean_up_killed_units():
	for unit in units_to_kill:
		kill_unit.rpc(unit.get_location())
	units_to_kill.clear()

func retreat_units():
	for unit: base_unit in units_to_retreat:
		set_unit_route(unit, find_surrounding_open_tile(unit.get_location()))
	units_to_retreat.clear()

func find_surrounding_open_tile(coords: Vector2i) -> Vector2i:
	for cell in map.get_surrounding_cells(coords):
		if map.is_tile_traversable(cell) and tile_has_no_unit(cell):
			return cell
	units_to_kill.append(unit_data[coords])
	return coords

func get_additional_aura_boost() -> Dictionary:
	var adjacent_officer = {}
	for cell: Vector2i in get_used_cells():
		if unit_data.has(cell) and unit_data[cell] is officer:
			for adj_cell in get_surrounding_cells(cell):
				if adjacent_officer.has(adj_cell) and adjacent_officer[adj_cell] > unit_data[cell].get_aura_boost():
					continue
				adjacent_officer[adj_cell] = unit_data[cell].get_aura_boost()
	return adjacent_officer

func _on_regen_timer_timeout():
	var boosts: Dictionary = get_additional_aura_boost()
	for unit: base_unit in unit_data.values():
		var player_id = unit.get_player_id()
		var amount = round(unit.get_max_manpower() / 80 + 12)
		var max_cost = round(amount * 0.3)
		var multiple = 1
		if boosts.has(unit.get_location()):
			multiple = boosts[unit.get_location()]
		unit.add_experience(multiple)
		if map.player_has_enough_money(player_id, max_cost):
			var manpower_used = unit.add_manpower(amount)
			var cost = round(manpower_used * 0.3)
			map.remove_money(player_id, cost)
			unit.add_morale(10)
		else:
			unit.remove_morale(10)
		refresh_unit.rpc(unit.convert_to_client_array())
		
		
	
