class_name rail_graph_controller extends Node

var map: TileMapLayer
var rail_vertices = {}

func _init(new_map: TileMapLayer):
	map = new_map

func add_rail_vertex(coordinates: Vector2i):
	rail_vertices[coordinates] = rail_vertex.new(coordinates)
	search_for_connections(rail_vertices[coordinates])

func move_rail_vertex(coordinates: Vector2i, new_coordinates: Vector2i):
	rail_vertices[coordinates].move_vertex(new_coordinates)
	rail_vertices[new_coordinates] = rail_vertices[coordinates]
	rail_vertices.erase(coordinates)

func get_vertex(coordinates: Vector2i) -> rail_vertex:
	return rail_vertices[coordinates]

func does_vertex_have_no_connections(coordinates: Vector2i) -> bool:
	return get_vertex(coordinates).get_connections_count() == 0

func is_tile_vertix(coordinates: Vector2i) -> bool:
	return rail_vertices.has(coordinates)

func connect_two_endpoints(coords1: Vector2i, coords2: Vector2i):
	var vertex1 = get_vertex(coords1)
	var vertex2 = get_vertex(coords2)
	var connections = []
	connections.append(vertex1.get_connection())
	connections.append(vertex2.get_connection())
	var length = get_length(vertex1, vertex2)
	if connections[0] != null:
		connections[0].remove_connection(vertex1)
		delete_rail_vertex(coords1)
	if connections[1] != null:
		connections[1].remove_connection(vertex2)
		delete_rail_vertex(coords2)
	if connections[0] != null and connections[1] != null:
		connections[0].add_connection(connections[1], length)
		connections[1].add_connection(connections[0], length)
	elif connections[0] != null:
		connections[0].add_connection(vertex2, length)
		vertex2.add_connection(connections[0], length)
	else:
		vertex1.add_connection(connections[1], length)
		connections[1].add_connection(vertex1, length)
	
		

func get_length(vertex1: rail_vertex, vertex2: rail_vertex) -> int:
	var length = 0
	if vertex1.get_connection() != null:
		length += vertex1.get_connection().get_length(vertex1)
	if vertex2.get_connection() != null:
		length += vertex2.get_connection().get_length(vertex2)
	return length + 1

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