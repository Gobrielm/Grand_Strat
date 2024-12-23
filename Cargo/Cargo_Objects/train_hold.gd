class_name train_hold extends hold

func _init(new_location: Vector2i):
	location = new_location
	max_amount = 10
	for i in NUMBER_OF_GOODS:
		storage[i] = []

func create_cargo_collection(type: int, coords: Vector2i):
	storage[type].append(cargo_collection.new(type, coords))

func is_current_collection_valid(type: int, coords: Vector2i) -> bool:
	var current_collection: cargo_collection = storage[type].back()
	return current_collection.is_origination_same(coords) and current_collection.is_type_same(type)

func add_cargo(type: int, amount: int) -> int:
	var amount_to_add = get_amount_to_add(type, amount)
	var collection: cargo_collection
	if storage[type].size() != 0 and is_current_collection_valid:
		collection = storage[type].back()
	else:
		collection = cargo_collection.new(type, location)
		storage[type].append(collection)
	collection.change_amount(amount_to_add)
	return amount_to_add

func transfer_cargo(type: int, amount: int) -> Array:
	var collection_array: Array = storage[type]
	var curr_amount = 0
	var n = 0
	var ave_dist = 0
	var ave_time = 0
	var index = 0
	while !collection_array.is_empty() and curr_amount != amount and index < collection_array.size():
		var collection: cargo_collection = collection_array[index]
		if collection.get_origination() == location:
			index += 1
			continue
		n += 1
		ave_dist += collection.get_distance(location)
		ave_time += collection.get_time()
		var a = collection.transfer_amount(amount - curr_amount)
		
		clean_up_collection(type, index)
		curr_amount += a
	if n == 0:
		return [type, 0, 0, 0]
	ave_dist /= n
	ave_time /= n
	return [type, curr_amount, ave_dist, ave_time]

func transfer_all_cargo(type: int) -> int:
	var collection_array: Array = storage[type]
	var curr_amount = 0
	while !collection_array.is_empty():
		var collection: cargo_collection = collection_array.front()
		var a = collection.transfer_all()
		clean_up_collection(type, 0)
		curr_amount += a
	return curr_amount

func clean_up_collection(type: int, index: int):
	var collection_array: Array = storage[type]
	if collection_array[index].get_amount() == 0:
		collection_array.remove_at(index)

func remove_cargo(_type: int, _amount: int):
	print("NOT FINISHED, WILL CAUSE ISSUES")
	#TODO
	pass
	#var collection: Array = storage[type]
	#collection.change_amount(-amount)

func get_current_hold_total() -> int:
	var total = 0
	for index in storage:
		total += get_collection_array_total(storage[index])
	return total

func get_collection_array_total(collection_array: Array) -> int:
	var total = 0
	for collection in collection_array:
		total += collection.get_amount()
	return total

func get_cargo_total_for_each_type() -> Array[int]:
	var total: Array[int] = []
	for index in storage:
		total.append(get_collection_array_total(storage[index]))
	return total

func finalize_cargo_collections():
	for i in NUMBER_OF_GOODS:
		for collection: cargo_collection in storage[i]:
			collection.set_time_if_null()
