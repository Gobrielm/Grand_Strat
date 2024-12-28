class_name rail_graph_controller extends Node

var map: TileMapLayer
var rail_vertices = {}

func _init(new_map: TileMapLayer):
	map = new_map

func add_rail_vertex(coordinates: Vector2i):
	rail_vertices[coordinates] = rail_vertex.new(coordinates)
	search_for_connections(rail_vertices[coordinates])

func move_rail_vertex(coordinates: Vector2i, new_coordinates: Vector2i):
	rail_vertices[coordinates].move_vertex()
	rail_vertices[new_coordinates] = rail_vertices[coordinates]
	rail_vertices.erase(coordinates)

func get_vertex(coordinates: Vector2i) -> rail_vertex:
	return rail_vertices[coordinates]

func is_tile_vertix(coordinates: Vector2i) -> bool:
	return rail_vertices.has(coordinates)

func search_for_connections(vertex: rail_vertex):
	var coordinates = vertex.get_coordinates()
	var queue = []
	var visited = {}
	var distance_away = {}
	var current
	queue.append(coordinates)
	distance_away[coordinates] = 0
	while !queue.is_empty():
		current = queue.pop_front()
		visited[current] = 1
		var rail_connections: Array = map.get_tile_connections(current)
		for direction in rail_connections.size():
			#If there is connection in that direction could the train traverse there?
			if rail_connections[direction]:
				var tile = get_neighbor_cell_given_direction(current, direction)
				#Does this tile also connect back to path_find_pos
				if map.get_tile_connections(tile)[(direction + 3) % 6] and !visited.has(tile):
					if is_tile_vertix(tile):
						var vert = get_vertex(tile)
						var dist = distance_away[current] + 1
						vertex.add_connection(vert, dist)
						vert.add_connection(vertex, dist)
					else:
						queue.append(tile)
						distance_away[tile] = distance_away[current] + 1

func get_neighbor_cell_given_direction(coords: Vector2i, num: int) -> Vector2i:
	if num == 0:
		return map.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_TOP_SIDE)
	elif num == 1:
		return map.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE)
	elif num == 2:
		return map.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE)
	elif num == 3:
		return map.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	elif num == 4:
		return map.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE)
	elif num == 5:
		return map.get_neighbor_cell(coords, TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE)
	return Vector2i(0, 0)

func delete_rail_vertex(coordinates: Vector2i):
	rail_vertices.erase(coordinates)
	#Add dfs to find and remove routes that connect to vertex
	#Then add dfs to try and connect routes again
