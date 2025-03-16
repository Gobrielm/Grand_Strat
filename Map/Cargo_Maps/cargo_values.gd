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
	
	var start: float = Time.get_ticks_msec()
	create_territories()
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

func create_territories():
	#TODO: USE this to create and save seperate tilemaplayer, from there
	#edit and make better in editor, then save as map/TileMapLayer for player to use in-game
	var im_provinces: Image = load("res://Map/Map_Images/provinces.png").get_image()
	var coords_to_province_id := {}
	var current_index := 0
	for real_x in range(-609, 671):
		for real_y in range(-243, 282):
			var x := (real_x + 609) * 3 / 2
			var y := (real_y + 243) * 7 / 4
			var tile := Vector2i(real_x, real_y)
			var color = im_provinces.get_pixel(x, y)
			if is_tile_water(tile):
				continue
			
			if get_left_color(x, y, im_provinces) == color and !is_tile_water(Vector2i(real_x - 1, real_y)):
				var this_id = coords_to_province_id[Vector2i(real_x - 1, real_y)]
				coords_to_province_id[tile] = this_id
			elif get_up_color(x, y, im_provinces) == color and !is_tile_water(Vector2i(real_x, real_y - 1)):
				var this_id = coords_to_province_id[Vector2i(real_x, real_y - 1)]
				coords_to_province_id[tile] = this_id
			else:
				coords_to_province_id[tile] = current_index
				current_index += 1
	
	var file := FileAccess.open("res://Map/Map_Info/Provinces.txt", FileAccess.WRITE)
	for tile: Vector2i in coords_to_province_id:
		var id: int = coords_to_province_id[tile]
		file.store_string(str(tile) + ":" + str(id))
	



func get_left_color(x: int, y: int, im_provinces: Image) -> Color:
	if x < 3/2:
		return Color.BLACK
	return im_provinces.get_pixel(x - 3/2, y)

func get_up_color(x: int, y: int, im_provinces: Image) -> Color:
	if y < 7/4:
		return Color.BLACK
	return im_provinces.get_pixel(x, y - 7/4)

func is_tile_water(coords: Vector2i) -> bool:
	var atlas = map.get_cell_atlas_coords(coords)
	return atlas == Vector2i(6, 0) or atlas == Vector2i(7, 0)

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
