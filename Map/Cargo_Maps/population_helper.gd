extends Node

var map: TileMapLayer
var im_population: Image = load("res://Map/Map_Images/population.png").get_image()
var mutex := Mutex.new()

func _init(_map: TileMapLayer):
	map = _map

func create_population_map():
	var tile_info = Utils.tile_info
	assert(tile_info != null)
	var thread := Thread.new()
	var thread1 := Thread.new()
	var thread2 := Thread.new()
	var thread3 := Thread.new()
	thread.start(create_part_of_array.bind(-609, 0, -243, 0, tile_info))
	thread1.start(create_part_of_array.bind(0, 671, -243, 0, tile_info))
	thread2.start(create_part_of_array.bind(-609, 0, 0, 282, tile_info))
	thread3.start(create_part_of_array.bind(0, 671, 0, 282, tile_info))
	var threads := [thread, thread1, thread2, thread3]
	for thd: Thread in threads:
		thd.wait_to_finish()

func create_part_of_array(from_x: int, to_x: int, from_y: int, to_y: int, tile_info):
	var total = 0
	for real_x in range(from_x, to_x):
		for real_y in range(from_y, to_y):
			var x := (real_x + 609) * 3 / 2
			var y := (real_y + 243) * 7 / 4
			var tile := Vector2i(real_x, real_y)
			total += helper(x, y, tile, tile_info)
	print(total)

func helper(x: int, y: int, tile: Vector2i, tile_info) -> int:
	var color: Color = im_population.get_pixel(x, y)
	var num := 0
	var multipler := 0.1
	if color.r > 0.9:
		if color.b > 0.98:
			num = (randi() % 10000) * multipler
		elif color.b > 0.7:
			num = (randi() % 40000 + 10000) * multipler
		elif color.b > 0.60:
			num = (randi() % 50000 + 50000) * multipler
		elif color.b > 0.30:
			num = (randi() % 200000 + 100000) * multipler
		elif color.b > 0.20:
			num = (randi() % 200000 + 300000) * multipler
		elif color.b == 0.0:
			num = (randi() % 300000 + 500000) * multipler
	else:
		if color.b > 0.5:
			num = (randi() % 100000 + 500000)
		elif color.b > 0.3:
			num = (randi() % 300000 + 1000000)
	mutex.lock()
	tile_info.set_population(tile, num)
	mutex.unlock()
	return num
	
