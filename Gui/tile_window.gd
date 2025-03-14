extends Window

var coords: Vector2i

func open_window(_coords: Vector2i):
	coords = _coords
	$Control/Coords.text = str(coords)
	$Control/Biome.text = Utils.world_map.get_biome_name(coords)
	popup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_close_requested():
	hide()

func _on_focus_exited():
	hide()
