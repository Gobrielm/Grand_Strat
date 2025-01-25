class_name terminal extends Node

static var NUMBER_OF_GOODS: int = 0
static var BASE_PRICES: Dictionary = {}

static func set_number_of_goods(new_number):
	NUMBER_OF_GOODS = new_number

static func set_base_prices(base_prices):
	BASE_PRICES = base_prices
	set_number_of_goods(BASE_PRICES.size())

static func get_base_prices() -> Dictionary:
	return BASE_PRICES

var location: Vector2i
var player_owner: int

func get_location() -> Vector2i:
	return location

func update_location(new_location: Vector2i):
	location = new_location

func get_player_owner() -> int:
	return player_owner

func calculate_reward(_type: int, _amount: int) -> int:
	return 0
