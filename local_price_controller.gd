extends Node

const MAX_DIFF = 1.5

var local_prices = {}
var base_prices = []

func _init(accepts: Array, new_base_prices: Array):
	base_prices = new_base_prices
	for type in accepts.size():
		if accepts[type]:
			local_prices[type] = base_prices[type]
	

func vary_prices(demand: int, supply: int, type: int):
	var percentage_being_met = 1 -float(supply - demand) / demand
	if demand / 1.2 > supply:
		bump_up_good_price(type, percentage_being_met)
	elif demand * 1.2 < supply:
		bump_down_good_price(type, percentage_being_met)
	else:
		equalize_good_price(type)

func get_multiple(type: int) -> float:
	return local_prices[type] /  base_prices[type]

func bump_up_good_price(type: int, percentage_met: float):
	var multiple = get_multiple(type)
	if multiple >= percentage_met:
		multiple = percentage_met
	elif multiple >= MAX_DIFF:
		multiple = MAX_DIFF
	else:
		multiple += 0.01
	local_prices[type] = base_prices[type] * multiple

func bump_down_good_price(type: int, percentage_met: float):
	var multiple = get_multiple(type)
	if multiple <= percentage_met:
		multiple = percentage_met
	elif multiple <= 1 / MAX_DIFF:
		multiple = 1 / MAX_DIFF
	else:
		multiple -= 0.01
	local_prices[type] = base_prices[type] * multiple

func equalize_good_price(type: int):
	var multiple = get_multiple(type)
	if multiple > 1:
		bump_down_good_price(type, 1)
	elif multiple < 1:
		bump_up_good_price(type, 1)
