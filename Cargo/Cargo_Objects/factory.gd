class_name factory extends fixed_hold

var inputs: Array
var outputs: Array
var max_batch_size: int

func _init(new_location: Vector2i, new_inputs: Array, new_outputs: Array):
	super._init(new_location)
	inputs = new_inputs
	outputs = new_outputs
	max_batch_size = 2
	for index in inputs.size():
		if index != 0:
			add_accept(index)

func deliver_cargo(type: int, amount: int) -> int:
	add_cargo(type, amount)
	return calculate_reward(type, amount)

func calculate_reward(type: int, amount: int) -> int:
	return amount

func check_recipe() -> bool:
	return check_inputs() and check_outputs()

func check_inputs() -> bool:
	for index in inputs.size():
		var amount = inputs[index]
		if storage[index] < amount:
			return false
	return true

func check_outputs() -> bool:
	for index in outputs.size():
		var amount = outputs[index]
		if max_amount - storage[index] < amount:
			return false
	return true

func create_recipe():
	print(get_batch_size())
	remove_inputs()
	add_outputs()

func get_batch_size() -> int:
	var batch_size = max_batch_size
	for index in inputs.size():
		var amount = inputs[index]
		batch_size = min(floor(amount % storage[index]), batch_size)
	for index in outputs.size():
		var amount = outputs[index]
		batch_size = min(floor((max_amount - amount) % storage[index]), batch_size)
	return batch_size
	

func remove_inputs():
	for index in inputs.size():
		var amount = inputs[index]
		storage[index] -= amount

func add_outputs():
	for index in outputs.size():
		var amount = outputs[index]
		storage[index] += amount

func get_price(_type: int, _amount: int) -> int:
	return 0

func month_tick():
	if check_recipe():
		create_recipe()
