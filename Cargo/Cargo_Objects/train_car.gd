extends Sprite2D
var destination: Vector2
var velocity = Vector2(0, 0)
var speed = 0
var train
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func update_train(new_train):
	train = new_train


func _process(delta):
	position.x += velocity.x * delta
	position.y += velocity.y * delta
	update_speed()

func update_desination(new_dest: Vector2):
	if check_dist():
		destination = new_dest
		path_find_to_desination()

func check_dist() -> bool:
	var dist = position.distance_to(train.position)
	return dist > 100

func path_find_to_desination():
	var velocity_unit = (destination - position).normalized()
	velocity = velocity_unit * speed

func update_speed():
	speed = train.get_speed()
	velocity = velocity.normalized() * speed
