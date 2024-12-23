class_name terminal extends Node

const NUMBER_OF_GOODS = 5

var location: Vector2i
var player_owner: int

func get_location() -> Vector2i:
	return location

func update_location(new_location: Vector2i):
	location = new_location

func get_player_owner() -> int:
	return player_owner

func calculate_reward(cargo_array: Array) -> int:
	var type = cargo_array[0]
	var amount = cargo_array[1]
	var dist = cargo_array[2]
	var time = cargo_array[3]
	#Piecewise
	if time < 5:
		return round(sqrt(5) * amount * sqrt(dist))
	elif time < 30:
		return round(5 * amount * sqrt(dist) / sqrt(time))
	else:
		return round(5 * amount * sqrt(dist) / sqrt(30))
