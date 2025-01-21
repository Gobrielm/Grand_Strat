extends Window
var location = null
var hold_name: String
var current_cargo: Dictionary

const time_every_update = 1
var progress: float = 0.0

var map: TileMapLayer
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	map = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress += delta
	if progress > time_every_update:
		refresh_window()

func _on_close_requested():
	hide()

func open_window(new_location: Vector2i):
	location = new_location
	refresh_window()
	popup()

func refresh_window():
	progress = 0
	if location != null:
		request_current_cargo.rpc_id(1, location)
		request_current_name.rpc_id(1, location)
		station_window()

@rpc("any_peer", "call_local", "unreliable")
func request_current_name(coords: Vector2i):
	var current_name = map.tile_info.get_hold_name(coords)
	update_current_name.rpc_id(multiplayer.get_remote_sender_id(), current_name)

@rpc("any_peer", "call_local", "unreliable")
func request_current_cargo(coords: Vector2i):
	var dict = map.get_cargo_array_at_location(coords)
	update_current_cargo.rpc_id(multiplayer.get_remote_sender_id(), dict)

@rpc("authority", "call_local", "unreliable")
func update_current_cargo(new_current_cargo: Dictionary):
	current_cargo = new_current_cargo

@rpc("authority", "call_local", "unreliable")
func update_current_name(new_name: String):
	hold_name = new_name

func station_window():
	$Name.text = "[center][font_size=30]" + hold_name + "[/font_size][/center]"
	var cargo_list: ItemList = $Cargo_Node/Cargo_List
	for i in cargo_list.item_count:
		cargo_list.remove_item(0)
	var names = map.get_cargo_index_to_name()
	for cargo in current_cargo.size():
		var cargo_name: String = names[cargo]
		if current_cargo[cargo] != 0:
			cargo_list.add_item(cargo_name + ", " + str(current_cargo[cargo]))
	
