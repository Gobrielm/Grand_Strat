extends terminal
var trains = []

var map: TileMapLayer
const train_scene = preload("res://Cargo/Cargo_Objects/train.tscn")


func _init(new_location: Vector2i, new_map):
	location = new_location
	map = new_map

func get_trains():
	return trains

func get_train(index: int):
	return trains[index]

func add_train(train):
	trains.append(train)

func add_new_train():
	var train = train_scene.instantiate()
	map.add_child(train)
	train.create(location)
	trains.append(train)
	train.visible = false

func remove_train(index: int):
	trains.remove_at(index)
