class_name hold extends terminal

var storage: Dictionary = {} #Cargo the hold has
var max_amount: int = 50 #Max Amount of cargo the hold can hold

func _init(new_location: Vector2i):
	location = new_location
	for i in NUMBER_OF_GOODS:
		storage[i] = 0

#Return amount added
func add_cargo(type: int, amount: int) -> int:
	var amount_to_add = get_amount_to_add(type, amount)
	storage[type] += amount_to_add
	return amount_to_add

func remove_cargo(type: int, amount: int):
	storage[type] -= amount

func get_amount_to_add(_type: int, amount: int) -> int:
	return min(max_amount - get_current_hold_total(), amount)

func get_current_hold() -> Dictionary:
	return storage

func get_current_hold_total() -> int:
	var total = 0
	for index in storage:
		total += storage[index]
	return total

func is_full() -> bool:
	return get_current_hold_total() >= max_amount

func is_empty() -> bool:
	return get_current_hold_total() == 0

func change_max_storage(_type: int, amount: int):
	max_amount += amount

func does_accept(_type: int):
	return get_current_hold_total() < max_amount
