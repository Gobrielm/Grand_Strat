class_name artillery extends base_unit

func _init(new_location: Vector2i, new_player_id: int):
	super._init(new_location, new_player_id)
	manpower = 200
	morale = 100
	
	organization = null
	speed = 10
	shock = 40
	firepower = 100
	cohesion = 15
	experience_gain = 3
	battle_multiple = 10
	
	experience = 0
	combat_arm = 2

func _to_string():
	return "Artillery"
