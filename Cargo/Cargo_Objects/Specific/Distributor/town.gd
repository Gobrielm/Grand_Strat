extends factory

func _init(new_location: Vector2i, size: int):
	create_inputs(size)
	pass

func create_inputs(size: int):
	inputs[terminal_map.get_cargo_type("wine")] = 1
	inputs[terminal_map.get_cargo_type("furniture")] = 1
	inputs[terminal_map.get_cargo_type("wagons")] = 1
	inputs[terminal_map.get_cargo_type("paper")] = 1
	inputs[terminal_map.get_cargo_type("lumber")] = 1
	inputs[terminal_map.get_cargo_type("lanterns")] = 1
	inputs[terminal_map.get_cargo_type("luxury_clothes")] = 1
	inputs[terminal_map.get_cargo_type("clothes")] = 1
	inputs[terminal_map.get_cargo_type("bread")] = 1
	inputs[terminal_map.get_cargo_type("meat")] = 1
	inputs[terminal_map.get_cargo_type("liquor")] = 1
	inputs[terminal_map.get_cargo_type("coffee")] = 1
	inputs[terminal_map.get_cargo_type("tea")] = 1
	inputs[terminal_map.get_cargo_type("porcelain")] = 1
	inputs[terminal_map.get_cargo_type("cigarettes")] = 1
	inputs[terminal_map.get_cargo_type("gold")] = 1

func check_recipe() -> bool:
	return true
