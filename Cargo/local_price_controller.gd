class_name local_price_controller extends Node

const MAX_DIFF = 1.5

var changes = {}
var local_prices = {}
static var base_prices: Dictionary

func _init(accepts: Dictionary):
	for type in accepts:
		local_prices[type] = base_prices[type]

static func set_base_prices(new_base_prices):
	base_prices = new_base_prices

func get_local_price(type: int) -> int:
	return local_prices[type]

func vary_prices(demand: int, supply: int, type: int):
	var percentage_being_met = 1 - float(supply - demand) / demand
	if demand / 1.1 > supply:
		bump_up_good_price(type, percentage_being_met)
	elif demand * 1.1 < supply:
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
		multiple -= 0.02
	local_prices[type] = base_prices[type] * multiple

func equalize_good_price(type: int):
	var multiple = get_multiple(type)
	if multiple > 1:
		bump_down_good_price(type, 1)
	elif multiple < 1:
		bump_up_good_price(type, 1)
