extends base_factory

func _init(new_location: Vector2i):
	var dict = {}
	dict[16] = 2
	super._init(new_location, dict)
