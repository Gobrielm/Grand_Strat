extends TileMapLayer

var unit_creator

# Called when the node enters the scene tree for the first time.
func _ready():
	unit_creator = load("res://Units/unit_managers/unit_creator.gd").new()

@rpc("any_peer", "call_remote", "unreliable")
func create_unit(coords: Vector2i, type: int, player_id: int):
	set_cell(coords, 0, Vector2i(0, type))
	var unit_class = unit_creator.get_unit_class(type)
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

func move_label(coords: Vector2i, move_to: Vector2i):
	var node = get_node(str(coords))
	node.name = str(move_to)
	node.position = map_to_local(move_to)
