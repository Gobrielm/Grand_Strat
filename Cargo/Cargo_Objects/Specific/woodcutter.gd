extends base_factory

func _init(new_location: Vector2i):
	var array = []
	array.resize(NUMBER_OF_GOODS)
	array.fill(0)
	array[0] = 3
	super._init(new_location, array)
