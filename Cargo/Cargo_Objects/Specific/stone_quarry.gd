extends base_factory

func _init(new_location: Vector2i):
	var array = [NUMBER_OF_GOODS]
	array[4] = 3
	super._init(new_location, array)
