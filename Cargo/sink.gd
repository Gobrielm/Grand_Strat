class_name sink extends terminal

var accepts: Dictionary

func _init(new_location: Vector2i, new_accepts: Dictionary):
	location = new_location
	accepts = new_accepts

func get_accepts() -> Dictionary:
	return accepts

func does_accept(type: int) -> bool:
	return accepts[type]
