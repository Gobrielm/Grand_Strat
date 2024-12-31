class_name rail_graph_controller extends Node

var map: TileMapLayer
var rail_vertices = {}

func _init(new_map: TileMapLayer):
	map = new_map

func clear_and_clean_all_vertices():
	for vertex in rail_vertices.values():
		vertex.queue_free()
	rail_vertices.clear()

func add_stationary_vertex(coordinates: Vector2i):
	rail_vertices[coordinates] = rail_vertex_stationary.new(coordinates)
	search_for_connections(rail_vertices[coordinates])
	var vertex = get_vertex(coordinates)
	for vert in vertex.get_connections():
		vert.remove_all_connections()
		search_for_connections(vert)

func add_rail_vertex(coordinates: Vector2i):
	rail_vertices[coordinates] = rail_vertex.new(coordinates)
	search_for_connections(rail_vertices[coordinates])
	var vertex = get_vertex(coordinates)
	for vert in vertex.get_connections():
		vert.remove_all_connections()
		search_for_connections(vert)
	check_convert_endpoint_intersection(coordinates)

func check_convert_endpoint_intersection(coordinates: Vector2i):
	var vertex = get_vertex(coordinates)
	var count = vertex.connections.size()
	if count < 2:
		rail_vertices[coordinates] = rail_vertex_endpoint.new(vertex)
	else:
		rail_vertices[coordinates] = rail_vertex_intersection.new(vertex)

func move_rail_vertex(coordinates: Vector2i, new_coordinates: Vector2i):
	rail_vertices[coordinates].move_vertex(new_coordinates)
	rail_vertices[new_coordinates] = rail_vertices[coordinates]
	rail_vertices.erase(coordinates)

func get_vertex(coordinates: Vector2i) -> rail_vertex:
	return rail_vertices[coordinates]

func does_vertex_have_no_connections(coordinates: Vector2i) -> bool:
	return get_vertex(coordinates).get_connections_count() == 0

func is_tile_vertex(coordinates: Vector2i) -> bool:
	return rail_vertices.has(coordinates)

func is_tile_stationary_vertix(coordinates: Vector2i) -> bool:
	return rail_vertices.has(coordinates) and rail_vertices[coordinates] is rail_vertex_stationary

func is_tile_endpoint(coordinates: Vector2i) -> bool:
	return rail_vertices.has(coordinates) and rail_vertices[coordinates] is rail_vertex_endpoint

func is_tile_intersection(coordinates: Vector2i) -> bool:
	return rail_vertices.has(coordinates) and rail_vertices[coordinates] is rail_vertex_intersection

func connect_and_delete_endpoint_to_non_endpoint(coords1: Vector2i, coords2: Vector2i):
	var endpoint: rail_vertex_endpoint
	var non_endpoint: rail_vertex
	if get_vertex(coords1) is rail_vertex_endpoint and !(get_vertex(coords2) is rail_vertex_endpoint):
		non_endpoint = get_vertex(coords2)
		delete_rail_vertex(coords1)
	else:
		non_endpoint = get_vertex(coords1)
		delete_rail_vertex(coords2)
	search_for_connections(endpoint)
	

func connect_two_endpoints(coords1: Vector2i, coords2: Vector2i):
	var vertex1 = get_vertex(coords1)
	var vertex2 = get_vertex(coords2)
	if vertex1 is rail_vertex_endpoint and vertex2 is rail_vertex and !(vertex2 is rail_vertex_endpoint):
		connect_and_delete_endpoint_to_non_endpoint(coords1, coords2)
	elif vertex2 is rail_vertex_endpoint and vertex1 is rail_vertex and !(vertex1 is rail_vertex_endpoint):
		connect_and_delete_endpoint_to_non_endpoint(coords1, coords2)
	var connections = []
	connections.append(vertex1.get_connection())
	connections.append(vertex2.get_connection())
	var length = get_length(vertex1, vertex2)
	if connections[0] == null and connections[1] == null:
		connect_two_isolated_rails(vertex1, vertex2)
		return
	elif connections[0] == null:
		connect_isolated_rail_to_rest(coords2, coords1)
		return
	elif connections[1] == null:
		connect_isolated_rail_to_rest(coords1, coords2)
		return
	elif connections[0] == vertex2 and connections[1] == vertex1:
		delete_rail_vertex(coords1)
		delete_rail_vertex(coords2)
		return
	elif connections[0] == connections[1]:
		delete_rail_vertex(coords1)
		delete_rail_vertex(coords2)
		connections[0].remove_connection(vertex1)
		connections[0].remove_connection(vertex2)
		return
	connections[0].remove_connection(vertex1)
	connections[1].remove_connection(vertex2)
	delete_rail_vertex(coords1)
	delete_rail_vertex(coords2)
	connections[0].add_connection(connections[1], length)
	connections[1].add_connection(connections[0], length)
	
func connect_isolated_rail_to_rest(coords1: Vector2i, coords2: Vector2i):
	var vertex = get_vertex(coords1)
	var vertex_isolated = get_vertex(coords2)
	var connection = vertex.get_connection()
	var length = get_length(vertex, vertex_isolated)
	
	connection.remove_connection(vertex)
	delete_rail_vertex(coords1)
	connection.add_connection(vertex_isolated, length)
	vertex_isolated.add_connection(connection, length)
		
func connect_two_isolated_rails(vertex1: rail_vertex, vertex2: rail_vertex):
	vertex1.add_connection(vertex2, 1)
	vertex2.add_connection(vertex1, 1)

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
					if is_tile_vertex(tile):
						var vert = get_vertex(tile)
						var dist = distance_away[current] + 1
						vertex.check_coonection_add_if_shorter(vert, dist)
						vert.check_coonection_add_if_shorter(vertex, dist)
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
	var vertex = get_vertex(coordinates)
	for connected_vertex: rail_vertex in vertex.get_connections():
		connected_vertex.add_connection(vertex, connected_vertex.get_length(vertex))
		connected_vertex.remove_connection(vertex)
	vertex.queue_free()
	rail_vertices.erase(coordinates)
	
