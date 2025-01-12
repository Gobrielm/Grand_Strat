extends TileMapLayer

var unit_creator
var selected_coords
var map: TileMapLayer
var unit_data: Dictionary = {}

const client_unit = preload("res://Client_Objects/client_base_unit.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	unit_creator = load("res://Units/unit_managers/unit_creator.gd").new()
	map = get_parent()

@rpc("authority", "call_remote", "reliable")
func refresh_map(visible_tiles: Array, unit_atlas: Dictionary):
	for coords in visible_tiles:
		if !unit_atlas.has(coords):
			kill_unit(coords)
		elif get_cell_atlas_coords(coords) == unit_atlas[coords]:
			request_refresh.rpc_id(1, coords, multiplayer.get_unique_id())
		else:
			create_unit(coords, unit_atlas[coords].y, 0)
			request_refresh.rpc_id(1, coords, multiplayer.get_unique_id())

@rpc("any_peer", "call_remote", "unreliable")
func request_refresh(tile: Vector2i):
	pass

@rpc("authority", "call_local", "unreliable")
func refresh_unit(unit_info: Array):
	
	var coords: Vector2i = unit_info[1]
	if !unit_data.has(coords):
		#TODO: Unit exists server-side, desync
		return
	var unit_node = get_node(str(coords))
	unit_data[coords].update_stats(unit_info)
	var morale_bar = unit_node.get_node(str("MoraleBar"))
	morale_bar.value = unit_info[4]
	var manpower_label: RichTextLabel = get_node(str(coords)).get_node("Manpower_Label")
	manpower_label.text = "[center]" + str(unit_info[3]) + "[/center]"

func get_unit_client_array(coords: Vector2i) -> Array:
	if unit_data.has(coords):
		return unit_data[coords].convert_to_client_array()
	return []

@rpc("any_peer", "call_local", "unreliable")
func check_before_create(coords: Vector2i, type: int, player_id: int):
	pass

@rpc("authority", "call_remote", "unreliable")
func create_unit(coords: Vector2i, type: int, player_id: int):
	set_cell(coords, 0, Vector2i(0, type))
	unit_data[coords] = client_unit.new(coords, player_id)
	var unit_class = unit_creator.get_unit_class(type)
	create_label(coords, str(unit_class.toString()))
	request_refresh.rpc_id(1, coords)

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

@rpc("authority", "call_local", "unreliable")
func move_unit(coords: Vector2i, move_to: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(coords)
	if coords != move_to:
		unit_data[move_to] = unit_data[coords]
		unit_data.erase(coords)
	erase_cell(coords)
	set_cell(move_to, 0, soldier_atlas)
	move_label(coords, move_to)
	if selected_coords == coords:
		selected_coords = move_to

func select_unit(coords: Vector2i, player_id: int):
	unhightlight_name()
	selected_coords = coords
	highlight_selected_dest()
	if selected_unit_exists_and_owned(player_id):
		map.click_unit()
		$select_unit_sound.play(0.5)
		highlight_name()

func highlight_name():
	if has_node(str(selected_coords)):
		var node = get_node(str(selected_coords))
		var unit_name: Label = node.get_node("Label")
		unit_name.add_theme_color_override("font_color", Color(1, 0, 0, 1))

func unhightlight_name():
	if has_node(str(selected_coords)):
		var node = get_node(str(selected_coords))
		var unit_name: Label = node.get_node("Label")
		unit_name.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func highlight_dest(destination):
	if unit_data.has(selected_coords):
		if destination != null:
			map.highlight_cell(destination)
		else:
			map.clear_highlights()
	else:
		map.clear_highlights()

func highlight_selected_dest():
	if unit_data.has(selected_coords):
		var unit = unit_data[selected_coords]
		if unit.get_destination() != null:
			map.highlight_cell(unit.get_destination())
		else:
			map.clear_highlights()
	else:
		map.clear_highlights()

func selected_unit_exists_and_owned(unique_id: int) -> bool:
	return unit_data.has(selected_coords) and unit_data[selected_coords].get_player_id() == unique_id

@rpc("any_peer", "call_local", "unreliable")
func set_selected_unit_route(_coords: Vector2i, move_to: Vector2i):
	$dest_sound.play(0.3)
	highlight_dest(move_to)

func get_selected_coords() -> Vector2i:
	return selected_coords

func is_unit_double_clicked(coords: Vector2i, unique_id: int):
	return selected_coords == coords and selected_unit_exists_and_owned(unique_id)

func move_label(coords: Vector2i, move_to: Vector2i):
	var node = get_node(str(coords))
	node.name = str(move_to)
	node.position = map_to_local(move_to)

@rpc("authority", "call_local", "unreliable")
func kill_unit(coords: Vector2i):
	if get_cell_atlas_coords(coords) == Vector2i(-1, -1):
		return
	erase_cell(coords)
	unit_data[coords].queue_free()
	unit_data.erase(coords)
	var node = get_node(str(coords))
	for child in node.get_children():
		child.queue_free()
	node.queue_free()
