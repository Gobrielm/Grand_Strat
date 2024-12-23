class_name source extends terminal

var production: Array
var speed: int
var count: float

func _init(new_location: Vector2i, new_production: Array, new_speed: int):
	location = new_location
	production = new_production
	speed = new_speed
	count = 0
