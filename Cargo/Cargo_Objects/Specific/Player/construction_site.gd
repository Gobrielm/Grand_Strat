class_name construction_site extends fixed_hold

var inputs = {}
var outputs = {}

func _init(coords: Vector2i):
	super._init(coords)

func has_recipe() -> bool:
	return inputs.is_empty()
