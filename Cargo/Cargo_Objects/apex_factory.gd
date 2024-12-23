class_name apex_factory extends sink

#Returns Money
func deliver_cargo(type: int, amount: int) -> int:
	if accepts[type]:
		#Money System
		return amount
	return 0

func get_desired_cargo(type: int) -> int:
	if accepts[type]:
		return 1000
	return 0
	
