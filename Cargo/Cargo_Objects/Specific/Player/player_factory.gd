class_name player_factory extends factory

func _init(new_location: Vector2i):
	super._init(new_location, {}, {})

func has_no_recipe() -> bool:
	return inputs == {} and outputs == {}
