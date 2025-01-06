class_name officer extends base_unit

var experience_aura_boost

func _init(new_location: Vector2i, new_player_id: int):
	super._init(new_location, new_player_id)
	manpower = 50
	morale = 100
	
	organization = null
	speed = 80
	shock = 5
	firepower = 5
	cohesion = 5
	experience_gain = 2
	battle_multiple = 40
	
	experience_aura_boost = experience / 1000 + 1
	
	experience = 0
	combat_arm = 4

func recalculate_experience_aura_boost():
	experience_aura_boost = experience / 1000 + 1

func _to_string():
	return "Officer"
