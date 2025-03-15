extends Node2D

var map: TileMapLayer

const TILES_PER_ROW := 8
const MAX_RESOURCES = [5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, -1, 5000
, -1, -1, -1, -1, 5000, 5000, 5000, 5000, 5000, 50000
, 1000]

func _ready():
	Utils.assign_cargo_values(self)

func can_build_type(type: int, coords: Vector2i) -> bool:
	return get_tile_magnitude(type, coords) > 0

func get_layer(type: int) -> TileMapLayer:
	var cargo_name = get_good_name_uppercase(type)
	var layer: TileMapLayer = get_node("Layer" + str(type) + cargo_name)
	assert(layer != null)
	return layer

func get_available_resources(coords: Vector2i) -> Dictionary:
	var toReturn := {}
	for type in get_child_count():
		var mag := get_tile_magnitude(type, coords)
		if mag > 0:
			toReturn[type] = mag
	return toReturn

func open_resource_map(type: int):
	get_layer(type).visible = true

func close_all_layers():
	for i in terminal_map.amount_of_primary_goods:
		get_layer(i).visible = false

func get_tile_magnitude(type: int, coords: Vector2i) -> int:
	var cargo_name = get_good_name_uppercase(type)
	var layer: TileMapLayer = get_node("Layer" + str(type) + cargo_name)
	assert(layer != null)
	var atlas: Vector2i = layer.get_cell_atlas_coords(coords)
	if atlas == Vector2i(-1, -1):
		return 0
	return atlas.y * TILES_PER_ROW + atlas.x

func get_atlas_for_magnitude(num: int) -> Vector2i:
	return Vector2i(num % TILES_PER_ROW, num / TILES_PER_ROW)
	
func get_good_name_uppercase(type: int) -> String:
	var cargo_name: String = terminal_map.get_cargo_name(type)
	cargo_name[0] = cargo_name[0].to_upper()
	return cargo_name

func get_available_primary_recipes(coords: Vector2i) -> Array:
	var toReturn = []
	for type in get_child_count():
		if can_build_type(type, coords):
			var dict = {}
			dict[terminal_map.get_cargo_name(type)] = 1
			toReturn.append([{}, dict])
	return toReturn

func place_resources(_map: TileMapLayer):
	var start: float = Time.get_ticks_msec()
	map = _map
	var helper: Node = load("res://Map/Cargo_Maps/cargo_values_helper.gd").new(map)
	var resource_array: Array = helper.create_resource_array()
	helper.queue_free()
	
	
	var threads := []
	for i in get_child_count():
		var thread = Thread.new()
		threads.append(thread)
		thread.start(autoplace_resource.bind(resource_array[i], get_child(i), MAX_RESOURCES[i]))
	for thread: Thread in threads:
		thread.wait_to_finish()
	var end: float = Time.get_ticks_msec()
	print(str((end - start) / 1000) + " Seconds passed")

func autoplace_resource(tiles: Dictionary, layer: TileMapLayer, max: int):
	var array: Array = tiles.keys()
	array.shuffle()
	var count = 0
	for cell: Vector2i in array:
		var mag = randi() % 4 + tiles[cell]
		layer.call_deferred_thread_group("set_cell", cell, 1, get_atlas_for_magnitude(mag))
		count += mag
		if count > max and max != -1:
			return

#func create_continents():
	#var file = FileAccess.open("res://Map/Map_Info/North_America.txt", FileAccess.WRITE)
	#for tile in $Layer1Sand.get_used_cells():
		#if !is_tile_water(map, tile):
			#save_to_file(file, str(tile) + '.')
	#file.close()
	#file = FileAccess.open("res://Map/Map_Info/South_America.txt", FileAccess.WRITE)
	#for tile in $Layer2Sulfur.get_used_cells():
		#if !is_tile_water(map, tile):
			#save_to_file(file, str(tile) + '.')
	#file.close()
	#file = FileAccess.open("res://Map/Map_Info/Europe.txt", FileAccess.WRITE)
	#for tile in $Layer3Lead.get_used_cells():
		#if !is_tile_water(map, tile):
			#save_to_file(file, str(tile) + '.')
	#file.close()
	#file = FileAccess.open("res://Map/Map_Info/Africa.txt", FileAccess.WRITE)
	#for tile in $Layer4Iron.get_used_cells():
		#if !is_tile_water(map, tile):
			#save_to_file(file, str(tile) + '.')
	#file.close()
	#file = FileAccess.open("res://Map/Map_Info/Asia.txt", FileAccess.WRITE)
	#for tile in $Layer5Coal.get_used_cells():
		#if !is_tile_water(map, tile):
			#save_to_file(file, str(tile) + '.')
	#file.close()
	#file = FileAccess.open("res://Map/Map_Info/Australia.txt", FileAccess.WRITE)
	#for tile in $Layer6Copper.get_used_cells():
		#if !is_tile_water(map, tile):
			#save_to_file(file, str(tile) + '.')
	#file.close()
	#file = FileAccess.open("res://Map/Map_Info/Australia.txt", FileAccess.READ)
	#try_to_read(file)
#
#func save_to_file(file, content: String):
	#file.store_string(content)
	#
#
#func try_to_read(file: FileAccess):
	#var packedString = file.get_csv_line('.')
	#print(packedString[0])
	#print(packedString[999])
	#
