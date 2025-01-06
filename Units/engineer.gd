class_name engineer extends base_unit

func _init(new_location: Vector2i):
	super._init(new_location)
	manpower = 100
	morale = 100
	
	organization = null
	speed = 50
	shock = 0
	firepower = 0
	cohesion = 10
	experience_gain = 30
	battle_multiple = 2
	
	experience = 0
	combat_arm = 0
	specific_type = 0
