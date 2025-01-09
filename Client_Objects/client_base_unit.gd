extends base_unit

var destination

func _init(new_location: Vector2i, new_player_id: int):
	location = new_location
	player_id = new_player_id
	manpower = 0
	morale = 0
	experience = 0

func update_stats(unit_info: Array):
	#player_id = unit_info[0]
	location = unit_info[1]
	destination = unit_info[2]
	manpower = unit_info[3]
	morale = unit_info[4]
	experience = unit_info[5]

func convert_to_client_array() -> Array:
	return [player_id, location, destination, manpower, morale, experience]
