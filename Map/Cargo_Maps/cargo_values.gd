extends Node2D

var map: TileMapLayer

const TILES_PER_ROW = 8
const MAX_CLAY = 5000
const MAX_SULFUR = 5000
const MAX_IRON = 5000

func can_build_type(type: int, coords: Vector2i) -> bool:
	return get_tile_magnitude(type, coords) > 0

func get_tile_magnitude(type: int, coords: Vector2i) -> int:
	var cargo_name = get_good_name_uppercase(type)
	var layer: TileMapLayer = get_node("Layer" + str(type) + cargo_name)
	assert(layer != null)
	var atlas: Vector2i = layer.get_cell_atlas_coords(coords)
	if atlas == Vector2i(-1, -1):
		return 0
	return atlas.y * TILES_PER_ROW + atlas.x

func get_atlas_for_magnitude(num: int) -> Vector2i:
	return Vector2i(num % TILES_PER_ROW, floor(num / TILES_PER_ROW))
	
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
	var resource_array: Array = get_tiles_for_resources()
	autoplace_resource(get_tiles_for_clay(), $Layer0Clay, MAX_CLAY)
	autoplace_resource(resource_array[2], $Layer2Sulfur, MAX_SULFUR)
	autoplace_resource(resource_array[4], $Layer4Iron, MAX_IRON)


func autoplace_resource(tiles: Array, layer: TileMapLayer, max: int):
	var count = 0
	for cell: Vector2i in tiles:
		var mag = randi() % 10
		layer.set_cell(cell, 1, get_atlas_for_magnitude(mag))
		count += mag
		if count > max:
			return

func get_tiles_for_clay() -> Array:
	var toReturn = []
	for tile in map.get_used_cells_by_id(0, Vector2i(6, 0)):
		if is_tile_river(tile):
			for cell: Vector2i in map.get_surrounding_cells(tile):
				if !is_tile_water(cell):
					toReturn.append(cell)
	for tile in map.get_used_cells_by_id(0, Vector2i(5, 0)):
		for cell in map.get_surrounding_cells(tile):
			if get_tile_elevation(map.get_cell_atlas_coords(cell)) == 0:
				toReturn.append(cell)
	
	toReturn.shuffle()
	return toReturn

func get_tiles_for_resources() -> Array:
	var toReturn = []
	for i in terminal_map.amount_of_primary_goods:
		toReturn.push_back([])
	var im_volcanoes: Image = Image.load_from_file("res://Map/Map_Images/volcanos.png")
	var im_iron: Image = Image.load_from_file("res://Map/Map_Images/iron.png")
	var real_x = -610
	var real_y = -244
	for x in im_volcanoes.get_width():
		for y in im_volcanoes.get_height():
			if x % 3 == 0 or y % 7 <= 2:
				continue
			var color2: Color = im_volcanoes.get_pixel(x, y)
			var color4: Color = im_iron.get_pixel(x, y)
			var tile: Vector2i = Vector2i(real_x, real_y)
			
			if color2.r > (color2.b + color2.g + 0.5) and !is_tile_water(tile):
				toReturn[2].push_back(tile)
				
			if color4.r > (color4.b + color4.g) or color4.b > (color4.r + color4.g) and !is_tile_water(tile):
				toReturn[4].push_back(tile)
			real_y += 1
		if x % 3 != 0:
			real_x += 1
			real_y = -244
	for i in terminal_map.amount_of_primary_goods:
		toReturn[i].shuffle()
	return toReturn

func is_tile_water(coords: Vector2i) -> bool:
	var atlas = map.get_cell_atlas_coords(coords)
	return atlas == Vector2i(6, 0) or atlas == Vector2i(7, 0)

func get_tile_elevation(atlas: Vector2i) -> int:
	if atlas == Vector2i(5, 0) or atlas == Vector2i(3, 3):
		return 2
	elif atlas == Vector2i(3, 0) or atlas == Vector2i(4, 0) or atlas == Vector2i(5, 1) or atlas == Vector2i(3, 2) or atlas == Vector2i(3, 3):
		return 1
	return 0

func is_tile_river(coords: Vector2i) -> bool:
	var count = 0
	for cell in map.get_surrounding_cells(coords):
		if !is_tile_water(cell):
			count += 1
	return count > 3

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
