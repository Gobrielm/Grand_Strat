extends factory

func _init(new_location: Vector2i, size: int):
	create_inputs(size)
	pass

func create_inputs(size: int):
	inputs[1] = 1
	inputs[3] = 1
	inputs[5] = 2
	inputs[6] = 2
	inputs[7] = 1
	inputs[9] = 1
	inputs[10] = 1
	inputs[14] = 1
	inputs[15] = 1
	inputs[16] = 1
	inputs[20] = 2

func check_recipe() -> bool:
	return true
