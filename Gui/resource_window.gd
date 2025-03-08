extends Window


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in terminal_map.amount_of_primary_goods:
		$ItemList.add_item(terminal_map.get_cargo_name(i))
	var file: String = "res://Gui/resource_window.tscn"
	var scene = PackedScene.new()
	scene.pack(get_tree().get_current_scene())
	if FileAccess.file_exists(file):
		var error = ResourceSaver.save(scene, file)
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
