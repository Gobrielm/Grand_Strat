extends Sprite2D
var destination: Vector2
var velocity = Vector2(0, 0)
var train
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func assign_train(new_train, new_position: Vector2):
	train = new_train
	position = new_position


func _process(delta):
	position.x += velocity.x * delta
	position.y += velocity.y * delta
	update_speed()

func update_desination(new_dest: Vector2):
	new_dest = destination
	path_find_to_desination()

func path_find_to_desination():
	var velocity_unit = (destination - position).normalized()
	var magnitude = velocity.length()
	velocity = velocity_unit * magnitude

func update_speed():
	var new_speed = train.get_speed()
	velocity = velocity.normalized() * new_speed
