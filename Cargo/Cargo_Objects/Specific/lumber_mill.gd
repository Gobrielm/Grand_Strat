extends factory

func _init(new_location: Vector2i):
	var new_inputs = {}
	new_inputs[0] = 1
	var new_outputs = {}
	new_outputs[1] = 1
	super._init(new_location, new_inputs, new_outputs)
