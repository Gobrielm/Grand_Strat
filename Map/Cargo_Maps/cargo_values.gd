extends Node2D

const TILES_PER_ROW = 8
const MAX_CLAY = 5000

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

func place_resources(map: TileMapLayer):
	autoplace_clay(map)

func autoplace_clay(map: TileMapLayer):
	var count = 0
	for cell: Vector2i in get_tiles_for_clay(map):
		var mag = randi() % 10
		$Layer0Clay.set_cell(cell, 1, get_atlas_for_magnitude(mag))
		count += mag
		if count > MAX_CLAY:
			return

func get_tiles_for_clay(map: TileMapLayer) -> Array:
	var toReturn = []
	for tile in map.get_used_cells_by_id(0, Vector2i(6, 0)):
		if is_tile_river(map, tile):
			for cell: Vector2i in map.get_surrounding_cells(tile):
				if !is_tile_water(map, cell):
					toReturn.append(cell)
	for tile in map.get_used_cells_by_id(0, Vector2i(5, 0)):
		for cell in map.get_surrounding_cells(tile):
			if get_tile_elevation(map.get_cell_atlas_coords(cell)) == 0:
				toReturn.append(cell)
	
	toReturn.shuffle()
	return toReturn

func is_tile_water(map: TileMapLayer, coords: Vector2i) -> bool:
	var atlas = map.get_cell_atlas_coords(coords)
	return atlas == Vector2i(6, 0) or atlas == Vector2i(7, 0)

func get_tile_elevation(atlas: Vector2i) -> int:
	if atlas == Vector2i(5, 0) or atlas == Vector2i(3, 3):
		return 2
	elif atlas == Vector2i(3, 0) or atlas == Vector2i(4, 0) or atlas == Vector2i(5, 1) or atlas == Vector2i(3, 2) or atlas == Vector2i(3, 3):
		return 1
	return 0

func is_tile_river(map: TileMapLayer, coords: Vector2i) -> bool:
	var count = 0
	for cell in map.get_surrounding_cells(coords):
		if !is_tile_water(map, cell):
			count += 1
	return count > 3

#func create_continents(map: TileMapLayer):
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
