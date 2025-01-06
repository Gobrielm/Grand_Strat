class_name base_unit extends Node

func _init(new_location: Vector2i, new_player_id: int):
	location = new_location
	player_id = new_player_id

#Where the unit is
var location: Vector2i

func set_location(new_location: Vector2i):
	location = new_location

var player_id: int

func get_player_id() -> int:
	return player_id

#How much manpower the unit has
var manpower: int
#The desire for the unit to fight
var morale: int
#How fast a unit can move
var speed: int

func get_speed() -> int:
	return speed

#The route the unit takes if travelling
var route: Array

func set_route(new_route: Array):
	route = new_route

func get_next_location() -> Vector2i:
	if route.is_empty():
		return location
	return route.front()

func pop_next_location() -> Vector2i:
	return route.pop_front()

func is_route_empty() -> bool:
	return route.is_empty()

func get_destination():
	if route.is_empty():
		return null
	return route.back()

#The progress unit has to travel
var progress: float

func update_progress(num: float):
	progress += num

func reset_progress():
	progress = 0

func ready_to_move(progress_needed) -> bool:
	if progress_needed < progress:
		reset_progress()
		return true
	return false
	

#The amount of supplies the unit has
var organization

#The morale damage a unit does
var shock: int
#The general damage
var firepower: int

#Morale defense, defense in general
var cohesion: int
#The disipline and skill of the unit
var experience: int
#The rate at which a unit gains experience
#level 0 - inexperienced, 0 - 200
#level 1 - trained,       200 - 500
#level 2 - experienced,   500 - 1000
#level 3 - expert,        1000 - 2000
#level 4 - verteran,      2000 - 5000
#level 5 - elite,         5000 - ∞
var experience_gain: int
#The bonus to experience_gain when in battle
var battle_multiple: int

#The specification, infantry, cav, ect. the y atlas
#Infantry, Calvary, officer, engineer, artillery, 
var combat_arm: int
#The actual type line infantry, mechanized infantry, ect. the x atlas
var specific_type: int
