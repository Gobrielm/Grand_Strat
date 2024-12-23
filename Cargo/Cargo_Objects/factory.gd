class_name factory extends fixed_hold

var ticker: float = 0
var inputs: Array[int]
var outputs: Array[int]

func _init(new_location: Vector2i, new_inputs: Array[int], new_outputs: Array[int]):
	super._init(new_location)
	inputs = new_inputs
	outputs = new_outputs

func deliver_cargo(type: int, amount: int) -> int:
	add_cargo(type, amount)
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
	remove_inputs()
	add_outputs()

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

func process(delta):
	ticker += delta
	if ticker == 1:
		if check_recipe():
			create_recipe()
		ticker = 0
