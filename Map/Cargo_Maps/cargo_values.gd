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
	@warning_ignore("integer_division")
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
	create_territories()
	place_population()
	var threads := []
	for i in get_child_count():
		var thread = Thread.new()
		threads.append(thread)
		thread.start(autoplace_resource.bind(resource_array[i], get_child(i), MAX_RESOURCES[i]))
	for thread: Thread in threads:
		thread.wait_to_finish()

func autoplace_resource(tiles: Dictionary, layer: TileMapLayer, max_resouces: int):
	var array: Array = tiles.keys()
	array.shuffle()
	var count = 0
	for cell: Vector2i in array:
		var mag = randi() % 4 + tiles[cell]
		layer.call_deferred_thread_group("set_cell", cell, 1, get_atlas_for_magnitude(mag))
		count += mag
		if count > max_resouces and max_resouces != -1:
			return

func place_population():
	var helper: Node = load("res://Map/Cargo_Maps/population_helper.gd").new()
	helper.create_population_map()
	helper.queue_free()

func create_territories():
	var provinces: TileMapLayer = preload("res://Map/Map_Info/provinces.tscn").instantiate()
	var tile_info = Utils.tile_info
	for real_x in range(-609, 671):
		for real_y in range(-243, 282):
			var tile := Vector2i(real_x, real_y)
			if !tile_info.is_tile_a_province(tile) and !is_tile_water(tile):
				var group: Array = create_territory(tile, provinces)
				var province_id: int = tile_info.create_new_province()
				tile_info.add_many_tiles_to_province(province_id, group)

func create_territory(start: Vector2i, provinces: TileMapLayer) -> Array:
	var atlas = provinces.get_cell_atlas_coords(start)
	var visited := {}
	visited[start] = 0
	var toReturn = [start]
	var queue := [start]
	while !queue.is_empty():
		var curr: Vector2i = queue.pop_front()
		for tile in provinces.get_surrounding_cells(curr):
			if !visited.has(tile) and provinces.get_cell_atlas_coords(tile) == atlas:
				visited[tile] = 0
				toReturn.push_back(tile)
				queue.push_back(tile)
			#Broken
			elif is_tile_water_and_real(tile):
				if visited[curr] < 5 and !visited.has(tile):
					visited[tile] = visited[curr] + 1
					queue.push_back(tile)
				elif visited.has(tile) and visited[tile] > visited[curr] + 1:
					visited[tile] = visited[curr] + 1
					queue.push_back(tile)
	return toReturn


func refresh_territories():
	var im_provinces: Image = load("res://Map/Map_Info/provinces.png").get_image()
	var provinces: TileMapLayer = preload("res://Map/Map_Info/provinces.tscn").instantiate()
	var coords_to_province_id := {}
	var colors_to_province_id := {}
	create_colors_to_province_id(colors_to_province_id)
	for real_x in range(-609, 671):
		for real_y in range(-243, 282):
			@warning_ignore("integer_division")
			var x := (real_x + 609) * 3 / 2
			@warning_ignore("integer_division")
			var y := (real_y + 243) * 7 / 4
			var tile := Vector2i(real_x, real_y)
			var color = get_closest_color(im_provinces.get_pixel(x, y))
			if is_tile_water(tile):
				continue
			
			if !colors_to_province_id.has(color):
				provinces.erase_cell(tile)
				continue
			
			coords_to_province_id[tile] = colors_to_province_id[color]
			provinces.add_tile_to_province(tile, colors_to_province_id[color])
	var scene := PackedScene.new()
	scene.pack(provinces)
	var file = "res://Map/Map_Info/provinces.tscn"
	if FileAccess.file_exists(file):
		var error = ResourceSaver.save(scene, file)
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
	
	var new_image := Image.create(1920, 919, false, Image.FORMAT_RGBA8)
	for real_x in range(-609, 671):
		for real_y in range(-243, 282):
			@warning_ignore("integer_division")
			var x := (real_x + 609) * 3 / 2
			@warning_ignore("integer_division")
			var y := (real_y + 243) * 7 / 4
			var tile := Vector2i(real_x, real_y)
			if is_tile_water(tile):
				continue
			new_image.set_pixel(x, y, provinces.get_color(tile))
			if x != 0 and y != 0:
				new_image.set_pixel(x - 1, y - 1, provinces.get_color(tile))
			if y != 0:
				new_image.set_pixel(x, y - 1, provinces.get_color(tile))
			if x != 0:
				new_image.set_pixel(x - 1, y, provinces.get_color(tile))
	file = "res://Map/Map_Info/provinces.png"
	new_image.save_png(file)
	provinces.queue_free()

func get_closest_color(color: Color) -> Color:
	var red := 0.0
	var blue := 0.0
	var green := 0.0
	if color.r > 0.45 and color.r < 0.55:
		red = 0.5
	if color.g > 0.45 and color.g < 0.55:
		green = 0.5
	if color.b > 0.45 and color.b < 0.55:
		blue = 0.5
	if red == blue and blue == green and red == 0.0:
		return color
	return Color(red, green, blue)

func create_colors_to_province_id(colors_to_province_id: Dictionary):
	colors_to_province_id[Color(1, 0, 0, 1)] = 0
	colors_to_province_id[Color(0, 1, 0, 1)] = 1
	colors_to_province_id[Color(0, 0, 1, 1)] = 2
	colors_to_province_id[Color(0.5, 0.5, 0, 1)] = 3
	colors_to_province_id[Color(0.5, 0, 0.5, 1)] = 4
	colors_to_province_id[Color(0, 0.5, 0.5, 1)] = 5

func is_tile_water(coords: Vector2i) -> bool:
	var atlas = map.get_cell_atlas_coords(coords)
	return atlas == Vector2i(6, 0) or atlas == Vector2i(7, 0) or atlas == Vector2i(-1, -1)

func is_tile_water_and_real(coords: Vector2i) -> bool:
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
