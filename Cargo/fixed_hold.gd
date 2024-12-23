class_name fixed_hold extends hold

var accepts: Array #Cargo the hold accepts

func _init(new_location: Vector2i):
	super._init(new_location)
	accepts = []
	for i in NUMBER_OF_GOODS:
		accepts.append(false)

#Return amount added
func add_cargo(type: int, amount: int) -> int:
	if accepts[type]:
		var amount_to_add = min(max_amount - storage[type], amount)
		storage[type] += amount_to_add
		return amount_to_add
	return 0

func get_desired_cargo(type: int) -> int:
	if accepts[type]:
		return max_amount - storage[type]
	return 0

func get_accepts() -> Array:
	return accepts
func add_accept(type: int):
	accepts[type] = true
func remove_accept(type: int):
	accepts[type] = false

func does_accept(type: int) -> bool:
	return accepts[type]
