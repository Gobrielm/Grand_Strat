extends Window

var coords: Vector2i

func open_window(_coords: Vector2i):
	#var resolution: Vector2i = get_tree().root.content_scale_size
	position = Vector2i(0, 0)
	coords = _coords
	$Control/Coords.text = str(coords)
	request_biome.rpc_id(1, coords)
	request_resources_available.rpc_id(1, coords)
	popup()

@rpc("any_peer", "call_local")
func request_biome(coords: Vector2i):
	set_biome.rpc_id(multiplayer.get_remote_sender_id(), Utils.world_map.get_biome_name(coords))

@rpc("authority", "call_local")
func set_biome(biome: String):
	$Control/Biome.text = biome

@rpc("any_peer", "call_local")
func request_resources_available(coords: Vector2i):
	var resource_dict := terminal_map.get_available_resources(coords)
	set_resources_available.rpc_id(multiplayer.get_remote_sender_id(), resource_dict)

@rpc("authority", "call_local")
func set_resources_available(resource_dict: Dictionary):
	$Control/ItemList.clear()
	for type in resource_dict:
		var mag = resource_dict[type]
		$Control/ItemList.add_item(terminal_map.get_cargo_name(type) + " - " + str(mag))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_close_requested():
	hide()

func _on_close_pressed():
	hide()
