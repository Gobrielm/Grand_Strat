class_name sink extends terminal

var accepts: Array

func _init(new_location: Vector2i, new_accepts: Array):
	location = new_location
	accepts = new_accepts

func get_accepts() -> Array:
	return accepts

func does_accept(type: int) -> bool:
	return accepts[type]
