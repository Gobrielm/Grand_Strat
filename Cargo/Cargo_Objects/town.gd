class_name town extends terminal

var town_sink: apex_factory
var town_source: base_factory

func _init(new_location: Vector2i, population):
	location = new_location
	town_sink = apex_factory.new(new_location, create_accepts_array(true, false))
	town_source = base_factory.new(new_location, create_accepts_array(floor(population / 100), 0))

func create_accepts_array(start_with, toAppend) -> Array:
	var toReturn = []
	for i in NUMBER_OF_GOODS:
		toReturn.append(toAppend)
	toReturn[0] = start_with
	return toReturn

func get_desired_cargo(type: int) -> int:
	return town_sink.get_desired_cargo(type)

func does_accept(type: int) -> bool:
	return town_sink.does_accept(type)

func get_accepts() -> Array:
	return town_sink.get_accepts()

func deliver_cargo(cargo_array: Array):
	var type = cargo_array[0]
	var amount = cargo_array[1]
	town_sink.deliver_cargo(type, amount)
	return calculate_reward(cargo_array)

func add_terminal(coords: Vector2i, new_terminal):
	town_source.add_terminal(coords, new_terminal)

func delete_terminal(coords: Vector2i):
	town_source.delete_terminal(coords)

func process(delta: float):
	town_source.process(delta)
