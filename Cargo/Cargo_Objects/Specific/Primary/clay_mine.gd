extends base_factory

func _init(new_location: Vector2i):
	var dict = {}
	dict[terminal_map.get_cargo_type("clay")] = 2
	super._init(new_location, dict)
