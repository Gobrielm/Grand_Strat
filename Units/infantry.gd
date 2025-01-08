class_name infantry extends base_unit

func _init(new_location: Vector2i, new_player_id: int):
	super._init(new_location, new_player_id)
	manpower = 1000
	morale = 100
	
	organization = null
	speed = 30
	range = 1
	shock = 20
	firepower = 50
	cohesion = 100
	experience_gain = 10
	battle_multiple = 5
	
	experience = 0
	combat_arm = 0

func _to_string():
	return "Infantry"

static func toString() -> String:
	return "Infantry"
