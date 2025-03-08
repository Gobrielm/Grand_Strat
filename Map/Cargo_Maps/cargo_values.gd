extends Node2D

var map: TileMapLayer

const TILES_PER_ROW = 8
const MAX_RESOURCES = [5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000
, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 50000
, 1000]

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
	autoplace_resource(get_tiles_for_clay(), $Layer0Clay, MAX_RESOURCES[0])
	autoplace_resource(resource_array[2], $Layer2Sulfur, MAX_RESOURCES[2])
	autoplace_resource(resource_array[3], $Layer3Lead, MAX_RESOURCES[3])
	autoplace_resource(resource_array[4], $Layer4Iron, MAX_RESOURCES[4])
	autoplace_resource(resource_array[5], $Layer5Coal, MAX_RESOURCES[5])
	autoplace_resource(resource_array[6], $Layer6Copper, MAX_RESOURCES[6])
	
	autoplace_resource(resource_array[14], $Layer14Cotton, MAX_RESOURCES[14])
	autoplace_resource(resource_array[15], $Layer15Silk, MAX_RESOURCES[15])
	
	autoplace_resource(resource_array[17], $Layer17Coffee, MAX_RESOURCES[17])
	
	autoplace_resource(resource_array[19], $Layer19Tobacco, MAX_RESOURCES[19])
	autoplace_resource(resource_array[20], $Layer20Gold, MAX_RESOURCES[20])


func autoplace_resource(tiles: Array, layer: TileMapLayer, max: int):
	var count = 0
	for cell: Vector2i in tiles:
		var mag = randi() % 8 + 2
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
	var im_lead: Image = Image.load_from_file("res://Map/Map_Images/lead.png")
	var im_iron: Image = Image.load_from_file("res://Map/Map_Images/iron.png")
	var im_coal: Image = Image.load_from_file("res://Map/Map_Images/coal.png")
	var im_copper: Image = Image.load_from_file("res://Map/Map_Images/copper.png")
	var im_cotton: Image = Image.load_from_file("res://Map/Map_Images/cotton.png")
	var im_silk: Image = Image.load_from_file("res://Map/Map_Images/silk.png")
	var im_coffee: Image = Image.load_from_file("res://Map/Map_Images/coffee.png")
	var im_tobacco: Image = Image.load_from_file("res://Map/Map_Images/tobacco.png")
	var im_gold: Image = Image.load_from_file("res://Map/Map_Images/gold.png")
	var real_x = -610
	var real_y = -244
	for x in im_volcanoes.get_width():
		for y in im_volcanoes.get_height():
			if x % 3 == 0 or y % 7 <= 2:
				continue
			
			var tile: Vector2i = Vector2i(real_x, real_y)
			
			var color: Color = im_volcanoes.get_pixel(x, y)
			if color.r > (color.b + color.g + 0.5) and !is_tile_water(tile):
				toReturn[2].push_back(tile)
			
			color = im_lead.get_pixel(x, y)
			if color.r > (color.b + color.g - 0.45) and color.r > 0.6 and !is_tile_water(tile):
				toReturn[3].push_back(tile)
			
			color = im_iron.get_pixel(x, y)
			if color.r > (color.b + color.g) or color.b > (color.r + color.g) and !is_tile_water(tile):
				toReturn[4].push_back(tile)
			
			color = im_coal.get_pixel(x, y)
			if color.r > 0.75 and color.r > (color.b + color.g - 0.3) and !is_tile_water(tile):
				toReturn[5].push_back(tile)
			
			color = im_copper.get_pixel(x, y)
			
			if color.b > (color.r + color.g - 0.4) and color.b > (color.r + 0.05) and !is_tile_water(tile):
				toReturn[6].push_back(tile)
			elif 0.01 < color.get_luminance() and color.get_luminance() < 0.65 and !is_tile_water(tile):
				toReturn[6].push_back(tile)
			
			color = im_cotton.get_pixel(x, y)
			if color.r > 0.75 and color.r > (color.b + 0.1) and !is_tile_water(tile):
				toReturn[14].push_back(tile)
			
			color = im_silk.get_pixel(x, y)
			if 1.3 < (color.b + color.g) and color.r > 0.75 and color.r > (color.b + 0.07) and !is_tile_water(tile):
				if randi() % 5 == 0:
					toReturn[15].push_back(tile)
			elif color.r > 0.75 and color.r > (color.b + 0.07) and !is_tile_water(tile):
				toReturn[15].push_back(tile)
			
			color = im_coffee.get_pixel(x, y)
			if color.r > 0.9 and 0.9 > color.b and 0.9 > color.g and !is_tile_water(tile):
				if 0.7 > color.b and 0.7 > color.g:
					toReturn[17].push_back(tile)
				elif randi() % 5 == 0:
					toReturn[17].push_back(tile)
			
			color = im_tobacco.get_pixel(x, y)
			if 1.3 < (color.b + color.g) and color.r > 0.75 and color.r > (color.b + 0.07) and !is_tile_water(tile):
				if randi() % 5 == 0:
					toReturn[19].push_back(tile)
			elif color.r > 0.75 and color.r > (color.b + 0.1) and !is_tile_water(tile):
				toReturn[19].push_back(tile)
			
			
			color = im_gold.get_pixel(x, y)
			if 1.3 < (color.b + color.g) and color.r > 0.75 and color.r > (color.b + 0.07) and !is_tile_water(tile):
				if randi() % 5 == 0:
					toReturn[20].push_back(tile)
			elif color.r > 0.75 and color.r > (color.b + 0.1) and !is_tile_water(tile):
				toReturn[20].push_back(tile)
			
			
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
