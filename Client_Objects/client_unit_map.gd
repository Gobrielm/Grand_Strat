extends TileMapLayer

var unit_creator
var unit_selected_coords
var map: TileMapLayer
var unit_data: Dictionary = {}

const client_unit = preload("res://Client_Objects/client_base_unit.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	unit_creator = load("res://Units/unit_managers/unit_creator.gd").new()
	map = get_parent()

@rpc("authority", "call_remote", "unreliable")
func refresh_map(visible_tiles: Array, unit_atlas: Dictionary):
	for coords in visible_tiles:
		if !unit_atlas.has(coords):
			erase_unit(coords)
		elif get_cell_atlas_coords(coords) == unit_atlas[coords]:
			request_refresh.rpc_id(1, coords, multiplayer.get_unique_id())
		else:
			create_unit(coords, unit_atlas[coords])
			request_refresh.rpc_id(1, coords, multiplayer.get_unique_id())

@rpc("any_peer", "call_remote", "unreliable")
func request_refresh(tile: Vector2i, sender_id: int):
	pass

@rpc("any_peer", "call_remote", "unreliable")
func refresh_unit(tile: Vector2i, unit_info: Array):
	var unit_node = get_node(str(tile))
	unit_data[tile].update_stats(unit_info)
	var morale_bar = unit_node.get_node(str("ProgressBar"))
	morale_bar.value = unit_info[2]

func create_unit(coords: Vector2i, atlas: Vector2i):
	set_cell(coords, 0, atlas)
	unit_data[coords] = client_unit.new()
	var unit_class = unit_creator.get_unit_class(atlas.y)
	create_label(coords, str(unit_class.toString()))

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
	var progress_bar = create_progress_bar(label.size)
	node.add_child(progress_bar)

func create_progress_bar(size: Vector2) -> ProgressBar:
	var progress_bar: ProgressBar = ProgressBar.new()
	progress_bar.name = "ProgressBar"
	progress_bar.show_percentage = false
	progress_bar.value = 100
	progress_bar.size = size
	progress_bar.position = Vector2(-size.x / 2, size.y * 2)
	var background_color = StyleBoxFlat.new()
	background_color.bg_color = Color(1, 1, 1, 0)
	var fill_color = StyleBoxFlat.new()
	fill_color.bg_color = Color(0.5, 1, 0.5, 1)
	progress_bar.add_theme_stylebox_override("background", background_color)
	progress_bar.add_theme_stylebox_override("fill", fill_color)
	return progress_bar

func move_unit(coords: Vector2i, move_to: Vector2i):
	var soldier_atlas = get_cell_atlas_coords(coords)
	erase_cell(coords)
	set_cell(move_to, 0, soldier_atlas)
	move_label(coords, move_to)

@rpc("any_peer", "call_local", "unreliable")
func select_unit(coords: Vector2i, player_id: int):
	unit_selected_coords = coords

func selected_unit_exists_and_owned() -> bool:
	return unit_data.has(unit_selected_coords) and unit_data[unit_selected_coords].get_owned()

func get_selected_unit() -> base_unit:
	if selected_unit_exists_and_owned():
		map.click_unit()
		return unit_data[unit_selected_coords]
	return null

func is_unit_double_clicked(coords: Vector2i, _unique_id: int):
	return unit_selected_coords == coords and selected_unit_exists_and_owned()

func move_label(coords: Vector2i, move_to: Vector2i):
	var node = get_node(str(coords))
	node.name = str(move_to)
	node.position = map_to_local(move_to)

func erase_unit(coords: Vector2i):
	if get_cell_atlas_coords(coords) == Vector2i(-1, -1):
		return
	erase_cell(coords)
	var node = get_node(str(coords))
	for child in node.get_children():
		child.queue_free()
	node.queue_free()
