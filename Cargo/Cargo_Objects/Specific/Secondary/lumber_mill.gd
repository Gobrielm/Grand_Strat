extends factory

func _init(new_location: Vector2i):
	var new_inputs = {}
	new_inputs[terminal_map.get_cargo_type("wood")] = 2
	var new_outputs = {}
	new_outputs[terminal_map.get_cargo_type("lumber")] = 1
	super._init(new_location, new_inputs, new_outputs)
