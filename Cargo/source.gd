class_name source extends terminal

var production: Array
var speed: int
var count: float

func _init(new_location: Vector2i, new_production: Array):
	location = new_location
	production = new_production
	speed = 10
	count = 0
