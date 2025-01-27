class_name factory_template extends fixed_hold

var connected_stations: Dictionary = {}

var inputs: Dictionary
var outputs: Dictionary

var max_batch_size: int
var local_pricer: local_price_controller

const DEFAULT_BATCH_SIZE = 2

func _init(new_location: Vector2i, new_inputs: Dictionary, new_outputs: Dictionary):
	super._init(new_location)
	inputs = new_inputs
	outputs = new_outputs
	max_batch_size = DEFAULT_BATCH_SIZE
	for type in inputs.size():
		if inputs[type] != 0:
			add_accept(type)
	local_pricer = local_price_controller.new(inputs, outputs)

func add_station(coords: Vector2i, new_station: station):
	connected_stations[coords] = new_station

func delete_station(coords: Vector2i):
	connected_stations.erase(coords)

func deliver_cargo(type: int, amount: int) -> int:
	add_cargo(type, amount)
	local_pricer.report_sale(type, amount)
	return calculate_reward(type, amount)

func calculate_reward(type: int, amount: int) -> int:
	return local_pricer.get_local_price(type) * amount

func check_recipe() -> bool:
	return check_inputs() and check_outputs()

func transfer_cargo(type: int, amount: int) -> int:
	var new_amount = min(storage[type], amount)
	remove_cargo(type, amount)
	local_pricer.report_sale(type, new_amount)
	return new_amount

func check_inputs() -> bool:
	for index in inputs:
		var amount = inputs[index]
		if storage[index] < amount:
			return false
	return true

func check_outputs() -> bool:
	for index in outputs:
		var amount = outputs[index]
		if max_amount - storage[index] < amount:
			return false
	return true

func create_recipe():
	var batch_size = get_batch_size()
	remove_inputs(batch_size)
	add_outputs(batch_size)

func get_batch_size() -> int:
	var batch_size = max_batch_size
	for index in inputs:
		var amount = inputs[index]
		batch_size = min(floor(storage[index] / amount), batch_size)
	for index in outputs:
		var amount = outputs[index]
		batch_size = min(floor((max_amount - storage[index]) / amount), batch_size)
	return batch_size

func remove_inputs(batch_size: int):
	for index in inputs:
		var amount = inputs[index] * batch_size
		storage[index] -= amount

func add_outputs(batch_size: int):
	for index in outputs:
		var amount = outputs[index] * batch_size
		storage[index] += amount

func get_price(_type: int, _amount: int) -> int:
	return 0

func distribute_cargo():
	var array = []
	for stat in connected_stations.values():
		array.push_back(stat)
	for index: int in outputs:
		distribute_specific_type(index, array)

func distribute_specific_type(type: int, connected_stations_array: Array):
	var price = local_pricer.get_local_price(type)
	var amount_to_transfer = min(LOAD_TICK_AMOUNT, get_cargo_amount(type))
	var size = connected_stations_array.size()
	var amount_for_each = ceil(amount_to_transfer / size)
	var index = 0
	while amount_to_transfer > 0:
		var connected_station: station = connected_stations_array[index]
		var amount_can_buy = min(connected_station.get_amount_can_buy(price), amount_for_each)
		if amount_can_buy == 0:
			size -= 1
			if size == 0:
				return
			connected_stations_array.pop_at(index)
			index = (index) % size
			continue
		var amount = transfer_cargo(type, amount_can_buy)
		amount_to_transfer -= amount
		add_cash(connected_station.transfer_cash(amount * price))
		connected_station.add_cargo(type, amount)
		index = (index + 1) % size

func month_tick():
	for type in inputs:
		local_pricer.vary_input_price(inputs[type] * max_batch_size, type)
	for type in outputs:
		local_pricer.vary_output_price(outputs[type] * max_batch_size, type)
	
	if check_recipe():
		create_recipe()
	if connected_stations.size() != 0:
		distribute_cargo()
	
