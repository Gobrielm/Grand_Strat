class_name rail_vertex extends Node
var location: Vector2i
var connections: Dictionary = {}

func _init(new_location: Vector2i):
	location = new_location

func get_coordinates() -> Vector2i:
	return location

func move_vertex(new_location: Vector2i):
	var change = 0 if new_location == location else 1
	location = new_location
	for vertex in connections:
		connections[vertex] += change
		vertex.change_connection(self, change)

func add_connection(other_vertex: rail_vertex, distance: int):
	connections[other_vertex] = distance

func change_connection(vertex_that_changed, distance_change):
	connections[vertex_that_changed] += distance_change

func get_connection() -> rail_vertex:
	if get_connections_count() == 1:
		return connections.keys()[0]
	return null

func get_length(vertex: rail_vertex) -> int:
	if connections.has(vertex):
		return connections[vertex]
	return -1

func get_connections() -> Dictionary:
	return connections

func get_connections_count() -> int:
	return connections.keys().size()

func remove_connection(other_vertex: rail_vertex):
	connections.erase(other_vertex)