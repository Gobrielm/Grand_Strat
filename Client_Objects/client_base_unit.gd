extends base_unit

var owned: bool

func get_owned() -> bool:
	return owned

func _init():
	owned = false
	manpower = 0
	morale = 0
	experience = 0

func update_stats(unit_info: Array):
	owned = unit_info[0]
	manpower = unit_info[1]
	morale = unit_info[2]
	experience = unit_info[3]
