class_name base_factory extends source

var connected_stations: Dictionary = {}
var local_pricer: local_price_controller

func _init(new_location: Vector2i, new_outputs: Dictionary):
	super._init(new_location, new_outputs)
	local_pricer = local_price_controller.new({}, outputs)

func add_terminal(coords: Vector2i, new_terminal):
	connected_stations[coords] = new_terminal

func delete_terminal(coords: Vector2i):
	connected_stations.erase(coords)

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
		#TODO: FInish and add price
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

func produce():
	for i in outputs:
		add_cargo(i, outputs[i])


func month_tick():
	for type in outputs:
		local_pricer.vary_output_price(outputs[type] * max_batch_size, type)
	produce()
	if connected_stations.size() > 0:
		distribute_cargo()
