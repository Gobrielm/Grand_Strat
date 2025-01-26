extends base_factory

func _init(new_location: Vector2i):
	var dict = {}
	dict[11] = 1
	super._init(new_location, dict)
